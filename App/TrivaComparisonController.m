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

  graphSequences = [NSMutableArray array];

  int input_size = [[configuration inputFiles] count], i = 0;
  NSArray *g = nil;
  if ([configuration visualizationComponent] == TrivaSquarifiedTreemap){
    g = [@"(  \
      ( FileReader, \
         PajeEventDecoder, \
         PajeSimulator, \
         StorageController, \
         TimeSync, \
         TypeFilter, \
         TimeIntegration, \
         SquarifiedTreemap \
      ) )" propertyList];
  }else if ([configuration visualizationComponent] == TrivaGraphView){
    g = [@"(  \
      ( FileReader, \
         PajeEventDecoder, \
         PajeSimulator, \
         StorageController, \
         TimeSync, \
         TimeIntegration, \
         GraphConfiguration, \
         GraphView \
      ) )" propertyList];
  }else{
    NSException *exception = [NSException exceptionWithName: @"TrivaException"
                   reason: @"No visualization option activated for comparing" userInfo: nil];
    [exception raise];
  }

  //loading bundles and creating graph sequences
  for (i = 0; i < input_size; i++){ 
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [self addComponentSequences: g withDictionary: d];
    [graphSequences addObject: d];
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
    SEL method = @selector(setController:);
    [[d objectForKey: @"TimeSync"] performSelector: method withObject: compareController];

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
    id r = [self componentWithName:@"FileReader" fromDictionary: graph];
    id storage = [self componentWithName:@"StorageController" fromDictionary: graph];

    [r setInputFilename: [files objectAtIndex: i]];
    [self readAllTracefileFrom: r];
    [storage timeLimitsChanged];

  }

  //check if trace files are good to go
  SEL method = @selector(check);
  [compareController performSelector: method withObject: nil];

  [self setSelectionWindow];
}

- (void)setSelectionWindow
{
  NSEnumerator *en = [graphSequences objectEnumerator];
  id graph;
  while ((graph = [en nextObject])){
    id storage = [self componentWithName:@"StorageController" fromDictionary: graph];
    [storage setSelectionStartTime: [storage startTime]
                          endTime: [storage endTime]];
  }
}
@end
