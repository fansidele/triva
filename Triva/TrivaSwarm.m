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
#include "TrivaSwarm.h"

@implementation TrivaSwarm
- (id) initWithConfiguration: (NSDictionary*) conf
                    withName: (NSString*) n
              forObject: (TrivaGraphNode*) obj
              withValues: (NSDictionary*) timeSliceValues
              andProvider: (TrivaFilter*) prov
{
  self = [super initWithFilter: prov andSpace: NO andName: n andObject: obj];

  //allocate array for objects
  objects = [[NSMutableArray alloc] init];
  objectsColors = [[NSMutableDictionary alloc] init];

  //saving node
  node = obj;

  //we need the filter
  NSString *filt = [conf objectForKey: @"filter"];
  if (!filt) {
    //no filter specified
    NSLog (@"%s:%d: no 'filter' configuration for composition %@",
                        __FUNCTION__, __LINE__, conf);
    return nil;
  }
  //we need the color
  NSSet *colors = [NSSet setWithArray: [conf objectForKey: @"color"]];
  if (!colors) {
    //no color specified
    NSLog (@"%s:%d: no 'color' configuration for composition %@",
                        __FUNCTION__, __LINE__, conf);
    return nil;
  }

  //getting the timeslice-node for my object
  TimeSliceTree *t = (TimeSliceTree*)[[prov timeSliceTree] searchChildByName: [obj name]];

  //check among its children if they were present in the swarm (filter variable indicates presence)
  NSEnumerator *en = [[t children] objectEnumerator];
  TimeSliceTree *child;
  while ((child = [en nextObject])){
    //if value is != 0, child is present in the swarm
    //checking if it should be present
    if ([[[child timeSliceValues] objectForKey: filt] doubleValue]){
      [objects addObject: [child name]];

      //finding color
      NSEnumerator *values = [[child timeSliceValues] keyEnumerator];
      id category;
      while ((category = [values nextObject])){
        if ([[[child timeSliceValues] objectForKey: category] doubleValue]>0 &&
                                          [colors containsObject: category]){
            [objectsColors setObject: [[child timeSliceColors]
                                          objectForKey: category]
                              forKey: [child name]];
        }
      }
    }
  }
  return self;
}

- (void) refreshWithinRect: (NSRect) rect
{
  bb = rect;
}

- (BOOL) draw
{
  int count = [objects count];
  if (!count) return NO;
  int i;
  double step = 20;//count;
  double s = 0;
  for (i = 0; i < count; i++){
    [[objectsColors objectForKey: [objects objectAtIndex: i]] set];
    NSBezierPath *path = [NSBezierPath bezierPath];
    //position of the dot
    [path appendBezierPathWithArcWithCenter:
                          NSMakePoint(bb.origin.x+bb.size.width/2,
                                      bb.origin.y+bb.size.height/2)
                                     radius: bb.size.width/2+bb.size.width*.3
                                 startAngle: s endAngle: s];
    //drawing the dot
    [path appendBezierPathWithArcWithCenter: [path currentPoint]
                                     radius: 3
                                 startAngle: 0
                                   endAngle: 360];
    [path fill];

    if ([node highlighted]){
      [[objects objectAtIndex: i] drawAtPoint: [path currentPoint]
                               withAttributes: nil];
    }
    s += step;
  }
  return YES;
}

- (void) dealloc
{
  [objects release];
  [objectsColors release];
  [super dealloc];
}
@end
