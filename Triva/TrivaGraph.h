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
#include <PajeGeneral/PajeContainer.h>
#include "TrivaTree.h"
#include "TrivaComposition.h"

@class TrivaTree;

@interface TrivaGraph : TrivaTree
{
  NSMutableSet *connectedNodes;
  NSMutableDictionary *compositions;
  NSPoint location;
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

/* how the nodes are connected (as a graph) */
- (NSSet*) connectedNodes;
- (void) connectToNode: (TrivaGraph*) n;

/* search methods */
- (TrivaGraph *) searchAtPoint: (NSPoint) point;
- (TrivaGraph *) searchWith: (NSPoint) point limitToDepth: (int) d;

/* dealing with expressions */
- (double) sizeForConfigurationName: (NSString *)compName;
- (BOOL) expressionHasVariables: (NSString*) expr;
- (BOOL) evaluateWithValues: (NSDictionary *) values
                   withExpr: (NSString *) expr
                  evaluated: (double*) output;

/* other methods used for creating graph cuts from the tree */
- (void) expand;    //non-recursive (one level only)
- (void) collapse;  //recursive (all to the bottom)
- (TrivaGraph *) root;
- (NSSet *) collapsedNodes;

/* location of the node in a bi-dimensional space */
- (void) setLocation: (NSPoint)l;
- (NSPoint) location;
@end

@interface TrivaGraph (Layout)
- (void) recursiveLayout;
- (void) layout;
- (void) recursiveDrawLayout;
- (void) drawLayout;
@end

#include "TrivaTree.h"
#endif
