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
#include "TrivaFilter.h"

@implementation TrivaFilter
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController:c];
  return self;
}

- (TrivaGraphNode*) findNodeByName: (NSString *)name
{
  return [(TrivaFilter*)inputComponent findNodeByName: name];
}

- (NSEnumerator*) enumeratorOfNodes;
{
  return [(TrivaFilter*)inputComponent enumeratorOfNodes];
}

- (NSEnumerator*) enumeratorOfEdges
{
  return [(TrivaFilter*)inputComponent enumeratorOfEdges];
}

- (NSRect) sizeForGraph
{
  return [(TrivaFilter*)inputComponent sizeForGraph];
}

- (double) graphComponentScaling
{
  return [(TrivaFilter*)outputComponent graphComponentScaling];
}

- (void) graphComponentScalingChanged
{
  return [(TrivaFilter*)inputComponent graphComponentScalingChanged];
}

- (TimeSliceTree *) timeSliceTree
{
  return [(TrivaFilter*)inputComponent timeSliceTree];
}

- (void) debugOf: (PajeEntityType*) type At: (PajeContainer*) container
{
  return [(TrivaFilter*)inputComponent debugOf: type At: container];
}

- (BOOL) expressionHasVariables: (NSString*) expr
{
  return [(TrivaFilter*)inputComponent expressionHasVariables: expr];
}

- (double) evaluateWithValues: (NSDictionary *) values
                withExpr: (NSString *) expr
{
  return [(TrivaFilter*)inputComponent evaluateWithValues: values
      withExpr: expr];
}

- (NSColor *) getColor: (NSColor *)c withSaturation: (double) saturation
{
  return nil; // TODO: remove
}

- (double) calculateScreenSizeBasedOnValue: (double) size
  andMax: (double)max andMin: (double)min
{
  return [(TrivaFilter*)inputComponent calculateScreenSizeBasedOnValue: size
        andMax: max andMin: min]; //TODO: remove
}

- (double) maxOfVariable: (NSString *) variable
               withScale: (TrivaScale) scale
                ofObject: (NSString *) entityName
                withType: (NSString *) entityType
{
  return [(TrivaFilter*)inputComponent maxOfVariable: variable
                                           withScale: scale
                                            ofObject: entityName
                                            withType: entityType];
}

- (double) minOfVariable: (NSString *) variable
               withScale: (TrivaScale) scale
                ofObject: (NSString *) entityName
                withType: (NSString *) entityType
{
  return [(TrivaFilter*)inputComponent minOfVariable: variable
                                           withScale: scale
                                            ofObject: entityName
                                            withType: entityType];
}

+ (NSDictionary*) defaultOptions
{
  /* to be implemented by sub-classes */
  return nil;
}

- (void) show
{
  /* to be implemented by sub-classes */
  return;
}
@end
