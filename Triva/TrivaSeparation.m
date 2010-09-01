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
#include "TrivaSeparation.h"

@implementation TrivaSeparation
- (id) initWithFilter: (TrivaFilter *) f
     andConfiguration: (NSDictionary *) conf
             andSpace: (BOOL) s
              andName: (NSString*)n
            andObject: (TrivaGraphNode*)obj
{
  self = [super initWithFilter: f andConfiguration: conf
                      andSpace: s andName: n andObject: obj];
  overflow = 0;
  direction = NO;
  calculatedValues = [[NSMutableDictionary alloc] init];
  size = nil;
  values = nil;
  diffForComparison = nil;
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

  //get size
  size = [configuration objectForKey: @"size"];
  if (!size){
    NSLog (@"%s:%d: no 'size' configuration for composition %@",
                        __FUNCTION__, __LINE__, configuration);
    return nil;
  }

  //check for differences
  if (differences){
    id value = [differences objectForKey: size];
    if (value){
      if ([value doubleValue] != 0){
        NSLog (@"%s:%d: 'size' configuration for composition %@ has "
                "different values during comparison",
                        __FUNCTION__, __LINE__, configuration);
        return nil;
      }
    }
    //saving differences
    diffForComparison = differences;
    [diffForComparison retain];
  }

  //get values
  values = [configuration objectForKey: @"values"];
  if (!values){
    NSLog (@"%s:%d: no 'values' configuration for composition %@",
                        __FUNCTION__, __LINE__, configuration);
    return nil;
  }else{
    if (![values isKindOfClass: [NSArray class]]){
      NSLog (@"%s:%d: 'value' is invalid (%@). "
              " It should be something like (var,var2)",
               __FUNCTION__, __LINE__, values);
      return nil;
    }
  }

  //get direction
  NSString *dir = [configuration objectForKey: @"direction"];
  if (dir){
    direction = YES;
  }
  [self redefineLayoutWithValues: timeSliceValues];
  return self;
}

- (void) redefineLayoutWithValues: (NSDictionary*) timeSliceValues
{
  //clear calculatedValues
  [calculatedValues removeAllObjects];

  //we need the size
  double s = [filter evaluateWithValues: timeSliceValues withExpr: size];

  //get values
  NSEnumerator *en2 = [values objectEnumerator];
  id var;
  double sum = 0;
  while ((var = [en2 nextObject])){
    double val = [filter evaluateWithValues: timeSliceValues withExpr: var];
    if (val > 0){
      [calculatedValues setObject: [NSNumber numberWithDouble: val/s]
          forKey: var];
    }
    sum += val/s;
  }
  overflow = sum - 1;

  if ([calculatedValues count] == 0){
    needSpace = NO;
  }else{
    needSpace = YES;
  }
}

- (void) dealloc
{
  [calculatedValues release];
  [diffForComparison release];
  [super dealloc];
}

- (void) refreshWithinRect: (NSRect) rect
{
  bb = rect;
}

- (BOOL) draw
{
  NSEnumerator *en = [calculatedValues keyEnumerator];
  NSString *type;
  double accum_y = 0;

  NSMutableString *str = [NSMutableString string];

  while ((type = [en nextObject])){
    double value = [[calculatedValues objectForKey: type] doubleValue];

    if (!diffForComparison){
      [[filter colorForEntityType:
        [filter entityTypeWithName: type]] set];
    }else{
      //defining color based on the differences
      NSColor *color = [filter colorForEntityType:
                          [filter entityTypeWithName: type]];
      //get difference for type
      double val = [[diffForComparison objectForKey: type] doubleValue];
      float h, s, b, a;
      [color getHue:&h saturation:&s brightness:&b alpha:&a];
      if (val > 0){
        [[NSColor colorWithCalibratedHue:h saturation: 1 brightness: b alpha:a] set];
      }else if (val < 0){
        [[NSColor colorWithCalibratedHue:h saturation: .5 brightness: b alpha:a] set];
      }else{
        //this should not happen, because its size will be equal to 0
      }
    }

    NSRect vr;
    vr.size.width = bb.size.width;
    vr.size.height = bb.size.height * value;
    vr.origin.x = bb.origin.x;
    vr.origin.y = bb.origin.y + accum_y;

    if (direction){ 
      NSBezierPath *path = [NSBezierPath bezierPath];
      [path moveToPoint: NSMakePoint (bb.origin.x, bb.origin.y + accum_y)];
      [path relativeLineToPoint: NSMakePoint (0, bb.size.height*value)];
      [path relativeLineToPoint: NSMakePoint (bb.size.width-10, 0)];
      [path relativeLineToPoint: NSMakePoint (10, -(bb.size.height*value/2))];
      [path relativeLineToPoint: NSMakePoint (-10, -(bb.size.height*value/2))];
      [path relativeLineToPoint: NSMakePoint (-bb.size.width+10, 0)];
      [path stroke];
      [path fill];
    }else{
      NSRectFill(vr);
      [NSBezierPath strokeRect: vr];
    }
    [str appendString: [NSString stringWithFormat: @"%@ = %g\n", type,
                             value*100]]; //value is always between 0 and 1 here
    accum_y += vr.size.height;
  }

  if ([node highlighted]){
    NSMutableDictionary *attr = [[NSMutableDictionary alloc] init];
    [attr setValue:[NSFont userFontOfSize: 10] forKey: NSFontAttributeName];
    [str drawAtPoint: NSAddPoints ([node bb].origin,
                                   NSMakePoint([node bb].size.width,
                                               [node bb].size.height))
      withAttributes: attr];
    [attr release];
  }

  return YES;
}

- (NSRect) bb
{
  return bb;
}

- (NSString *) description
{
  NSMutableString *ret = [NSMutableString string];
  NSEnumerator *en = [calculatedValues keyEnumerator];
  NSString *type;
  while ((type = [en nextObject])){
    double value = [[calculatedValues objectForKey: type] doubleValue];
    [ret appendString: [NSString stringWithFormat: @"%@ = %g\n", type,
                             value*100]]; //value is always between 0 and 1 here
  }
  return ret;
}
@end
