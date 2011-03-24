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

@implementation TrivaGraph (Layout)
- (void) recursiveLayout
{
  [filter removeGraphNodes];
  [self recursiveLayout2];
}

- (void) recursiveLayout2
{
  //if i am expanded, recurse to my children
  if ([self expanded]){
    //recurse
    NSEnumerator *en = [children objectEnumerator];
    TrivaGraph *child;
    while ((child = [en nextObject])){
      [child recursiveLayout2];
    }
  }else{
    //add myself to the filter's force-directed algo
    [filter addGraphNode: self];
    //i am NOT expanded, layout myself
    [self layout];
  }
}

- (void) layout
{
  NSDictionary *minValues, *maxValues;
  minValues = [filter minValuesForContainerType: [container entityType]];
  maxValues = [filter maxValuesForContainerType: [container entityType]];

  //layout myself with update my graph values
  NSDictionary *configuration;
  configuration = [filter graphConfigurationForContainerType:
                            [container entityType]];
  if (configuration){
    NSString *sizeConfiguration = [configuration objectForKey: @"size"];
    double s;
    if ([self expressionHasVariables: sizeConfiguration]){
      double min = [self evaluateWithValues: minValues
                                   withExpr: sizeConfiguration];
      double max = [self evaluateWithValues: maxValues
                                   withExpr: sizeConfiguration];
      double val = [self evaluateWithValues: values
                                   withExpr: sizeConfiguration];
      double dif = max - min;
      if (dif != 0) {
        s = MIN_SIZE + ((val - min)/dif)*(MAX_SIZE-MIN_SIZE);
      }else{
        s = MIN_SIZE + ((val - min)/min)*(MAX_SIZE-MIN_SIZE);
      }
      size = val;
    }else{
      s = [sizeConfiguration doubleValue];
    }
    bb.size.width = s;
    bb.size.height = s;
  }
}

- (void) layoutSizeWith: (double) s
{
}

- (void) layoutConnectionPointsWith: (double) screenSize
{
  //pre-requisite is layout bounding box size
  [self layoutSizeWith: screenSize];

  //release previous layout definitions
  [connectionPoints release];
  connectionPoints = [[NSMutableDictionary alloc] init];

  int n = [connectedNodes count];
  if (n <= 4){
    NSEnumerator *en = [connectedNodes objectEnumerator];
    TrivaGraph *p;
    double x = bb.size.width/2;
    double y = 0;
    while ((p = [en nextObject])){
      [connectionPoints setObject: 
                          NSStringFromPoint (NSMakePoint (x, y))
                           forKey: [p name]];
      x += bb.size.width/2;
      if (x > bb.size.width) { x = 0; }
      y += bb.size.height/2;
      if (y > bb.size.height) { y = 0; }
    }
  }else{
    NSEnumerator *en = [connectedNodes objectEnumerator];
    TrivaGraph *p;
    double x = bb.size.width/2;
    double y = bb.size.height/2;
    while ((p = [en nextObject])){
      [connectionPoints setObject:
                          NSStringFromPoint(NSMakePoint(x,y))
                           forKey: [p name]];
      x += bb.size.width/n;
      if (x > bb.size.width) { x = bb.size.width/n; }
    }
  }
}

- (NSPoint) connectionPointForPartner: (TrivaGraph *) p
{
  NSString *a = [connectionPoints objectForKey: [p name]];
  NSPoint ret;
  if (a){
    ret = NSPointFromString(a);
  }else{
    ret = [self centerPoint];
  }
  NSAffineTransform *t = [NSAffineTransform transform];
  [t translateXBy: bb.origin.x yBy: bb.origin.y];
  return [t transformPoint: ret];
}
@end
