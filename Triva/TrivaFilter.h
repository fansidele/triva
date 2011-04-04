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
#ifndef __TrivaFilter_h
#define __TrivaFilter_h
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <Triva/Triva.h>
#include <Triva/TrivaConfiguration.h>

typedef enum {Local,Global,Convergence,Arnaud} TrivaScale;

@interface TrivaFilter  : PajeFilter
- (id) currentTupiManager;

/* auxiliary methods */
- (void) debugOf: (PajeEntityType*) type At: (PajeContainer*) container;
- (BOOL) expressionHasVariables: (NSString*) expr;
- (double) evaluateWithValues: (NSDictionary *) values
                withExpr: (NSString *) expr;
- (NSColor *) getColor: (NSColor *)c withSaturation: (double) saturation; //TODO :remove

// new part of protocol
- (double) maxOfVariable: (NSString *) variable
               withScale: (TrivaScale) scale
                ofObject: (NSString *) entityName
                withType: (NSString *) entityType;
- (double) minOfVariable: (NSString *) variable
               withScale: (TrivaScale) scale
                ofObject: (NSString *) entityName
                withType: (NSString *) entityType;


//configuration from the command line
+ (NSDictionary*) defaultOptions;
- (void) setConfiguration: (TrivaConfiguration*) opt;
- (void) show;
- (void) hide;

//spatial/time integration protocol
- (NSDictionary *) timeIntegrationOfType:(PajeEntityType*) type inContainer:(PajeContainer*) cont;
- (NSDictionary *) integrationOfContainer: (PajeContainer *) cont;
- (NSDictionary *) spatialIntegrationOfContainer: (PajeContainer *) cont;
- (NSColor *) colorForIntegratedValueNamed: (NSString *) valueName;

//graph view protocol
- (NSDictionary *) graphConfigurationForContainerType:(PajeEntityType*) type;
- (NSDictionary *) graphConfiguration;
- (NSArray*) entityTypesForNodes;
- (NSArray*) entityTypesForEdges;
- (NSDictionary *) minValuesForContainerType:(PajeEntityType*) type;
- (NSDictionary *) maxValuesForContainerType:(PajeEntityType*) type;
@end

#endif
