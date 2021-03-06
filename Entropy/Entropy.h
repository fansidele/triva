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
#ifndef __Entropy_H
#define __Entropy_H
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Renaissance/Renaissance.h>
#include "../Triva/TrivaFilter.h"
#include "../Triva/TrivaWindow.h"

@class EntropyPlot;

@interface Entropy  : TrivaFilter
{
  NSArray *bestAggregationContainer;
  NSMutableArray *leafContainers;
  double p;
  NSString *variableName;
  EntropyPlot *entropyPlot;
  NSArray *savedEntropyPoints;

  //GUI
  TrivaWindow *window;
  NSSlider *slider;
  NSTextField *text;
  NSPopUpButton *variableboxer;
  NSTextField *variablecurrent;
}
- (NSMutableArray *) leafContainersInContainer: (PajeContainer *) cont;
- (NSMutableArray *) childrenOfContainer: (PajeContainer *) cont;
- (void) addThis: (NSDictionary *) origin
          toThis: (NSMutableDictionary *) destination;
- (void) subtractThis: (NSDictionary *) origin
             fromThis: (NSMutableDictionary *) destination;
- (void) multiplyThis: (NSMutableDictionary *) origin
               byThis: (double) m;
- (NSDictionary*) vzeroOfType: (PajeEntityType*) type;
- (NSArray *) maxPRicOfContainer: (PajeContainer*) cont
                           withP: (double) pval
			   withVariable: (NSString *) variable;
- (void) redefineAvailableVariables;
- (void) recalculateBestAggregation;

- (NSDictionary *) entropyGainOfAggregation: (NSArray*) containers;
- (NSDictionary *) divergenceOfAggregation: (NSArray*) containers;

- (NSArray *) getEntropyPointsFromPoint: (NSArray*) minPoint
				toPoint: (NSArray*) maxPoint
				withVariable: (NSString*) variable;
- (NSArray *) getEntropyPointsWithVariable: (NSString*) variable;
- (NSMutableArray *) getEntropyPointsByStep: (double) step withVariable: (NSString*) variable;
- (NSArray *) translateEntropyPoints: (NSArray *) points withVariable: (NSString*) variable;
- (BOOL) areEqualsAggregation1: (NSArray *) aggregation1 aggregation2: (NSArray *) aggregation2;

- (NSString *) variableName;
- (double) parameter;
- (NSArray *) savedEntropyPoints;

//notification of a change in P
- (void) pChanged;
- (void) variableChanged;
@end

@interface Entropy (GUI)
- (void) pSliderChanged: (id) sender;
- (void) pTextChanged: (id) sender;
- (void) variableChanged: (id) sender;
@end

#include "EntropyPlot.h"
#endif
