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
#include "TrivaGraphEdge.h"
#include <math.h>

double LMSAngleBetweenPoints (NSPoint pt1, NSPoint pt2)
{
  double ptxd = pt1.x - pt2.x;
  double ptyd = pt1.y - pt2.y;
  return 90-(atan2 (ptxd, ptyd)/M_PI*180);
}

double LMSDistanceBetweenPoints(NSPoint pt1, NSPoint pt2)
{
  double ptxd = pt1.x - pt2.x;
  double ptyd = pt1.y - pt2.y;
  return sqrt( ptxd*ptxd + ptyd*ptyd );
}

@implementation TrivaGraphEdge
- (void) setSource: (TrivaGraphNode *) s;
{
  [source release];
  source = s;
  [source retain];
}

- (void) setDestination: (TrivaGraphNode *) d
{
  [destination release];
  destination = d;
  [destination retain];
}

- (TrivaGraphNode *) source
{
  return source;
}

- (TrivaGraphNode *) destination
{
  return destination;
}

- (void) dealloc
{
  [source release];
  [destination release];
  [super dealloc];
}

- (void) setBoundingBox: (NSRect) b
{
  //get size from b.size.width (or b.size.height)
  //ignore the rest of b
  bb.origin.x = 0;
  bb.origin.y = 0;
  bb.size.width = b.size.width;
  bb.size.height = b.size.height;
}

- (void) draw
{
  NSRect srcRect = [source bb];
  NSRect dstRect = [destination bb];
  NSPoint srcPoint = NSMakePoint (srcRect.origin.x+srcRect.size.width/2,
          srcRect.origin.y+srcRect.size.height/2);
  NSPoint dstPoint = NSMakePoint (dstRect.origin.x+dstRect.size.width/2,
          dstRect.origin.y+dstRect.size.height/2);
  double angle = LMSAngleBetweenPoints (dstPoint, srcPoint);

  NSAffineTransform* xform = [NSAffineTransform transform];
  [xform translateXBy: srcPoint.x yBy: srcPoint.y];
  [xform rotateByDegrees: angle];
  if (![[destination connectedNodes] containsObject: source]){
    [xform translateXBy: 0 yBy: -bb.size.height/2];
  }
  [xform concat];
  [super draw];
  [xform invert];
  [xform concat];
}

- (void) refresh
{
  //screenbb is already updated by call to [convertFrom:bb to:tela]
  //(of superclass). must calculate here the part of screenbb related
  //to the distance between the nodes

  //calculate the distance from src to dst
  NSRect srcRect = [source bb];
  NSRect dstRect = [destination bb];
  NSPoint srcPoint = NSMakePoint (srcRect.origin.x+srcRect.size.width/2,
          srcRect.origin.y+srcRect.size.height/2);
  NSPoint dstPoint = NSMakePoint (dstRect.origin.x+dstRect.size.width/2,
          dstRect.origin.y+dstRect.size.height/2);
  double distance = LMSDistanceBetweenPoints (srcPoint, dstPoint);
  bb.size.width = distance;

  //divide my space among my compositions
  [super refresh];
}
@end
