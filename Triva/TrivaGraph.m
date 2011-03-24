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
#include "TrivaGraph.h"
#include <float.h>

#define BIGFLOAT FLT_MAX

@implementation TrivaGraph
+ (TrivaGraph*) nodeWithName: (NSString*)n
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
  }
  return self;
}

- (void) timeSelectionChanged
{
  [super timeSelectionChanged];

/*
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
*/
}


- (void) dealloc
{
  [super dealloc];
}


- (void) drawGraph
{
}

- (void) drawBorder
{
}

/*
 * Search method
 */
- (TrivaGraph *) searchWith: (NSPoint) point
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

@end
