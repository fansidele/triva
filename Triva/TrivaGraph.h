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

#define MIN_SIZE   20
#define MAX_SIZE   40

//for compatibility with some graphviz's
//installations (ubuntu's lucid, for example)
#ifndef ND_coord
#define ND_coord ND_coord_i
#endif

@interface TrivaGraph : TrivaTree
{
  NSMutableSet *connectedNodes;
  NSMutableDictionary *compositions;
  double size;

  NSPoint velocity; //force-directed algo
  BOOL executeThread;
  NSThread *thread;

  NSMutableDictionary *connectionPoints; //TrivaGraph->NSPoint(as NSString)
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
- (void) graphvizCreateNodes;
- (void) graphvizCreateEdges;
- (void) graphvizSetPositions;
- (void) connectToNode: (TrivaGraph*) n;

- (void) drawLayout;

/* search-based methods */
- (TrivaGraph *) searchWith: (NSPoint) point
      limitToDepth: (int) d;


/* dealing with expressions */
- (BOOL) expressionHasVariables: (NSString*) expr;
- (double) evaluateWithValues: (NSDictionary *) values
    withExpr: (NSString *) expr;

- (NSPoint) centerPoint;
- (NSSet*) connectedNodes;
- (void) forceDirectedLayout;
- (void) resetVelocity;
- (void) setVelocity: (NSPoint)v;
- (NSPoint) velocity;
- (void) cancelThreads;
@end

@interface TrivaGraph (Layout)
- (void) layoutSizeWith: (double) screenSize;
- (void) layoutConnectionPointsWith: (double) screenSize;
- (NSPoint) connectionPointForPartner: (TrivaGraph *) p;
@end

#endif
