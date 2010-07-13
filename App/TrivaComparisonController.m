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
- (void) x
{

}

- (id) init
{
  self = [super init];
  NSArray *g1 = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController \
    ) )" propertyList];
  NSArray *g2 = [@"(  \
    ( FileReader, \
       PajeEventDecoder, \
       PajeSimulator, \
       StorageController \
    ) )" propertyList];
  seq1 = [NSMutableDictionary dictionary];
  seq2 = [NSMutableDictionary dictionary];
  [self addComponentSequences: g1 withDictionary: seq1];
  [self addComponentSequences: g2 withDictionary: seq2];
  return self;
}

- (void) setInputFiles: (NSArray *) files
{
  //reading the first file
  reader = [self componentWithName:@"FileReader" fromDictionary: seq1];
  [reader setInputFilename: [files objectAtIndex: 1]];
  [self readAllTracefileFrom: reader];
  simulator = [self componentWithName:@"PajeSimulator" fromDictionary: seq1];
  encapsulator = [self componentWithName:@"StorageController" fromDictionary: seq1];

  //reading the second file
  reader = [self componentWithName:@"FileReader" fromDictionary: seq2];
  [reader setInputFilename: [files objectAtIndex: 0]];
  [self readAllTracefileFrom: reader];
  simulator = [self componentWithName:@"PajeSimulator" fromDictionary: seq2];
  encapsulator = [self componentWithName:@"StorageController" fromDictionary: seq2];
}
@end
