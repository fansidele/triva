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
#include "TrivaMarker.h"

@implementation TrivaMarker
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

  //size configuration
  NSString *sizeConf = [configuration objectForKey: @"size"];
  if (!sizeConf){
    NSLog (@"%s:%d: no 'size' configuration for composition %@",
                        __FUNCTION__, __LINE__, configuration);
    return nil;
  }
  size = [sizeConf doubleValue];

  //get values
  NSArray *values = [configuration objectForKey: @"values"];
  if (!values){
    NSLog (@"%s:%d: no 'values' configuration for composition %@",
                        __FUNCTION__, __LINE__, configuration);
    return nil;
  }else{
    if (![values isKindOfClass: [NSArray class]]){
      NSLog (@"%s:%d: 'value' is invalid (%@). "
              " It should be something like (var)",
               __FUNCTION__, __LINE__, values);
      return nil;
    }else{
      if ([values count] > 1){
        NSLog (@"%s:%d: 'value' has more than one variable (%@). "
               " It should contain only one: (var)",
               __FUNCTION__, __LINE__, values);
        return nil;
      }
    }
  }
  variable = [values objectAtIndex: 0];
  if ([val objectForKey: variable] == nil){
    return nil;
  }
  double v = [[val objectForKey: variable] doubleValue];
  if (v == 0){
    return nil;
  }
  return self;
}

- (BOOL) redefineLayoutWithValues: (NSDictionary*) timeSliceValues
{
  return YES;
}

- (void) layout
{
  [self setBoundingBox: NSMakeRect(0, 0, size, size)];
}

- (void) setBoundingBox: (NSRect) rect
{
  bb = rect;
}

- (void) drawLayout
{
  NSBezierPath *path = [NSBezierPath bezierPathWithRect: bb];

  [[filter colorForIntegratedValueNamed: variable] set];
  [path fill];
  [[NSColor grayColor] set];
  [path stroke];
}

- (double) evaluateSize
{
  return size;
}
@end
