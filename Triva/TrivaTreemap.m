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
+ (TrivaTreemap*) nodeWithName: (NSString*)n
                      depth: (int)d
                     parent: (TrivaTree*)p
                   expanded: (BOOL)e
                  container: (PajeContainer*)c
                     filter: (TrivaFilter*)f
{
  return [[[self alloc] initWithName: n
              depth:d
             parent:p
           expanded:e
          container:c
             filter:f] autorelease];
}


- (id) initWithName: (NSString*)n
              depth: (int)d
             parent: (TrivaTree*)p
           expanded: (BOOL)e
          container: (PajeContainer*)c
             filter: (TrivaFilter*)f
{
  self = [super initWithName:n depth:d parent:p expanded:e container:c filter:f];
  if (self != nil){
    offset = 0;
    valueChildren = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void) timeSelectionChanged
{
  [super timeSelectionChanged];

  treemapValue = 0;
  [valueChildren removeAllObjects];

  NSEnumerator *en = [values keyEnumerator];
  NSString *valueName;
  while ((valueName = [en nextObject])){
    double value = [[values objectForKey: valueName] doubleValue];
    TrivaTreemap *obj = [TrivaTreemap nodeWithName: valueName
                                             depth: depth+1
                                            parent: self
                                          expanded: 0
                                         container: nil
                                            filter: filter];
    
    [obj setTreemapValue: value];
    treemapValue += value;
    [valueChildren addObject: obj];
  }
}

- (void) setTreemapValue: (double)v
{
  treemapValue = v;
}

- (double) treemapValue
{
  return treemapValue;
}

- (void) dealloc
{
  [super dealloc];
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
    [valueChildren sortedArrayUsingSelector:
            @selector(compareValue:)]];

  /* remove children with value equal to zero */
  int i;
  for (i = 0; i < [sortedCopy count]; i++){
    if ([[sortedCopy objectAtIndex: i] treemapValue] != 0){
      break;
    }else{
      [[sortedCopy objectAtIndex: i] setBoundingBox: NSZeroRect];
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
    }else{
      [[sortedCopyAggregated objectAtIndex: i] setBoundingBox: NSZeroRect];
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
- (void) refreshWithBoundingBox: (NSRect) bounds
{
  if ([self treemapValue] == 0){
    //nothing to calculate
    return;
  }
  [self setBoundingBox: bounds];
  double area = (bb.size.width) * (bb.size.height);
  double factor = area/[self treemapValue];
  [self calculateTreemapRecursiveWithFactor: factor];
}

/*
 * drawTreemap
 */
- (void) drawTreemap
{
  [[filter colorForAggregationValueNamed: name] set];
  NSRectFill(bb);

  //iterate through values (if there are any)
  NSEnumerator *en = [valueChildren objectEnumerator];
  TrivaTreemap *childValue;
  while ((childValue = [en nextObject])){
    [childValue drawTreemap];
  }

  if (depth == 0) return;

  if (isHighlighted){
    NSRect highlightedBorder = NSMakeRect (bb.origin.x + 1,
                                                       bb.origin.y + 1,
                                                       bb.size.width - 2,
                                                       bb.size.height - 2);
    [[NSColor yellowColor] set];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect: highlightedBorder];
    [path setLineWidth: 3];
    [path stroke];
  }else{
    [[NSColor lightGrayColor] set];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect: bb];
    [path setLineWidth: 0.8];
    [path stroke];
  }
}

- (void) drawBorder
{
  if (depth){
    double width = ([self maxDepth])/((float)depth);
    [[NSColor blackColor] set];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect: bb];
    [path setLineWidth: width];
    [path stroke];
  }
}

/*
 * Search method
 */
- (TrivaTreemap *) searchWith: (NSPoint) point
    limitToDepth: (int) d
{
  return nil;
  double x = point.x;
  double y = point.y;
  TrivaTreemap *ret = nil;
  if (x >= bb.origin.x &&
      x <= bb.origin.x+bb.size.width &&
      y >= bb.origin.y &&
      y <= bb.origin.y+bb.size.height){
    if ([self depth] == d){
      // recurse to aggregated children 
/*
      unsigned int i;
      for (i = 0; i < [aggregatedChildren count]; i++){
        TrivaTreemap *child = [aggregatedChildren
              objectAtIndex: i];
        if ([child treemapValue] &&
          x >= [child boundingBox].origin.x &&
                x <= [child boundingBox].origin.x+
            [child boundingBox].size.width&&
           y >= [child boundingBox].origin.y &&
                y <= [child boundingBox].origin.y+
              [child boundingBox].size.height){
            ret = child;
            break;
        }
      }
*/
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
