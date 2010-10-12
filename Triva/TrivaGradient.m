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
#include "TrivaGradient.h"

@implementation TrivaGradient
- (id) initWithFilter: (TrivaFilter *)f
     andConfiguration: (NSDictionary *) conf
             andSpace: (BOOL) s
              andName: (NSString*)n
            andObject: (TrivaGraphNode*)obj
{
  self = [super initWithFilter: f andConfiguration: conf
                      andSpace: s andName: n andObject: obj];
  min = [[NSMutableDictionary alloc] init];
  max = [[NSMutableDictionary alloc] init];
  return self;
}

- (id) initWithConfiguration: (NSDictionary*) conf
                    withName: (NSString*) n
                   forObject: (TrivaGraphNode*)obj
             withDifferences: (NSDictionary*) differences
                  withValues: (NSDictionary*) timeSliceValues
                 andProvider: (TrivaFilter*) prov
{
  self = [self initWithFilter: prov andConfiguration: conf
                     andSpace: YES andName: n andObject: obj];

  //get scale for this composition
  NSString *scaleconf = [conf objectForKey: @"scale"];
  if ([scaleconf isEqualToString: @"global"]){
    scale = Global;
  }else if ([scaleconf isEqualToString: @"local"]){
    scale = Local;
  }else{
    scale = Global;
  }

  [self redefineLayoutWithValues: timeSliceValues];
  return self;
}

- (void) redefineLayoutWithValues: (NSDictionary*) timeSliceValues
{
  //clear calculatedValues
  [calculatedValues removeAllObjects];

  //get values
  NSEnumerator *en2 = [values objectEnumerator];
  id var;
  while ((var = [en2 nextObject])){
    double val = [filter evaluateWithValues: timeSliceValues withExpr: var];
    double mi, ma;
    ma = [filter maxOfVariable: var
                     withScale: scale
                      ofObject: [node name]
                      withType: [(TrivaGraphNode*)node type]];
    mi = [filter minOfVariable: var
                     withScale: scale
                      ofObject: [node name]
                      withType: [(TrivaGraphNode*)node type]];
    [self setGradientType: var withValue: val withMax: ma withMin: mi];
  }
}

- (void) dealloc
{
  [min release];
  [max release];
  [super dealloc];
}

- (void) setGradientType: (NSString *) type withValue: (double) val
                withMax: (double) ma withMin: (double) mi
{
  [calculatedValues setObject: [NSNumber numberWithDouble: val]
       forKey: type];
  [min setObject: [NSNumber numberWithDouble: mi]
    forKey: type];
  [max setObject: [NSNumber numberWithDouble: ma]
    forKey: type];
}

- (NSDictionary *) min
{
  return min;
}

- (NSDictionary *) max
{
  return max;
}

- (void) refreshWithinRect: (NSRect) rect
{
  //calculate bb based on number of gradients
  //knowing that each gradient is a small square
  bb = rect;
}

- (BOOL) draw
{
  int count = [calculatedValues count];
  NSEnumerator *en = [calculatedValues keyEnumerator];
  NSString *type;
  double accum_y = 0;
  while ((type = [en nextObject])){
    double value = [[calculatedValues objectForKey: type] doubleValue];
    double mi = [[min objectForKey: type] doubleValue];
    double ma = [[max objectForKey: type] doubleValue];
    double saturation = (value - mi) / (ma - mi);

    NSColor *color;
    color = [filter colorForEntityType:
        [filter entityTypeWithName: type]];
    color = [filter getColor: color withSaturation: saturation];
    [color set];

    NSRect vr;
    vr.size.width = bb.size.width;
    vr.size.height = bb.size.height * 1/count;
    vr.origin.x = bb.origin.x;
    vr.origin.y = bb.origin.y + accum_y;

    NSRectFill(vr);
    [NSBezierPath strokeRect: vr];

    [[NSColor blackColor] set];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint: NSMakePoint (vr.origin.x,
                                                vr.origin.y + vr.size.height * (1 - saturation))];
    [path lineToPoint: NSMakePoint (vr.origin.x + vr.size.width,
                                                vr.origin.y + vr.size.height * (1 - saturation))];
    [path stroke];

    accum_y += vr.size.height;
  }
  return YES;
}
@end
