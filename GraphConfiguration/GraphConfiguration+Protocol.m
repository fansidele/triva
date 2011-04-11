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

- (NSDictionary *) graphConfiguration
{
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];
  [ret addEntriesFromDictionary: currentGraphConfiguration];
  [ret removeObjectForKey: @"node"];
  [ret removeObjectForKey: @"edge"];
  return ret;
}

- (NSArray*) entityTypesForNodes
{
  return [currentGraphConfiguration objectForKey: @"node"];
}

- (NSArray*) entityTypesForEdges
{
  return [currentGraphConfiguration objectForKey: @"edge"];
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

- (BOOL) hasGraphvizLocationFromFile
{
  if (graph) return YES;
  return NO;
}

- (NSPoint) graphvizLocationForName: (NSString *)name
{
  Agnode_t *node = agfindnode (graph, (char*)[name cString]);
  NSPoint ret = NSZeroPoint;
  if (node != NULL){
    const char *s = agget(node, "pos");
    if (s == NULL) return ret;

    NSString *str = [NSString stringWithFormat: @"%s", s];
    NSArray *ar = [str componentsSeparatedByString: @","];
    if ([ar count] != 2) return ret;
    ret = NSMakePoint ([[ar objectAtIndex: 0] doubleValue],
                       [[ar objectAtIndex: 1] doubleValue]);
  }
  return ret;
}

- (NSSize) graphvizSize
{
  NSSize ret = NSZeroSize;
  char *s = agget (graph, "bb");
  if (s == NULL) return ret;
  NSArray *ar;
  ar = [[NSString stringWithFormat: @"%s", s] componentsSeparatedByString: @","];
  if ([ar count] != 4) return ret;
  ret = NSMakeSize ([[ar objectAtIndex: 2] doubleValue],
                    [[ar objectAtIndex: 3] doubleValue]);
  return ret;
}
@end
