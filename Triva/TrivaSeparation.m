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
- (id) initWithConfiguration: (NSDictionary*) conf
                        name: (NSString*) n
                      values: (NSDictionary*) val
                        node: (TrivaGraph*) obj
                      filter: (TrivaFilter*) f
{
  self = [super initWithConfiguration: conf
                                 name: n
                               values: val
                                 node: obj
                               filter: f];
  //get size
  size = [configuration objectForKey: @"size"];
  if (!size){
    NSLog (@"%s:%d: no 'size' configuration for composition %@",
                        __FUNCTION__, __LINE__, configuration);
    return nil;
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
  //get threshold
  NSString *thre = [configuration objectForKey: @"threshold"];
  if (thre){
    threshold = [thre doubleValue];
  }else{
    threshold = -1;
  }

  //get direction
  NSString *dir = [configuration objectForKey: @"direction"];
  if (dir){
    direction = YES;
  }

  calculatedValues = [[NSMutableDictionary alloc] init];
  return self;
}

- (void) dealloc
{
  [calculatedValues release];
  [super dealloc];
}

- (void) timeSelectionChanged
{
  NSDictionary *timeSliceValues = [node values];

  //clear calculatedValues
  [calculatedValues removeAllObjects];

  //we need the size
  sepSize = [node evaluateWithValues: timeSliceValues withExpr: size];

  //get values
  NSEnumerator *en2 = [values objectEnumerator];
  id var;
  double sum = 0;
  while ((var = [en2 nextObject])){
    double val = [node evaluateWithValues: timeSliceValues withExpr: var];
    if (val > 0){
      [calculatedValues setObject: [NSNumber numberWithDouble: val/sepSize]
          forKey: var];
    }
    sum += val/sepSize;
  }
  overflow = sum - 1;

//  if ([calculatedValues count] == 0){
//    needSpace = NO;
//  }else{
//    needSpace = YES;
//  }

//  if (threshold < 0){
//    return NO;
//  }
//
//  if (sum > threshold) {
//    return YES;
//  }else{
//    return NO;
//  }
}

- (void) setBoundingBox: (NSRect) rect
{
  bb = rect;
}

- (void) drawLayout
{
  NSEnumerator *en = [calculatedValues keyEnumerator];
  NSString *type;
  double accum_y = 0;
  NSMutableString *str = [NSMutableString string];

  while ((type = [en nextObject])){
    [[filter colorForIntegratedValueNamed: type] set];
    double value = [[calculatedValues objectForKey: type] doubleValue];

    NSRect vr;
    vr.size.width = bb.size.width;
    vr.size.height = bb.size.height * value;
    vr.origin.x = bb.origin.x;
    vr.origin.y = bb.origin.y + accum_y;

    NSBezierPath *path = [NSBezierPath bezierPath];
    if (direction){ 
      [path moveToPoint: NSMakePoint (bb.origin.x, bb.origin.y + accum_y)];
      [path relativeLineToPoint: NSMakePoint (0, bb.size.height*value)];
      [path relativeLineToPoint: NSMakePoint (bb.size.width-10, 0)];
      [path relativeLineToPoint: NSMakePoint (10, -(bb.size.height*value/2))];
      [path relativeLineToPoint: NSMakePoint (-10, -(bb.size.height*value/2))];
      [path relativeLineToPoint: NSMakePoint (-bb.size.width+10, 0)];
    }else{
      [path appendBezierPathWithRect: vr];
    }
    [path fill];
//    if ([selectedType isEqualToString: type]){
//      [[NSColor blackColor] set];
//    }
    if ([self highlight]){
      [str appendString: [NSString stringWithFormat: @"%@ - %f (%.2f%%)\n",
                                  type, value*sepSize, 100*value]];
      [type drawAtPoint: bb.origin withAttributes: nil];
    }
    [path stroke];
    accum_y += vr.size.height;
  }
  if ([self highlight]){
    [str drawAtPoint: bb.origin withAttributes: nil];
  }
}

- (NSRect) bb
{
  return bb;
}

- (NSString *) description
{
return name;
  NSMutableString *ret = [NSMutableString string];

//  if (selectedType){
//    double value;
//    value = [[calculatedValues objectForKey: selectedType] doubleValue];
//    [ret appendString: [NSString stringWithFormat: @"%@ = %f (%.2f%%)\n",
//                  selectedType, value*sepSize*[[diffForComparison objectForKey: selectedType] doubleValue], value*100]];
//    return ret;
//  }
//
//  NSEnumerator *en = [calculatedValues keyEnumerator];
//  NSString *type;
//  while ((type = [en nextObject])){
//    double value = [[calculatedValues objectForKey: type] doubleValue];
//    [ret appendString: [NSString stringWithFormat: @"%@ = %f (%.2f%%)\n", type,
//                             value*sepSize*[[diffForComparison objectForKey: selectedType] doubleValue], value*100]]; //value is always between 0 and 1 here
//  }
  return ret;
}

- (BOOL) pointInside: (NSPoint)mPoint
{
  hitPoint = mPoint;
  return NSPointInRect(hitPoint, bb);
}
@end
