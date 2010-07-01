/*
    This file is part of Triva.

    Triva is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Triva is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Triva.  If not, see <http://www.gnu.org/licenses/>.
*/
#include "TrivaTreemap.h"
#include <float.h>

#define BIGFLOAT FLT_MAX

@implementation TrivaTreemap
- (id) init
{
  self = [super init];
  treemapValue = 0;
  highlighted = NO;
  provider = nil;
  aggregatedChildren = nil;
  offset = 0;
  return self;
}

- (id) initWithTimeSliceTree: (TimeSliceTree*) tree andProvider: (id) prov
{
  self = [self init];
  [self setProvider: prov];
  [self setName: [tree name]];
  [self setTreemapValue: [tree finalValue]];
  [self setDepth: [tree depth]];
  [self setMaxDepth: [tree maxDepth]];

  /* create aggregated children */
  if (aggregatedChildren){
    [aggregatedChildren release];
  }
  aggregatedChildren = [[NSMutableArray alloc] init];

  NSDictionary *aggValues = [tree aggregatedValues];
  NSEnumerator *keys = [aggValues keyEnumerator];
  id key;
  while ((key = [keys nextObject])){
    TrivaTreemap *aggNode = [[TrivaTreemap alloc] init];
    [aggNode setProvider: prov];
    [aggNode setName: key];
    [aggNode setTreemapValue:
      [[aggValues objectForKey: key] floatValue]];
    [aggNode setDepth: [tree depth] + 1];
    [aggNode setMaxDepth: [tree maxDepth]];
    [aggNode setType: [[tree timeSliceTypes] objectForKey: key]];
    [aggNode setParent: self];
    [aggregatedChildren addObject: aggNode];
    [aggNode release];
  }

  /* recurse normally */
  int i;
  for (i = 0; i < [[tree children] count]; i++){
    TimeSliceTree *child = [[tree children] objectAtIndex: i];
    TrivaTreemap *node = [[TrivaTreemap alloc] initWithTimeSliceTree: child
                                   andProvider: prov];
    [node setParent: self];
    [children addObject: node];
    [node release];
  }
  return self;
}

- (void) setTreemapValue: (float) v
{
  treemapValue = v;
}

- (float) treemapValue
{
  return treemapValue;
}

- (void) dealloc
{
  [aggregatedChildren release];
  [super dealloc];
}

- (NSArray *) aggregatedChildren
{
  return aggregatedChildren;
}

- (double) worstf: (NSArray *) list
    withSmallerSize: (double) w
    withFactor: (double) factor
{
  double rmax = 0, rmin = FLT_MAX, s = 0;
  int i;
  for (i = 0; i < [list count]; i++){
    TrivaTreemap *child = (TrivaTreemap *)[list objectAtIndex: i];
    double childValue = [child treemapValue]*factor;
    rmin = rmin < childValue ? rmin : childValue;
    rmax = rmax > childValue ? rmax : childValue;
    s += childValue;
  }
  s = s*s; w = w*w;
  double first = w*rmax/s, second = s/(w*rmin);
  return first > second ? first : second;
}


- (NSRect)layoutRow: (NSArray *) row
    withSmallerSize: (double) w
    withinRectangle: (NSRect) r
    withFactor: (double) factor
{
  double s = 0; // sum
  int i;
  for (i = 0; i < [row count]; i++){
    s += [(TrivaTreemap *)[row objectAtIndex: i] treemapValue]*factor;
  }
  double x = r.origin.x, y = r.origin.y, d = 0;
  double h = w==0 ? 0 : s/w;
  BOOL horiz = (w == r.size.width);

  for (i = 0; i < [row count]; i++){
    TrivaTreemap *child = (TrivaTreemap *)[row objectAtIndex: i];
    NSRect childRect;
    if (horiz){
      childRect.origin.x = x+d;
      childRect.origin.y = y;
    }else{
      childRect.origin.x = x;
      childRect.origin.y = y+d;
    }
    double nw = [child treemapValue]*factor/h;
    if (horiz){
      childRect.size.width = nw;
      childRect.size.height = h;
      d += nw;
    }else{
      childRect.size.width = h;
      childRect.size.height = nw;
      d += nw;
    }
    [child setBoundingBox: childRect];
  }
  if (horiz){
    r = NSMakeRect (x, y+h, r.size.width, r.size.height-h);
  }else{
    r = NSMakeRect (x+h, y, r.size.width-h, r.size.height);
  }
  return r;
}

- (void) squarifyWithOrderedChildren: (NSMutableArray *) list
    andSmallerSize: (double) w
    andFactor: (double) factor
{
  NSMutableArray *row = [NSMutableArray array];
  double worst = FLT_MAX, nworst;
  /* make a copy of my bb, so the algorithm can modify it */
  NSRect r = NSMakeRect (bb.origin.x+offset, bb.origin.y+offset,
                               bb.size.width-2*offset, bb.size.height-2*offset);

  while ([list count] > 0){
    /* check if w is still valid */
    if (w < 1){
      /* w should not be smaller than 1 pixel
         no space left for other children to appear */
      break;
    }

    [row addObject: [list objectAtIndex: [list count]-1]];
    nworst = [self worstf: row withSmallerSize: w
          withFactor: factor];
    if (nworst <= 1){
      /* nworst should not be smaller than ratio 1,
                           which is the perfect square */
      break;
    }
    if (nworst <= worst){
      [list removeLastObject];
      worst = nworst;
    }else{
      [row removeLastObject];
      r = [self layoutRow: row withSmallerSize: w
        withinRectangle: r withFactor: factor];//layout current row
      w = r.size.width < r.size.height ?
        r.size.width : r.size.height;
      [row removeAllObjects];
      worst = FLT_MAX;
    }
  }
  if ([row count] > 0){
    r = [self layoutRow: row withSmallerSize: w
      withinRectangle: r withFactor: factor];
    [row removeAllObjects];
  }
}

- (void) calculateTreemapRecursiveWithFactor: (double) factor
{
  /* make ascending order of children by value */
  NSMutableArray *sortedCopy = [NSMutableArray array];
  [sortedCopy addObjectsFromArray: 
    [children sortedArrayUsingSelector:
            @selector(compareValue:)]];
  NSMutableArray *sortedCopyAggregated = [NSMutableArray array];
  [sortedCopyAggregated addObjectsFromArray:
    [aggregatedChildren sortedArrayUsingSelector:
            @selector(compareValue:)]];

  /* remove children with value equal to zero */
  int i;
  for (i = 0; i < [sortedCopy count]; i++){
    if ([[sortedCopy objectAtIndex: i] treemapValue] != 0){
      break;
    }
  }
  NSRange range;
  range.location = 0;
  range.length = i;
  [sortedCopy removeObjectsInRange: range];
  
  /* remove aggregated children with value equal to zero */
  for (i = 0; i < [sortedCopyAggregated count]; i++){
    if ([[sortedCopyAggregated objectAtIndex: i] treemapValue]!=0){
      break;
    }
  }
  range.location = 0;
  range.length = i;
  [sortedCopyAggregated removeObjectsInRange: range];

  /* calculate the smaller size */
  double w = bb.size.width-2*offset < bb.size.height-2*offset ?
      bb.size.width-2*offset : bb.size.height-2*offset;

  /* recalculate factor based on new space available */
  //note: if offset is 0, the factor remains the same
        double area = (bb.size.width-2*offset) * (bb.size.height-2*offset);
        factor = area/[self treemapValue];

  /* call my squarified method with:
    - the list of children with values dif from zero
    - the smaller size
    - the copy of my bb
    - and factor */
  [self squarifyWithOrderedChildren: sortedCopy
      andSmallerSize: w
      andFactor: factor];
  /* call also to set the bbangles of aggregated children */
  [self squarifyWithOrderedChildren: sortedCopyAggregated
      andSmallerSize: w
      andFactor: factor];

  for (i = 0; i < [children count]; i++){
    [[children objectAtIndex: i]
      calculateTreemapRecursiveWithFactor: factor];
  }
  return;
}

/*
 * Entry method
 */
- (void) refresh
{
        if ([self treemapValue] == 0){
                //nothing to calculate
                return;
        }
        double area = (bb.size.width) * (bb.size.height);
        double factor = area/[self treemapValue];
        [self calculateTreemapRecursiveWithFactor: factor];
}

/*
 * draw
 */
- (void) draw
{
  [[provider colorForValue: name
                   ofEntityType: [provider entityTypeWithName: type]] set];
  NSRectFill(bb);
  [NSBezierPath strokeRect: bb];
  if (highlighted){
    [[NSColor blackColor] set];
    NSRect highlightedBorder = NSMakeRect (bb.origin.x + 1,
                                                       bb.origin.y + 1,
                                                       bb.size.width - 1,
                                                       bb.size.height - 1);
    [NSBezierPath strokeRect: highlightedBorder];
  }else{
    [[NSColor lightGrayColor] set];
    [NSBezierPath strokeRect: bb];
  }
}

/*
 * Search method
 */
- (TrivaTreemap *) searchWith: (NSPoint) point
    limitToDepth: (int) d
{
  double x = point.x;
  double y = point.y;
  TrivaTreemap *ret = nil;
  if (x >= bb.origin.x &&
      x <= bb.origin.x+bb.size.width &&
      y >= bb.origin.y &&
      y <= bb.origin.y+bb.size.height){
    if ([self depth] == d){
      // recurse to aggregated children 
      unsigned int i;
      for (i = 0; i < [aggregatedChildren count]; i++){
        TrivaTreemap *child = [aggregatedChildren
              objectAtIndex: i];
        if ([child treemapValue] &&
          x >= [child bb].origin.x &&
                x <= [child bb].origin.x+
            [child bb].size.width&&
           y >= [child bb].origin.y &&
                y <= [child bb].origin.y+
              [child bb].size.height){
            ret = child;
            break;
        }
      }
    }else{
      // recurse to ordinary children 
      unsigned int i;
      for (i = 0; i < [children count]; i++){
        TrivaTreemap *child;
        child = [children objectAtIndex: i];
        if ([child treemapValue]){
          ret = [child searchWith: point
                limitToDepth: d];
          if (ret != nil){
            break;
          }
        }
      }
    }
  }
  return ret;
}

- (NSComparisonResult) compareValue: (TrivaTreemap *) other
{
        if ([self treemapValue] < [other treemapValue]){
                return NSOrderedAscending;
        }else if ([self treemapValue] > [other treemapValue]){
                return NSOrderedDescending;
        }else{
                return NSOrderedSame;
        }
}

- (NSString *) description
{
  return name;  
}

- (void) testTree
{
        int i;
        if ([children count] != 0){
                for (i = 0; i < [children count]; i++){
                        [[children objectAtIndex: i] testTree];
                }
        }
        NSLog (@"%@ - %@ %.2f", name, bb, [self treemapValue]);
}

- (BOOL) highlighted
{
  return highlighted;
}

- (void) setHighlighted: (BOOL) v
{
  highlighted = v;
}

- (void) setProvider: (id) prov
{
  provider = prov;
}

- (void) setOffset: (double) o //recursive call
{
  offset = o;
  NSEnumerator *en = [children objectEnumerator];
  TrivaTreemap *child;
  while ((child = [en nextObject])){
    [child setOffset: offset];
  }
}

- (double) offset
{
  return offset;
}

- (NSMutableArray *) recursiveHierarchy
{
  NSMutableArray *ret = [NSMutableArray array];
  if (parent != nil){
    [ret addObjectsFromArray: [(TrivaTreemap*)parent recursiveHierarchy]];
  }

  if (parent == nil){
    [ret addObject: [NSString stringWithFormat: @"/"]];
  }else{
    [ret addObject: name];
  }
  return ret;
}

- (NSMutableArray *) hierarchy
{
  NSMutableArray *ret = [self recursiveHierarchy];
  [ret addObject: [NSString stringWithFormat: @"%f", [self treemapValue]]];
  return ret;
}
@end
