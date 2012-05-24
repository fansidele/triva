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

- (void) setConfiguration: (TrivaConfiguration*) opt
{
  /* to be implemented by sub-classes */
  return;
}

- (void) show
{
  /* to be implemented by sub-classes */
  return;
}

- (void) hide
{
  /* to be implemented by sub-classes */
  return;
}

- (NSDictionary *) timeIntegrationOfType:(PajeEntityType*) type
                inContainer:(PajeContainer*) cont
{
  return [(TrivaFilter*)inputComponent timeIntegrationOfType: type
                                                 inContainer: cont];
}

- (NSDictionary *) integrationOfContainer: (PajeContainer *) cont
{
  return [(TrivaFilter*)inputComponent integrationOfContainer: cont];
}

- (NSDictionary *) spatialIntegrationOfContainer: (PajeContainer *) cont
{
  return [(TrivaFilter*)inputComponent spatialIntegrationOfContainer:cont];
}

- (NSColor *) colorForIntegratedValueNamed: (NSString *) valueName
{
  return [(TrivaFilter*)inputComponent colorForIntegratedValueNamed: valueName];
}

- (NSDictionary *) entropyOfContainer: (PajeContainer*) cont;
{
  return [(TrivaFilter*)inputComponent entropyOfContainer: cont];
}

- (NSDictionary *) entropyGainOfContainer: (PajeContainer*) cont
{
  return [(TrivaFilter*)inputComponent entropyGainOfContainer: cont];
}

- (NSDictionary *) informationLossOfContainer: (PajeContainer*) cont
{
  return [(TrivaFilter*)inputComponent informationLossOfContainer: cont];
}

- (NSDictionary *) divergenceOfContainer: (PajeContainer*) cont
{
  return [(TrivaFilter*)inputComponent divergenceOfContainer: cont];
}

- (NSDictionary *) ricOfContainer: (PajeContainer*) cont
{
  return [(TrivaFilter*)inputComponent ricOfContainer: cont];
}

- (NSDictionary *) pRicOfContainer: (PajeContainer*) cont withP: (double) pval
{
  return [(TrivaFilter*)inputComponent pRicOfContainer: cont withP: pval];
}

- (BOOL) entropyLetDisaggregateContainer: (PajeContainer*) cont
{
  return [(TrivaFilter*)inputComponent entropyLetDisaggregateContainer: cont];
}

- (BOOL) entropyLetShowContainer: (PajeContainer*) cont
{
  return [(TrivaFilter*)inputComponent entropyLetShowContainer: cont];
}

- (NSDictionary *) graphConfigurationForContainerType:(PajeEntityType*) type
{
  return [(TrivaFilter*)inputComponent graphConfigurationForContainerType:type];
}

- (NSDictionary *) graphConfiguration
{
  return [(TrivaFilter*)inputComponent graphConfiguration];
}

- (double) scaleForConfigurationWithName: (NSString *) name
{
  return [(TrivaFilter*)inputComponent scaleForConfigurationWithName: name]; 
}

- (NSArray*) entityTypesForNodes
{
  return [(TrivaFilter*)inputComponent entityTypesForNodes];
}

- (NSArray*) entityTypesForEdges
{
  return [(TrivaFilter*)inputComponent entityTypesForEdges];
}

- (NSDictionary *) minValuesForContainerType:(PajeEntityType*) type
{
  return [(TrivaFilter*)inputComponent minValuesForContainerType:type];
}

- (NSDictionary *) maxValuesForContainerType:(PajeEntityType*) type
{
  return [(TrivaFilter*)inputComponent maxValuesForContainerType:type];
}

- (void) removeForceDirectedNodes
{
  return [(TrivaFilter*)inputComponent removeForceDirectedNodes];
}

- (void) addForceDirectedNode: (id) node
{
  return [(TrivaFilter*)inputComponent addForceDirectedNode: node];
}

- (BOOL) hasGraphvizLocationFromFile
{
  return [(TrivaFilter*)inputComponent hasGraphvizLocationFromFile];
}

- (NSPoint) graphvizLocationForName: (NSString *)name
{
  return [(TrivaFilter*)inputComponent graphvizLocationForName: name];
}

- (NSSize) graphvizSize
{
  return [(TrivaFilter*)inputComponent graphvizSize];
}
@end
