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
#include <Triva/TrivaSeparation.h>
#include <Triva/TrivaGradient.h>
#include <Triva/TrivaColor.h>
#include <Triva/TrivaConvergence.h>
#include <Triva/TrivaSwarm.h>
#include <Triva/TrivaPlot.h>
#include <Triva/TrivaFFT.h>

@implementation TrivaComposition
+ (id) compositionWithConfiguration: (NSDictionary*) conf
                           withName: (NSString*) n
                          forObject: (TrivaGraphNode*) obj
                         withValues: (NSDictionary*) timeSliceValues
                        andProvider: (TrivaFilter*) prov
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
                                                forObject: obj
                                               withValues: timeSliceValues
                                              andProvider: prov];
  }else if ([type isEqualToString: @"gradient"]){
    return [[TrivaGradient alloc] initWithConfiguration: conf
                                               withName: n
                                              forObject: obj
                                             withValues: timeSliceValues
                                            andProvider: prov];
  }else if ([type isEqualToString: @"convergence"]){
    return [[TrivaConvergence alloc] initWithConfiguration: conf
                                                  withName: n
                                                 forObject: obj
                                                withValues: timeSliceValues
                                               andProvider: prov];
  }else if ([type isEqualToString: @"color"]){
    return [[TrivaColor alloc] initWithConfiguration: conf
                                            withName: n
                                           forObject: obj
                                          withValues: timeSliceValues
                                         andProvider: prov];
  }else if ([type isEqualToString: @"swarm"]){
    return [[TrivaSwarm alloc] initWithConfiguration: conf
                                            withName: n
                                           forObject: obj
                                          withValues: timeSliceValues
                                         andProvider: prov];
  }else if ([type isEqualToString: @"plot"]){
    return [[TrivaPlot alloc] initWithConfiguration: conf
                                            withName: n
                                           forObject: obj
                                          withValues: timeSliceValues
                                         andProvider: prov];
  }else if ([type isEqualToString: @"fft"]){
    return [[TrivaFFT alloc] initWithConfiguration: conf
                                            withName: n
                                           forObject: obj
                                          withValues: timeSliceValues
                                         andProvider: prov];
  }else{
    NSLog (@"%s:%d: type '%@' of configuration %@ is unknown",
                        __FUNCTION__, __LINE__, type, conf);
    return nil;
  }
}

- (id) initWithConfiguration: (NSDictionary*) conf
                    withName: (NSString*) n
                   forObject: (TrivaGraphNode*)obj
                  withValues: (NSDictionary*) timeSliceValues
                 andProvider: (TrivaFilter*) prov
{
  //must be implemented in the subclasses
  NSLog (@"%s:%d: this method must be implemented in the subclasses",
                        __FUNCTION__, __LINE__);
  return nil;
}

- (id) initWithFilter: (TrivaFilter *) f
     andConfiguration: (NSDictionary *) conf
             andSpace: (BOOL) s
              andName: (NSString *) n
            andObject: (TrivaGraphNode *)obj
{
  self = [super init];
  configuration = conf;
  needSpace = s;
  filter = f;
  name = n;
  node = obj;
  return self;
}

- (void) redefineLayoutWithValues: (NSDictionary*) timeSliceValues
{
  //must be implemented in the subclasses
  NSLog (@"%s:%d: this method must be implemented in the subclasses",
                        __FUNCTION__, __LINE__);
}

- (BOOL) needSpace
{
  return needSpace;
}

- (void) refreshWithinRect: (NSRect) rect
{
  //must be implemented in the subclasses
  NSLog (@"%s:%d: this method must be implemented in the subclasses",
                        __FUNCTION__, __LINE__);
}

- (BOOL) draw
{
  //must be implemented in the subclasses
  NSLog (@"%s:%d: this method must be implemented in the subclasses",
                        __FUNCTION__, __LINE__);
  return NO;
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
@end
