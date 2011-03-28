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
#include <graphviz/gvc.h>

#define MIN_SIZE   20.0
#define MAX_SIZE   100.0

//for compatibility with some graphviz's
//installations (ubuntu's lucid, for example)
#ifndef ND_coord
#define ND_coord ND_coord_i
#endif

typedef enum {
  TRIVA_NODE,
  TRIVA_EDGE,
  TRIVA_ROUTER
} TrivaGraphType;

@interface TrivaGraph : TrivaTree
{
  NSMutableSet *connectedNodes;
  NSMutableDictionary *compositions;
  double size;
  TrivaGraphType type;

  NSPoint location; //current location
  NSPoint velocity; //current velocity

  NSMutableDictionary *connectionPoints; //TrivaGraph->NSPoint(as NSString)

  BOOL posCalculated;
  BOOL isVisible; //define whether it appears or not in the visualization
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
//- (void) graphvizCreateNodes;
//- (void) graphvizCreateEdges;
//- (void) graphvizSetPositions;
- (void) connectToNode: (TrivaGraph*) n;
- (BOOL) isConnectedTo: (TrivaGraph*) c;

/* search-based methods */
- (TrivaGraph *) searchWith: (NSPoint) point
      limitToDepth: (int) d;
- (TrivaGraph *) searchAtPoint: (NSPoint) point;

/* dealing with expressions */
- (BOOL) expressionHasVariables: (NSString*) expr;
- (double) evaluateWithValues: (NSDictionary *) values
    withExpr: (NSString *) expr;

- (NSSet*) connectedNodes;
- (void) resetVelocity;
- (void) resetLocation;
- (void) setVelocity: (NSPoint)v;
- (void) setLocation: (NSPoint)l;
- (NSPoint) velocity;
- (NSPoint) location;
- (void) recursiveResetPositions;
- (void) setVisible: (BOOL)v;
- (void) setChildrenVisible: (BOOL) v; //recursive
- (BOOL) visible;
- (TrivaGraph *) higherVisibleParent;
- (BOOL) positionsAlreadyCalculated;
- (void) setPositionsAlreadyCalculated: (BOOL) p;
@end

@interface TrivaGraph (Layout)
- (void) recursiveLayout;
- (void) recursiveLayoutWithMinValues: (NSDictionary *) minValues
                            maxValues: (NSDictionary *) maxValues;
- (void) layoutWithMinValues: (NSDictionary *) minValues
                   maxValues: (NSDictionary *) maxValues;
- (NSPoint) connectionPointForPartner: (TrivaGraph *) p;
- (void) mergeValuesDictionary: (NSDictionary *) a
                intoDictionary: (NSMutableDictionary *) b
              usingComparisong: (NSComparisonResult) comp;
- (NSDictionary *) graphGlobalMinValues;
- (NSDictionary *) graphGlobalMaxValues;
- (void) drawLayout;
@end

#endif
