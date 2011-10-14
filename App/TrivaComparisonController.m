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
#include "TrivaComparisonController.h"

@implementation TrivaComparisonController
- (id) initWithConfiguration: (TrivaConfiguration *) configuration
{
  self = [super initWithConfiguration: configuration];

  graphSequences = [[NSMutableArray alloc] init];

  int input_size = [[configuration inputFiles] count], i = 0;
  NSArray *g = nil;
  TrivaVisualizationComponent comp = [configuration visualizationComponent];
  if (comp&TrivaSquarifiedTreemap){
    g = [@"(  \
      ( FileReader, \
         PajeEventDecoder, \
         PajeSimulator, \
         StorageController, \
         TimeSync, \
         TypeFilter, \
         TimeIntegration, \
         SpatialIntegration, \
         SquarifiedTreemap \
      ) )" propertyList];
  }else if (comp&TrivaGraphView){
    g = [@"(  \
      ( FileReader, \
         PajeEventDecoder, \
         PajeSimulator, \
         StorageController, \
         TypeFilter, \
         TimeSync, \
         TimeIntegration, \
         SpatialIntegration, \
         GraphConfiguration, \
         GraphView \
      ) )" propertyList];
  }else{
   g = [@"(  \
      ( FileReader, \
         PajeEventDecoder, \
         PajeSimulator, \
         StorageController, \
         TimeSync, \
      ) )" propertyList];
  }

  //loading bundles and creating graph sequences
  for (i = 0; i < input_size; i++){ 
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    [self addComponentSequences: g withDictionary: d];
    [graphSequences addObject: d];
    [d release];
  }

  //create the TimeSyncController
  Class compareControllerClass = NSClassFromString(@"TimeSyncController");
  if (compareControllerClass == nil){
    return nil;
  }
  compareController = [[compareControllerClass alloc] init];

  //create graph sequences (the number of files to be compared)
  NSMutableArray *compareFilters = [NSMutableArray array];
  for (i = 0; i < input_size; i++){ 
    NSMutableDictionary *d;
    d = [graphSequences objectAtIndex: i];
    
    //set the TimeSync filters' controller
    SEL method = @selector(setTimeSyncController:);
    [[d objectForKey: @"TimeSync"] performSelector: method withObject: compareController];
    method = @selector(show:);
    [[d objectForKey: @"TypeFilter"] performSelector: method withObject: self];
    [[d objectForKey: @"GraphView"] performSelector: method withObject: self];
    [[d objectForKey: @"GraphConfiguration"] performSelector: method withObject: self];

    //add the compare filters to the controller
    [compareFilters addObject: [d objectForKey: @"TimeSync"]];
  }
  SEL method = @selector(addFilters:);
  [compareController performSelector: method withObject: compareFilters];

  [self initializeWithConfiguration: configuration];
  return self;
}

- (void) initializeWithConfiguration: (TrivaConfiguration *) configuration
{
  //disabling single-file attributes
  reader = nil;
  encapsulator = nil;

  NSArray *files = [configuration inputFiles];
  int i;

  //reading the files
  for (i = 0; i < [files count]; i++){
    id graph = [graphSequences objectAtIndex: i];
    id r0 = [self componentWithName:@"FileReader" fromDictionary: graph];
    [r0 setInputFilename: [files objectAtIndex: i]];
    [self readAllTracefileFrom: r0];

    id s0 = [self componentWithName:@"StorageController"
                     fromDictionary: graph];
    [s0 setSelectionStartTime: [s0 startTime]
                      endTime: [s0 endTime]];
  }

  //check if trace files are good to go
  SEL method = @selector(check);
  [compareController performSelector: method withObject: nil];

  //configure the filters that are from Triva
  for (i = 0; i < [files count]; i++){
    id graph = [graphSequences objectAtIndex: i];
    NSEnumerator *en = [graph objectEnumerator];
    id component;
    while ((component = [en nextObject])){
      if ([component isKindOfClass: [TrivaFilter class]]){
        [component setConfiguration: configuration];
      }
    }
  }
}

- (void) dealloc
{
  [graphSequences release];
  [super dealloc];
}
@end
