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
- (void) layoutSizeWith: (double) screenSize
{
  //define width/height sizes according to number of connectedNodes
  int n = [connectedNodes count];
  if (n > 4) {
    bb.size.width = (n-1)/2*screenSize;
  }else{
    bb.size.width = screenSize;      
  }
  bb.size.height = screenSize;
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
