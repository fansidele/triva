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
#include "Tupi.h"
#include "TupiFunctions.h"

@implementation Tupi
- (id) init
{
  self = [super init];
  connectedNodes = [[NSMutableSet alloc] init];
  return self;
}

- (void) dealloc
{
  [connectedNodes release];
  [super dealloc];
}

- (void) setName: (NSString *) n
{
  if (name){
    [name release];
  }
  name = n;
  [name retain];
}

- (void) setType: (NSString *) n
{
  if (type){
    [type release];
  }
  type = n;
  [type retain];
}

- (void) setTupiType: (TupiType) n
{
  tupiType = n;
}

- (void) setBoundingBox: (NSRect) b
{
  bb = b;
}

- (void) connectToNode: (Tupi*) n
{
  [connectedNodes addObject: n];
}

- (NSString *) name
{
  return name;
}

- (NSString *) type
{
  return type;
}

- (TupiType) tupiType
{
  return tupiType;
}

- (NSRect) boundingBox
{
  return bb;
}

- (NSSet*) connectedNodes
{
  return connectedNodes;
}

- (NSString *) description
{
  return name;
}

- (NSUInteger)hash
{
  return [name hash];
}

- (BOOL)isEqual:(id)anObject
{
  return [name isEqual: [anObject name]];
}

/*
- (NSPoint) centerPoint
{
  return NSMakePoint (bb.origin.x + bb.size.width/2,
                      bb.origin.y + bb.size.height/2);
}

- (NSPoint) connectionPointTo: (Tupi *) node
{
  NSPoint center = [self centerPoint];
  return center;
  if (drawingType == TRIVA_NODE){
    return center;
  }else{
    NSPoint difNormalized = LMSNormalizePoint (NSSubtractPoints (center, [node centerPoint]));
    NSPoint ret = NSAddPoints (center, LMSMultiplyPoint(difNormalized, .3));
    return ret;
  }
}
*/

- (void) draw
{
  NSLog (@"%@ %@", name, connectedNodes);
/*
  NSAffineTransform *transform = [NSAffineTransform transform];
  if (drawingType == TRIVA_EDGE){
    int n = [connectedNodes count];
    if (n == 2){ //normal link
      Tupi *node1 = [[connectedNodes allObjects] objectAtIndex: 0];
      Tupi *node2 = [[connectedNodes allObjects] objectAtIndex: 1];
      NSPoint srcPoint = [node1 centerPoint];//To: self];
      NSPoint dstPoint = [node2 centerPoint];//To: self];
      double distance = LMSDistanceBetweenPoints (srcPoint, dstPoint);
    }
  }

  if (drawingType == TRIVA_EDGE){
    NSEnumerator *en = [connectedNodes objectEnumerator];
    Tupi *connectedNode;
    while ((connectedNode = [en nextObject])){
      [[NSColor grayColor] set];
      NSBezierPath *path = [NSBezierPath bezierPath];
      NSPoint center = [self centerPoint];
      NSPoint hisCenter = [connectedNode centerPoint];


        NSPoint oNorm = LMSNormalizePoint (NSSubtractPoints(center, hisCenter));
        NSPoint oNormPerp = NSMakePoint (-oNorm.y, oNorm.x);

        double distance = LMSDistanceBetweenPoints (center, hisCenter);
        NSPoint middle = NSSubtractPoints (hisCenter, LMSMultiplyPoint(oNorm,1));

      
      [path moveToPoint: center];
      [path lineToPoint: middle];//[connectedNode connectionPointTo: self]];
      [path stroke];
    }
  }

  [NSBezierPath strokeRect: NSMakeRect (-1,-1,2,2)]; 

  [transform concat];

  //draw my components
  NSEnumerator *en = [compositions objectEnumerator];
  id comp;
  while ((comp = [en nextObject])){
    [comp draw];
  }
*/
  
  //draw myself
  NSBezierPath *border = [NSBezierPath bezierPathWithRect: bb];
 // if (compositionHighlighted){
//    [[NSColor redColor] set];
 //   [border setLineWidth: 2]; 
//  }else{
    [[NSColor lightGrayColor] set];
//  }
  [border stroke];

/*
  [transform invert];
  [transform concat];
*/
}

- (void) layoutWith: (NSDictionary*)conf andValues: (NSDictionary*)values andProvider: (id) provider
{
}
@end
