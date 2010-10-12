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
#include "TrivaController.h"
#include "TrivaCommand.h"

@implementation TrivaController
+ (id) controllerWithArguments: (struct arguments) arguments
{
  TrivaController *triva = nil;
  //configuring triva
  if (arguments.comparison){
    triva = [[TrivaComparisonController alloc] initWithArguments: arguments];
  }else if (arguments.merge){
    triva = [[TrivaMergeController alloc] initWithArguments: arguments];
  }else{
    if (arguments.treemap) {
      triva = [[TrivaTreemapController alloc] initWithArguments: arguments];
    }else if (arguments.graph){
      triva = [[TrivaGraphController alloc] initWithArguments: arguments];
    }else if (arguments.linkview){
      triva = [[TrivaLinkController alloc] initWithArguments: arguments];
    }else if (arguments.hierarchy) {
      triva = [[TrivaDotController alloc] initWithArguments: arguments];
    }else if (arguments.stat) {
      triva = [[TrivaStatController alloc] initWithArguments: arguments];
    }else if (arguments.check) {
      triva = [[TrivaCheckController alloc] initWithArguments: arguments];
    }else if (arguments.list) {
      triva = [[TrivaListController alloc] initWithArguments: arguments];
    }else if (arguments.instances) {
      triva = [[TrivaInstanceController alloc] initWithArguments: arguments];
    }else{
      NSException *exception = [NSException exceptionWithName: @"TrivaException"
                     reason: @"No visualization option activated" userInfo: nil];
      [exception raise];
    }
  }
  return triva;
}

- (id) initWithArguments: (struct arguments) arguments
{
  self = [super init];
  components = [NSMutableDictionary dictionary];
  bundles = [NSMutableDictionary dictionary];
  return self;
}

- (void) initializeWithArguments: (struct arguments) arguments
{
  int i;
  NSMutableArray *files = [NSMutableArray array];
  for (i = 0; i < arguments.input_size; i++){
    [files addObject: [NSString stringWithFormat: @"%s", arguments.input[i]]];
  }
  NSLog (@"Tracefile (%@). Reading.... please wait\n", files);

  //reading only the first file by default (subclasses
  //should override this if necessary)
  reader = [self componentWithName:@"FileReader" fromDictionary: components];
  [reader setInputFilename: [files objectAtIndex: 0]];
  [self readAllTracefileFrom: reader];
  encapsulator = [self componentWithName:@"StorageController" fromDictionary: components];
  [encapsulator timeLimitsChanged];
  [encapsulator setSelectionStartTime: [encapsulator startTime]
                              endTime: [encapsulator endTime]];
}
@end

@implementation TrivaTreemapController
- (id) initWithArguments: (struct arguments) arguments
{
  self = [super initWithArguments: arguments];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       TimeInterval, \
       TypeFilter, \
       TimeSliceAggregation, \
       SquarifiedTreemap \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithArguments: arguments];
  return self;
}
@end

@implementation TrivaGraphController
- (id) initWithArguments: (struct arguments) arguments
{
  self = [super initWithArguments: arguments];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       TimeInterval, \
       TimeSliceAggregation, \
       GraphConfiguration, \
       GraphView \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithArguments: arguments];
  return self;
}
@end

@implementation TrivaLinkController
- (id) initWithArguments: (struct arguments) arguments
{
  self = [super initWithArguments: arguments];
  NSArray *graph = [@"(  \
    ( FileReader, \
      PajeEventDecoder, \
      PajeSimulator, \
      StorageController, \
      TimeInterval, \
      TimeSliceAggregation, \
      LinkView \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithArguments: arguments];
  return self;
}
@end

@implementation TrivaDotController
- (id) initWithArguments: (struct arguments) arguments
{
  self = [super initWithArguments: arguments];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       Dot \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithArguments: arguments];
  return self;
}
@end

@implementation TrivaCheckController
- (id) initWithArguments: (struct arguments) arguments
{
  self = [super initWithArguments: arguments];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       CheckTrace \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithArguments: arguments];
  return self;
}
@end

@implementation TrivaListController
- (id) initWithArguments: (struct arguments) arguments
{
  self = [super initWithArguments: arguments];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       List \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithArguments: arguments];
  return self;
}
@end

@implementation TrivaInstanceController
- (id) initWithArguments: (struct arguments) arguments
{
  self = [super initWithArguments: arguments];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       Instances \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithArguments: arguments];
  return self;
}
@end

@implementation TrivaStatController
- (id) initWithArguments: (struct arguments) arguments
{
  self = [super initWithArguments: arguments];
  NSArray *graph = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       StatTrace \
    ) )" propertyList];
  [self addComponentSequences: graph withDictionary: components];
  [self initializeWithArguments: arguments];
  return self;
}
@end
