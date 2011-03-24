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
#include "TrivaComposition.h"
#include "TrivaSeparation.h"

@implementation TrivaComposition
+ (id) compositionWithConfiguration: (NSDictionary*) conf
                           withName: (NSString*) n
                         withValues: (NSDictionary*) values
                         withColors: (NSDictionary*) col
                           withNode: (TrivaGraph*) obj;
{
  if (![conf isKindOfClass: [NSDictionary class]]) {
    NSLog (@"%s:%d: configuration %@ is not a dictionary",
                        __FUNCTION__, __LINE__, conf);
    return nil;
  }

  if (![conf count]) {
    NSLog (@"%s:%d: configuration %@ is empty",
                        __FUNCTION__, __LINE__, conf);
    return nil;
  }

  NSString *type = [conf objectForKey: @"type"];
  if (!type){
    NSLog (@"%s:%d: configuration %@ has no type",
                        __FUNCTION__, __LINE__, conf);
    return nil;
  }

  if ([type isEqualToString: @"separation"]){
    return [[TrivaSeparation alloc] initWithConfiguration: conf
                                                withName: n
                                              withValues: values
                                              withColors: col
                                                withNode: obj];
//  }else if ([type isEqualToString: @"gradient"]){
//    return [[TrivaGradient alloc] initWithConfiguration: conf
//                                               withName: n
//                                              forObject: obj
//                                        withDifferences: differences
//                                             withValues: timeSliceValues
//                                            andProvider: prov];
//  }else if ([type isEqualToString: @"convergence"]){
//    return [[TrivaConvergence alloc] initWithConfiguration: conf
//                                                  withName: n
//                                                 forObject: obj
//                                           withDifferences: differences
//                                                withValues: timeSliceValues
//                                               andProvider: prov];
//  }else if ([type isEqualToString: @"color"]){
//    return [[TrivaColor alloc] initWithConfiguration: conf
//                                            withName: n
//                                           forObject: obj
//                                     withDifferences: differences
//                                          withValues: timeSliceValues
//                                         andProvider: prov];
//  }else if ([type isEqualToString: @"swarm"]){
//    return [[TrivaSwarm alloc] initWithConfiguration: conf
//                                            withName: n
//                                           forObject: obj
//                                     withDifferences: differences
//                                          withValues: timeSliceValues
//                                         andProvider: prov];
//  }else if ([type isEqualToString: @"plot"]){
//    return [[TrivaPlot alloc] initWithConfiguration: conf
//                                            withName: n
//                                           forObject: obj
//                                     withDifferences: differences
//                                          withValues: timeSliceValues
//                                         andProvider: prov];
//  }else if ([type isEqualToString: @"fft"]){
//    return [[TrivaFFT alloc] initWithConfiguration: conf
//                                            withName: n
//                                           forObject: obj
//                                     withDifferences: differences
//                                          withValues: timeSliceValues
//                                         andProvider: prov];
  }else{
    NSLog (@"%s:%d: type '%@' of configuration %@ is unknown",
                        __FUNCTION__, __LINE__, type, conf);
    return nil;
  }
}

- (id) initWithConfiguration: (NSDictionary*) conf
                    withName: (NSString*) n
                  withValues: (NSDictionary*) values
                  withColors: (NSDictionary*) col
                    withNode: (TrivaGraph*) obj;
{
  self = [super init];
  configuration = conf;
  name = n;
  node = obj;
  return self;
}

- (void) timeSelectionChanged
{
  //must be implemented in the subclasses
  NSLog (@"%s:%d: this method must be implemented in the subclasses",
                        __FUNCTION__, __LINE__);
}

- (void) setBoundingBox: (NSRect) rect
{
  //must be implemented in the subclasses
  NSLog (@"%s:%d: this method must be implemented in the subclasses",
                        __FUNCTION__, __LINE__);
}

- (void) drawLayout
{
  //must be implemented in the subclasses
  NSLog (@"%s:%d: this method must be implemented in the subclasses",
                        __FUNCTION__, __LINE__);
}

- (void) setHighlight: (BOOL) v
{
  highlight = v;
}

- (BOOL) highlight
{
  return highlight;
}

- (BOOL) needSpace
{
  return needSpace;
}

- (NSRect) bb
{
  return bb;
}

- (NSString*) name
{
  return name;
}

- (NSString*) description
{
  return [NSString stringWithFormat: @"[%@ %@]", [node name], name];
}

- (BOOL) pointInside: (NSPoint)mPoint
{
  //must be implemented in the subclasses
  NSLog (@"%s:%d: this method must be implemented in the subclasses",
                        __FUNCTION__, __LINE__);
  return NO;
}
@end
