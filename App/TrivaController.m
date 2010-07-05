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
#include "config.h"

@implementation TrivaController
- (id) init
{
  self = [super init];
  components = [NSMutableDictionary dictionary];
  bundles = [NSMutableDictionary dictionary];

  chunkDates = [[NSClassFromString(@"PSortedArray") alloc]
                                initWithSelector:@selector(self)];

  NSNotificationCenter *notificationCenter;
  notificationCenter = [NSNotificationCenter defaultCenter];

  [notificationCenter addObserver:self
    selector:@selector(chunkFault:)
    name:@"PajeChunkNotInMemoryNotification"
    object:nil];

  return self;
}

+ (NSArray *)treemapComponentGraph
{
  return [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       TimeInterval, \
       TypeFilter, \
       TimeSliceAggregation, \
       SquarifiedTreemap \
    ) )" propertyList];
}

+ (NSArray *)graphComponentGraph
{
  return [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       TimeInterval, \
       TimeSliceAggregation, \
       GraphConfiguration, \
       GraphView \
    ) )" propertyList];
}

+ (NSArray *)linkViewComponentGraph
{
  return [@"(  \
    ( FileReader, \
      PajeEventDecoder, \
      PajeSimulator, \
      StorageController, \
      TimeInterval, \
      TimeSliceAggregation, \
      LinkView \
    ) )" propertyList];
}

+ (NSArray *)dotComponentGraph
{
  return [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       TimeInterval, \
       Dot \
    ) )" propertyList];
}

+ (NSArray *)checkTraceComponentGraph
{
  return [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       CheckTrace \
    ) )" propertyList];
}

+ (NSArray *)listComponentGraph
{
  return [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       List \
    ) )" propertyList];
}

+ (NSArray *)instancesComponentGraph
{
  return [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       Instances \
    ) )" propertyList];
}

- (void) activateTreemap
{
  [self addComponentSequences:[[self class] treemapComponentGraph]];
  [self defineMajorComponents];
}

- (void) activateGraph
{
  [self addComponentSequences:[[self class] graphComponentGraph]];
  [self defineMajorComponents];
}

- (void) activateLinkView
{
  [self addComponentSequences:[[self class] linkViewComponentGraph]];
  [self defineMajorComponents];
}

- (void) activateDot
{
  [self addComponentSequences:[[self class] dotComponentGraph]];
  [self defineMajorComponents];
}

- (void) activateCheckTrace
{
  [self addComponentSequences:[[self class] checkTraceComponentGraph]];
  [self defineMajorComponents];
}

- (void) activateList
{
  [self addComponentSequences:[[self class] listComponentGraph]];
  [self defineMajorComponents];
}

- (void) activateInstances
{
  [self addComponentSequences:[[self class] instancesComponentGraph]];
  [self defineMajorComponents];
}

- (void) defineMajorComponents
{
  reader = [self componentWithName:@"FileReader"];
  simulator = [self componentWithName:@"PajeSimulator"];
  encapsulator = [self componentWithName:@"StorageController"];
}
@end
