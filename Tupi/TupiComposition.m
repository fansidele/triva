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
#include "TupiComposition.h"
#include "TupiSeparation.h"

@implementation TupiComposition
+ (id) compositionWithConfiguration: (NSDictionary*) conf
                           withName: (NSString*) n
                         withValues: (NSDictionary*) values
                         withColors: (NSDictionary*) col
                           withNode: (Tupi*) obj;
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
    return [[TupiSeparation alloc] initWithConfiguration: conf
                                                withName: n
                                              withValues: values
                                              withColors: col
                                                withNode: obj];
//  }else if ([type isEqualToString: @"gradient"]){
//    return [[TupiGradient alloc] initWithConfiguration: conf
//                                               withName: n
//                                              forObject: obj
//                                        withDifferences: differences
//                                             withValues: timeSliceValues
//                                            andProvider: prov];
//  }else if ([type isEqualToString: @"convergence"]){
//    return [[TupiConvergence alloc] initWithConfiguration: conf
//                                                  withName: n
//                                                 forObject: obj
//                                           withDifferences: differences
//                                                withValues: timeSliceValues
//                                               andProvider: prov];
//  }else if ([type isEqualToString: @"color"]){
//    return [[TupiColor alloc] initWithConfiguration: conf
//                                            withName: n
//                                           forObject: obj
//                                     withDifferences: differences
//                                          withValues: timeSliceValues
//                                         andProvider: prov];
//  }else if ([type isEqualToString: @"swarm"]){
//    return [[TupiSwarm alloc] initWithConfiguration: conf
//                                            withName: n
//                                           forObject: obj
//                                     withDifferences: differences
//                                          withValues: timeSliceValues
//                                         andProvider: prov];
//  }else if ([type isEqualToString: @"plot"]){
//    return [[TupiPlot alloc] initWithConfiguration: conf
//                                            withName: n
//                                           forObject: obj
//                                     withDifferences: differences
//                                          withValues: timeSliceValues
//                                         andProvider: prov];
//  }else if ([type isEqualToString: @"fft"]){
//    return [[TupiFFT alloc] initWithConfiguration: conf
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
                    withNode: (Tupi*) obj;
{
  self = [super init];
  configuration = conf;
  name = n;
  node = obj;
  return self;
}

- (void) layoutWithValues: (NSDictionary*) timeSliceValues
{
  //must be implemented in the subclasses
  NSLog (@"%s:%d: this method must be implemented in the subclasses",
                        __FUNCTION__, __LINE__);
  return NO;
}

- (void) layoutWithRect: (NSRect) rect
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
  return NO;
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

- (BOOL) mouseInside: (NSPoint)mPoint
       withTransform: (NSAffineTransform*)transform
{
  //must be implemented in the subclasses
  NSLog (@"%s:%d: this method must be implemented in the subclasses",
                        __FUNCTION__, __LINE__);
  return NO;
}
@end
