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
  values = [[NSMutableDictionary alloc] init];
  return self;
}

- (id) initWithConfiguration: (NSDictionary*) conf
                    withName: (NSString*) n
                   forObject: (TrivaGraphNode*)obj
                  withValues: (NSDictionary*) timeSliceValues
                 andProvider: (TrivaFilter*) prov
{
  self = [self initWithFilter: prov andConfiguration: conf
                     andSpace: YES andName: n andObject: obj];

/*
  //TODO: what 'scale' local or global means for separation?
  //get scale for this composition
  TrivaScale scale;
  NSString *scaleconf = [conf objectForKey: @"scale"];
  if ([scaleconf isEqualToString: @"global"]){
    scale = Global;
  }else if ([scaleconf isEqualToString: @"local"]){
    scale = Local;
  }else{
    scale = Global;
  }
*/
  NSString *sizeconf = [configuration objectForKey: @"size"];
  if (!sizeconf){
    NSLog (@"%s:%d: no 'size' configuration for composition %@",
                        __FUNCTION__, __LINE__, configuration);
    return nil;
  }

  [self redefineLayoutWithValues: timeSliceValues];
  return self;
}

- (void) redefineLayoutWithValues: (NSDictionary*) timeSliceValues
{
  //we need the size
  NSString *sizeconf = [configuration objectForKey: @"size"];
  double size = 0;
  size = [filter evaluateWithValues: timeSliceValues withExpr: sizeconf];
  if (size < 0){
    //size could not be defined
    NSLog (@"%s:%d: the value of 'size' for composition %@ is negative or "
      "could not be defined",
                        __FUNCTION__, __LINE__, configuration);
    return;
  }

  //get values
  NSEnumerator *en2 = [[configuration objectForKey: @"values"]objectEnumerator];
  id var;
  double sum = 0;
  while ((var = [en2 nextObject])){
    double val = [filter evaluateWithValues: timeSliceValues withExpr: var];
    if (val > 0){
      [values setObject: [NSNumber numberWithDouble: val/size]
          forKey: var];
    }
    sum += val;
  }
  if (sum > 1){
    overflow = sum - 1;
  }else{
    overflow = 0;
  }
  if ([values count] == 0){
    needSpace = NO;
  }
}

- (void) dealloc
{
  [values release];
  [super dealloc];
}

- (NSDictionary*) values
{
  return values;
}

- (double) overflow
{
  return overflow;
}

- (void) refreshWithinRect: (NSRect) rect
{
  bb = rect;
}

- (BOOL) draw
{
  NSEnumerator *en = [values keyEnumerator];
  NSString *type;
  double accum_y = 0;

  NSMutableString *str = [NSMutableString string];

  while ((type = [en nextObject])){
    double value = [[values objectForKey: type] doubleValue];

    [[filter colorForEntityType:
      [filter entityTypeWithName: type]] set];

    NSRect vr;
    vr.size.width = bb.size.width;
    vr.size.height = bb.size.height * value;
    vr.origin.x = bb.origin.x;
    vr.origin.y = bb.origin.y + accum_y;

    NSRectFill(vr);
    [NSBezierPath strokeRect: vr];

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
@end
