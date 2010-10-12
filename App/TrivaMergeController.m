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
#include "TrivaMergeController.h"

@implementation TrivaMergeController
- (id) initWithArguments: (struct arguments) arguments
{
  self = [super initWithArguments: arguments];
  SEL method;

  graphSequences = [NSMutableArray array];

  int input_size = arguments.input_size, i = 0;
  NSArray *g = nil;
  g = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       TimeSync, \
       TimeSliceAggregation, \
       Difference \
    ) )" propertyList];

  //loading bundles and creating graph sequences
  for (i = 0; i < input_size; i++){ 
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [self addComponentSequences: g withDictionary: d];
    [graphSequences addObject: d];
  }

  //Step A: Create the TimeSyncController (responsible for time synchronization)
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
    method = @selector(setController:);
    [[d objectForKey: @"TimeSync"] performSelector: method withObject: compareController];

    //add the compare filters to the controller
    [compareFilters addObject: [d objectForKey: @"TimeSync"]];
  }
  method = @selector(addFilters:);
  [compareController performSelector: method withObject: compareFilters];

 
  //Step B: Create the Difference Controller (responsible for merging)
  Class difContrClass = NSClassFromString(@"DifferenceController");
  if (difContrClass == nil) return nil;
  differenceController = [[difContrClass alloc] initWithController: self];

  //set merge controller for all Intercept filters
  NSMutableArray *interceptFilters = [NSMutableArray array];
  for (i = 0; i < input_size; i++){ 
    NSMutableDictionary *d = [graphSequences objectAtIndex: i];
    id intercept = [d objectForKey: @"Difference"];

    method = @selector(setDifController:);
    [intercept performSelector: method withObject: differenceController];
    [interceptFilters addObject: intercept];
  }
  method = @selector(addFilters:);
  [differenceController performSelector: method withObject: interceptFilters];

  //Step C: Connect visualization components with the differenceController
  g = [@"(  \
    ( GraphConfiguration, \
      GraphView \
    ) )" propertyList];
  graphVisualization = [[NSMutableDictionary alloc] init];
  [self addComponentSequences: g withDictionary: graphVisualization];
  [self connectComponent: differenceController
             toComponent: 
                  [graphVisualization objectForKey: @"GraphConfiguration"]];

  [self initializeWithArguments: arguments];
  return self;
}

- (void) initializeWithArguments: (struct arguments) arguments
{
  //disabling single-file attributes
  reader = nil;
  encapsulator = nil;

  int input_size = arguments.input_size, i = 0;
  NSMutableArray *files = [NSMutableArray array];
  for (i = 0; i < arguments.input_size; i++){
    [files addObject: [NSString stringWithFormat: @"%s", arguments.input[i]]];
  }

  //reading the files
  for (i = 0; i < input_size; i++){
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
