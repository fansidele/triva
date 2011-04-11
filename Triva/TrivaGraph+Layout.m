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
  //remove all nodes from force-directed algorithm
  [filter removeForceDirectedNodes];

  //do the layout
  [self recursiveLayout2];
}

- (void) recursiveLayout2
{
  if ([self visible]){
    //I appear, consider me to force-direct my position, layout me
    [filter addForceDirectedNode: self];
    [self layout];
  }else{
    //I do not appear, recurse to my children
    NSEnumerator *en = [children objectEnumerator];
    TrivaGraph *child;
    while ((child = [en nextObject])){
      [child recursiveLayout2];
    }
  }
}

- (void) layout
{
  //calculate my bounding box based on my compositions
  NSRect nbb = NSZeroRect;
  NSEnumerator *en = [compositions objectEnumerator];
  TrivaComposition *composition;
  while ((composition = [en nextObject])){
    [composition layout];
    NSRect compbb = [composition bb];
    nbb.size.width += compbb.size.width;
    nbb.size.height = fmax (nbb.size.height, compbb.size.height);
  }
  [self setBoundingBox: nbb];
}

- (void) recursiveLayout3
{
  if ([self visible]){
    [self layout];
  }else{
     //I do not appear, recurse to my children
    NSEnumerator *en = [children objectEnumerator];
    TrivaGraph *child;
    while ((child = [en nextObject])){
      [child recursiveLayout3];
    }   
  }
}

/*
- (NSPoint) connectionPointForPartner: (TrivaGraph *) p
{
  NSString *a = [connectionPoints objectForKey: [p name]];
  NSPoint ret;
  if (a){
    ret = NSPointFromString(a);
  }else{
    ret = location;
  }
  NSAffineTransform *t = [NSAffineTransform transform];
  [t translateXBy: bb.origin.x yBy: bb.origin.y];
  return [t transformPoint: ret];
}


- (void) mergeValuesDictionary: (NSDictionary *) a
                intoDictionary: (NSMutableDictionary *) b
              usingComparisong: (NSComparisonResult) comp
{
  //merge cret into ret
  NSEnumerator *en0 = [a keyEnumerator];
  NSString *key;
  while ((key = [en0 nextObject])){
    NSNumber *existingValue = [b objectForKey: key];
    NSNumber *newValue = [a objectForKey: key];
    if (existingValue == nil){
      [b setObject: newValue
            forKey: key];
    }else{
      if ([existingValue compare: newValue] == comp){
        [b setObject: [a objectForKey: key]
              forKey: key];
      }
    }
  }
}

- (NSDictionary *) graphGlobalMinValues
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithDictionary:
                                         [filter minValuesForContainerType:
                                                   [container entityType]]];
  NSEnumerator *en = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en nextObject])){
    NSDictionary *cret = [child graphGlobalMinValues];
    [self mergeValuesDictionary: cret
                 intoDictionary: ret
               usingComparisong: NSOrderedDescending];
  }
  return ret;
}

- (NSDictionary *) graphGlobalMaxValues
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithDictionary:
                                         [filter maxValuesForContainerType:
                                                   [container entityType]]];
  NSEnumerator *en = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en nextObject])){
    NSDictionary *cret = [child graphGlobalMaxValues];
    [self mergeValuesDictionary: cret
                 intoDictionary: ret
               usingComparisong: NSOrderedAscending];
  }
  return ret;
}
*/

- (void) drawConnectNodes
{
  [[[NSColor grayColor] colorWithAlphaComponent: 0.2] set];

  NSEnumerator *en = [connectedNodes objectEnumerator];
  TrivaGraph *partner;
  while ((partner = [en nextObject])){
    if (![partner visible]){
      partner = [partner higherVisibleParent];
    }
    NSPoint mp = [self location];
    NSPoint pp = [partner location];

    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint: mp];
    [path lineToPoint: pp];
    [path stroke];
  }
}

- (void) drawCompositions
{
  NSEnumerator *en = [compositions objectEnumerator];
  TrivaComposition *composition;
  double composition_origin = 0;
  while ((composition = [en nextObject])){
    NSAffineTransform *t = [NSAffineTransform transform];    
    [t translateXBy: composition_origin yBy: 0];
    [t concat];
    [composition drawLayout];
    [t invert];
    [t concat];
    composition_origin += [composition bb].size.width;
  }  
}

- (void) drawLayout
{
  if (![self visible]) return;

  NSAffineTransform *t = [NSAffineTransform transform];
  [t translateXBy: location.x - bb.size.width/2
              yBy: location.y - bb.size.height/2];
  [t concat];

  //draw my compositions
  [self drawCompositions];

  //draw myself
  if ([self highlighted]){
    [[NSColor redColor] set];
    double m = .05;
    NSRect x = NSMakeRect (bb.origin.x - bb.size.width*m,
                           bb.origin.y - bb.size.height*m,
                           bb.size.width + 2*bb.size.width*m,
                           bb.size.height + 2*bb.size.height*m);
    [[NSBezierPath bezierPathWithRect: x] stroke];
  }else{
    [[NSColor lightGrayColor] set];
  }
  // if ([children count]){
  //   NSBezierPath *path = [NSBezierPath bezierPath];
  //   [path appendBezierPathWithArcWithCenter: NSMakePoint(bb.size.width,
  //                                                        bb.size.height)
  //                                    radius: 5
  //                                startAngle: 270
  //                                  endAngle: 180];
  //   [path fill];
  // }

  [t invert];
  [t concat];
}
@end
