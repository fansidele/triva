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
#ifndef __TrivaGraph_H_
#define __TrivaGraph_H_
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Triva/Triva.h>
#include <matheval.h>

typedef enum {
  TRIVA_NODE,
  TRIVA_EDGE,
  TRIVA_ROUTER
} TrivaGraphType;

@interface TrivaGraph : TrivaTree
{
  NSMutableSet *connectedNodes;
  NSMutableDictionary *compositions;

  NSPoint location; //current location
  NSPoint velocity; //current velocity

  NSMutableDictionary *connectionPoints; //TrivaGraph->NSPoint(as NSString)

  BOOL posCalculated;
}
+ (TrivaGraph*) nodeWithName: (NSString*)n
                      depth: (int)d
                     parent: (TrivaTree*)p
                   expanded: (BOOL)e
                  container: (PajeContainer*)c
                     filter: (TrivaFilter*)f;
- (id) initWithName: (NSString*)n
              depth: (int)d
             parent: (TrivaTree*)p
           expanded: (BOOL)e
          container: (PajeContainer*)c
             filter: (TrivaFilter*)f;
- (void) connectToNode: (TrivaGraph*) n;
- (BOOL) isConnectedTo: (TrivaGraph*) c;

/* search-based methods */
- (TrivaGraph *) searchWith: (NSPoint) point
      limitToDepth: (int) d;
- (TrivaGraph *) searchAtPoint: (NSPoint) point;

/* dealing with expressions */
- (BOOL) expressionHasVariables: (NSString*) expr;
- (BOOL) evaluateWithValues: (NSDictionary *) values
                   withExpr: (NSString *) expr
                  evaluated: (double*) output;
- (NSSet*) connectedNodes;
- (void) resetVelocity;
- (void) resetLocation;
- (void) setVelocity: (NSPoint)v;
- (void) setLocation: (NSPoint)l;
- (NSPoint) velocity;
- (NSPoint) location;
- (void) recursiveResetPositions;
- (BOOL) positionsAlreadyCalculated;
- (void) setPositionsAlreadyCalculated: (BOOL) p;
- (double) charge;
- (double) spring: (TrivaGraph *) n;
- (double) sizeForConfigurationName: (NSString *)compName;


/* new methods */
- (void) expand;    //non-recursive (one level only)
- (void) collapse;  //recursive (all to the bottom)

/* export */
- (NSString *) exportDot;
@end

@interface TrivaGraph (Layout)
- (void) recursiveLayout;
- (void) layout;

- (void) recursiveDrawLayout;
- (void) drawLayout;
@end

#endif
