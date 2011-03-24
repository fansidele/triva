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
/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "GraphConfiguration.h"

@implementation GraphConfiguration (Protocol)
/*
- (id) currentTupiManager
{
  return manager;
}
*/

- (NSColor *) getColor: (NSColor *)c withSaturation: (double) saturation
{
  if (![[c colorSpaceName] isEqualToString:
      @"NSCalibratedRGBColorSpace"]){
    NSLog (@"%s:%d Color provided is not part of the "
        "RGB color space.", __FUNCTION__, __LINE__);
    return nil;
  }
  float h, s, b, a;
  [c getHue: &h saturation: &s brightness: &b alpha: &a];
  NSColor *ret = [NSColor colorWithCalibratedHue: h
    saturation: saturation
    brightness: b
    alpha: a];
  return ret;
}

- (NSDictionary *) graphConfigurationForContainerType:(PajeEntityType*) type
{
  return [currentGraphConfiguration objectForKey: [type description]];
}

- (NSDictionary *) minValuesForContainerType:(PajeEntityType*) type
{
  //check if this is a container type
  if (![self isContainerEntityType: type]){
    return nil;
  }

  //check if we have cached values, calculate if not, return result
  NSDictionary *ret = nil;
  while (!(ret = [minValues objectForKey: type])){
    [self updateMinMaxColorForContainerType: type];
    ret = [minValues objectForKey: type];
  }
  return ret;
}

- (NSDictionary *) maxValuesForContainerType:(PajeEntityType*) type
{
  //check if this is a container type
  if (![self isContainerEntityType: type]){
    return nil;
  }

  //check if we have cached values, calculate if not, return result
  NSDictionary *ret = nil;
  while (!(ret = [maxValues objectForKey: type])){
    [self updateMinMaxColorForContainerType: type];
    ret = [maxValues objectForKey: type];
  }
  return ret;
}
@end
