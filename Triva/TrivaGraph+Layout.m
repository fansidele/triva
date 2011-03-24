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
  [filter removeGraphNodes];

  //search for min max values considering the whole hierarchical graph
  NSDictionary *min = [self graphGlobalMinValues];
  NSDictionary *max = [self graphGlobalMaxValues];

  //do the layout
  [self recursiveLayoutWithMinValues: min maxValues: max];
}

- (void) recursiveLayoutWithMinValues: (NSDictionary *) minValues
                            maxValues: (NSDictionary *) maxValues
{
  if ([self visible]){
    //I appear, consider me to force-direct my position, layout me
    [filter addGraphNode: self];
    [self layoutWithMinValues: minValues maxValues: maxValues];
  }else{
    //I do not appear, recurse to my children
    NSEnumerator *en = [children objectEnumerator];
    TrivaGraph *child;
    while ((child = [en nextObject])){
      [child recursiveLayoutWithMinValues: minValues maxValues: maxValues];
    }
  }
}


- (void) layoutWithMinValues: (NSDictionary*) minValues
                   maxValues: (NSDictionary*) maxValues
{
  //layout myself with update my graph values
  PajeEntityType *type = [container entityType];
  NSDictionary *conf  = [filter graphConfigurationForContainerType: type];
  if (conf){
    NSString *sizeConf = [conf objectForKey: @"size"];
    NSString *typeConf = [conf objectForKey: @"type"];
    if (typeConf == nil){
      typeConf = @"node";
    }
    if (sizeConf != nil){
      double val = [self evaluateWithValues: values withExpr: sizeConf];
      double min = [self evaluateWithValues: minValues withExpr: sizeConf];
      double max = [self evaluateWithValues: maxValues withExpr: sizeConf];
      double dif = max - min;
      double multiplier;
      if (dif != 0) {
        multiplier = (val-min)/dif;
      }else{
        multiplier = (val-min)/min;
      }
      //multiplier = multiplier==0 ? 1 : multiplier;
      double s = MIN_SIZE + multiplier*(MAX_SIZE-MIN_SIZE);

      size = val;
      bb.size.width = s;
      bb.size.height = s;
    }
  }
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
    NSDictionary *cret = [child graphGlobalMinValues];
    [self mergeValuesDictionary: cret
                 intoDictionary: ret
               usingComparisong: NSOrderedAscending];
  }
  return ret;
}

- (void) drawLayout
{
  if (![self visible]) return;

  NSEnumerator *en;
  //draw a line to connected nodes

  [[NSColor grayColor] set];
  en = [connectedNodes objectEnumerator];
  TrivaGraph *partner;
  while ((partner = [en nextObject])){
    if (![partner visible]){
      partner = [partner higherVisibleParent];
    }
    NSPoint mp = [self centerPoint];
    NSPoint pp = [partner centerPoint];

    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint: mp];
    [path lineToPoint: pp];
    [path stroke];
  }

  //compositions
  //draw my components
  en = [compositions objectEnumerator];
  id comp;
  while ((comp = [en nextObject])){
    [comp drawLayout];
  }

  //draw myself
  NSBezierPath *border = [NSBezierPath bezierPathWithRect: bb];
  if ([self highlighted]){
    NSString *str;
    str = [NSString stringWithFormat: @"%@(%@) - %f",
                    name,
                    [container entityType],
                    size];
    [str drawAtPoint: NSMakePoint (bb.origin.x,
                                   bb.origin.y+bb.size.height)
      withAttributes: nil];
  }
  [[NSColor grayColor] set];
  [border stroke];
}
@end
