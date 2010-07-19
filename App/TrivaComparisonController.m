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
- (id) initWithArguments: (struct arguments) arguments
{
  self = [super initWithArguments: arguments];

  NSArray *g1 = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       Compare, \
       TimeSliceAggregation, \
       SquarifiedTreemap \
    ) )" propertyList];
  NSArray *g2 = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController, \
       Compare, \
       TimeSliceAggregation, \
       SquarifiedTreemap \
    ) )" propertyList];

  //create graphs
  seq1 = [NSMutableDictionary dictionary];
  seq2 = [NSMutableDictionary dictionary];
  [self addComponentSequences: g1 withDictionary: seq1];
  [self addComponentSequences: g2 withDictionary: seq2];

  //create the CompareController
  Class compareControllerClass = NSClassFromString(@"CompareController");
  if (compareControllerClass == nil){
    return nil;
  }
  compareController = [[compareControllerClass alloc] init];

  //set the Compare filters' controller
  SEL method = @selector(setController:);
  [[seq1 objectForKey: @"Compare"] performSelector: method withObject: compareController];
  [[seq2 objectForKey: @"Compare"] performSelector: method withObject: compareController];

  //add the compare filters to the controller
  NSMutableArray *compareFilters = [NSMutableArray array];
  [compareFilters addObject: [seq1 objectForKey: @"Compare"]];
  [compareFilters addObject: [seq2 objectForKey: @"Compare"]];
  method = @selector(addFilters:);
  [compareController performSelector: method withObject: compareFilters];

  [self initializeWithArguments: arguments];
  return self;
}

- (void) initializeWithArguments: (struct arguments) arguments
{

  //disabling single-file attributes
  reader = nil;
  encapsulator = nil;

  int i;
  NSMutableArray *files = [NSMutableArray array];
  for (i = 0; i < arguments.input_size; i++){
    [files addObject: [NSString stringWithFormat: @"%s", arguments.input[i]]];
  }

  //reading the first file
  reader1 = [self componentWithName:@"FileReader" fromDictionary: seq1];
  [reader1 setInputFilename: [files objectAtIndex: 0]];
  [self readAllTracefileFrom: reader1];
  storage1 = [self componentWithName:@"StorageController" fromDictionary: seq1];
  [storage1 timeLimitsChanged];

  //reading the second file
  reader2 = [self componentWithName:@"FileReader" fromDictionary: seq2];
  [reader2 setInputFilename: [files objectAtIndex: 1]];
  [self readAllTracefileFrom: reader2];
  storage2 = [self componentWithName:@"StorageController" fromDictionary: seq2];
  [storage2 timeLimitsChanged];

  //check if trace files are good to go
  SEL method = @selector(check);
  [compareController performSelector: method withObject: nil];

  [self setSelectionWindow];
}

- (void)setSelectionWindow
{
  [storage1 setSelectionStartTime: [storage1 startTime]
                          endTime: [storage1 endTime]];
  [storage2 setSelectionStartTime: [storage2 startTime]
                          endTime: [storage2 endTime]];
}
@end
