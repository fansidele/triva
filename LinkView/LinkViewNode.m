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

#include <AppKit/AppKit.h>
#include "LinkViewNode.h"
#include "LinkViewEdge.h"
#include "LinkView.h"
#include <math.h>

@implementation LinkViewNode
- (id) init
{
  self = [super init];
  edges = [[NSMutableArray alloc] init];
  return self;
}

- (void) dealloc
{
  [edges release];
  [super dealloc];
}

- (id) initWithTimeSliceTree: (TimeSliceTree*) tree andProvider: (id) prov
{
  self = [self init];
  [self setName: [tree name]];
  [[prov nodes] setObject: self forKey: name];

  int i;
  for (i = 0; i < [[tree children] count]; i++){
    TimeSliceTree *child = [[tree children] objectAtIndex: i];
    LinkViewNode *node;
    node = [[LinkViewNode alloc] initWithTimeSliceTree: child
                                                  andProvider: prov];
    [node setParent: self];
    [children addObject: node];
    [node release];
  }

  if ([[tree children] count] == 0){
    [self setTreemapValue: 1];
  }else{
    NSEnumerator *en = [children objectEnumerator];
    LinkViewNode *child;
    double val = 0;
    while ((child = [en nextObject])){
      val += [child treemapValue];
    }
    [self setTreemapValue: val];
  }
  [self setProvider: prov];
  [self setDepth: [tree depth]];
  [self setMaxDepth: [tree maxDepth]];

  NSDictionary *destinations = [tree destinations];
  NSEnumerator *en = [destinations keyEnumerator];
  id dest;
  while ((dest = [en nextObject])){
    TimeSliceGraph *graph = [destinations objectForKey: dest];
    double w = [[[[graph timeSliceValues] allValues] objectAtIndex: 0] doubleValue];
    LinkViewEdge *edge = [[LinkViewEdge alloc] init];
    [edge setWidth: w];
    [edge setProvider: prov];
    [edge setSource: [self name]];
    [edge setDestination: dest];//[[prov nodes] objectForKey: dest]];
    [edges addObject: edge];
    [edge release];
  }
  return self;
}

- (void) draw
{
  [[[NSColor blackColor] colorWithAlphaComponent: 0.8] set];
  [NSBezierPath setDefaultLineWidth: 1];
  [NSBezierPath strokeRect: bb];
}

- (void) drawEdges
{
//  NSLog (@"%@ %@", name, edges);
  NSEnumerator *en = [edges objectEnumerator];
  LinkViewEdge *edge;
  while ((edge = [en nextObject])){
    [edge draw];
/*
    NSRect sr = [[edge source] bb];
//    NSLog (@"%@", [edge destination]);
    NSRect dr = [[edge destination] bb];

    NSPoint sp = NSMakePoint (sr.origin.x + sr.size.width/2,
                                          sr.origin.y + sr.size.height/2);
    NSPoint dp = NSMakePoint (dr.origin.x + dr.size.width/2,
                                          dr.origin.y + dr.size.height/2);

    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint: sp];
    [path lineToPoint: dp];
    [path stroke];
//    NSLog (@"%@(%@) -> %@(%@)",
//        [[edge source] name], NSStringFromPoint(sp),
//        [[edge destination] name], NSStringFromPoint(dp));
//    NSLog (@"%@ %@", NSStringFromRect([[edge source] bb]),
//        NSStringFromRect ([[edge destination] bb]));
*/
  }
//  [name drawAtPoint: NSMakePoint (bb.origin.x, bb.origin.y)
  //         withAttributes: nil];
}
@end
