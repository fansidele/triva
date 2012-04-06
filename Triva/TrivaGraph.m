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
#include "TrivaGraph.h"
#include <matheval.h>
#include <float.h>

#define BIGFLOAT FLT_MAX

@implementation TrivaGraph
+ (TrivaGraph*) nodeWithName: (NSString*)n
                      depth: (int)d
                     parent: (TrivaTree*)p
                   expanded: (BOOL)e
                  container: (PajeContainer*)c
                     filter: (TrivaFilter*)f
{
  return [[[self alloc] initWithName: n
              depth:d
             parent:p
           expanded:e
          container:c
             filter:f] autorelease];
}


- (id) initWithName: (NSString*)n
              depth: (int)d
             parent: (TrivaTree*)p
           expanded: (BOOL)e
          container: (PajeContainer*)c
             filter: (TrivaFilter*)f
{
  self = [super initWithName:n
                       depth:d
                      parent:p
                    expanded:e
                   container:c
                      filter:f];
  if (self != nil){
    connectedNodes = [[NSMutableSet alloc] init];
    compositions = [[NSMutableDictionary alloc] init];

    //layout myself with update my graph values
    NSDictionary *configuration = [filter graphConfiguration];
    NSEnumerator *en = [configuration keyEnumerator];
    NSString *compositionName;
    while ((compositionName = [en nextObject])){
      NSDictionary *compConf = [configuration objectForKey: compositionName];
      if (![compConf isKindOfClass: [NSDictionary class]]) continue;
      if (![compConf count]) continue;
      //check if composition already exist
      if (![compositions objectForKey: compositionName]){
        TrivaComposition *comp;
        comp = [TrivaComposition compositionWithConfiguration:compConf
                                                         name:compositionName
                                                       values:values
                                                         node:self
                                                       filter:filter];
        if (comp){
          [compositions setObject: comp forKey: compositionName];
        }
      }
    }
  }
  return self;
}

- (void) dealloc
{
  [connectedNodes release];
  [compositions release];
  [super dealloc];
}

- (void) connectToNode: (TrivaGraph*) n
{
  if (n == nil) return;                     //don't connect with nil
  if ([self isEqual: n] == YES) return;     //don't connect with itself

  [connectedNodes addObject: n];

  if ([parent isEqual: [n parent]]) return; //only connect with sibling

  TrivaGraph *np = (TrivaGraph*)[n parent];
  while (np){
    if ([np parent] == nil) break;
    [connectedNodes addObject: np];
    np = (TrivaGraph*)[np parent];
  }

  //bottom-up recursion
  [(TrivaGraph*)parent connectToNode: n];
  return;
}

- (void) timeSelectionChanged
{
  //update current values
  [super timeSelectionChanged];

  //layout my compositions
  NSEnumerator *en0 = [compositions objectEnumerator];
  TrivaComposition *comp;
  while ((comp = [en0 nextObject])){
    [comp layout];
  }

  if ([self expanded]){

    //recurse to my children
    NSEnumerator *en1 = [children objectEnumerator];
    TrivaGraph *child;
    while ((child = [en1 nextObject])){
      [child timeSelectionChanged];
    }

  }
}

- (BOOL) pointWithinLocation: (NSPoint) p
{
  NSRect myTargetRect;
  myTargetRect.origin = NSMakePoint ([self location].x - bb.size.width/2,
                                     [self location].y - bb.size.height/2);
  myTargetRect.size = bb.size;
  return NSPointInRect (p, myTargetRect);
}

/*
 * Search methods
 */
- (TrivaGraph *) searchWith: (NSPoint) point limitToDepth: (int) d
{

  if ([self depth] == d){
    if ([self pointWithinLocation: point]){
      return self;
    }
  }else{
    NSEnumerator *en = [children objectEnumerator];
    TrivaGraph *child;
    while ((child = [en nextObject])){
      TrivaGraph *ret = [child searchWith: point limitToDepth: d];
      if (ret) return ret;
    }
  }
  return nil;
}

/* 
 * Another search method: bottom-up search
 */
- (TrivaGraph *) searchAtPoint: (NSPoint) point
{
  if ([self expanded]){
    NSEnumerator *en = [children objectEnumerator];
    TrivaGraph *child;
    while ((child = [en nextObject])){
      TrivaGraph *ret = [child searchAtPoint: point];
      if (ret) return ret;
    }
  }else{
    if ([self pointWithinLocation: point]){
      return self;
    }
  }
  return nil;
}

/* 
 * expressions
 */
- (BOOL) expressionHasVariables: (NSString*) expr
{
  BOOL ret;
  char **expr_names;
  int count;
  void *f = evaluator_create ((char*)[expr cString]);
  evaluator_get_variables (f, &expr_names, &count);
  if (count == 0){
    ret = NO;
  }else{
    ret = YES;
  }
  evaluator_destroy (f);
  return ret;
}

- (BOOL) evaluateWithValues: (NSDictionary *) vals
                   withExpr: (NSString *) expr
                  evaluated: (double*) output
{
  char **expr_names;
  double *expr_values, ret;
  int count, i;
  void *f = evaluator_create ((char*)[expr cString]);
  evaluator_get_variables (f, &expr_names, &count);
  if (count == 0){
    //no variables detected, return doubleValue
    return [expr doubleValue];
  }else{
    //ok, we have some variables to be defined
    expr_values = (double*)malloc (count * sizeof(double));
    for (i = 0; i < count; i++){
      NSString *var = [NSString stringWithFormat: @"%s", expr_names[i]];
      NSString *val = [vals objectForKey: var];
      if (val){
        expr_values[i] = [val doubleValue];
      }else{
        evaluator_destroy (f);
        *output = 0;
        return NO;
      }
    }
    ret = evaluator_evaluate (f, count, expr_names, expr_values);
    evaluator_destroy (f);
    free(expr_values);
  }
  *output = ret;
  return YES;
}

- (void) setLocation: (NSPoint)l
{
  location = l;
}

- (NSPoint) location
{
  return location;
}

- (NSString *) description
{
  NSMutableString *ret = [NSMutableString string];
  [ret appendString: [NSString stringWithFormat: @"Name: %@ (%@)",
                               name, [container entityType]]];
  if ([compositions count]){
    [ret appendString: @"\n"];
  }else{
    return ret;
  }
  NSEnumerator *en = [compositions objectEnumerator];
  TrivaComposition *composition;
  while ((composition = [en nextObject])){
    [ret appendString: [composition description]];
    [ret appendString: @"\n"];
  }
  return ret;
}

- (double) sizeForConfigurationName: (NSString *)compName
{
  return sqrt([[compositions objectForKey: compName] evaluateSize]);
}

- (void) expand    //non-recursive (one level only)
{
  //only expand if has children
  if ([children count]){
    [self setExpanded: YES];
  }
}

- (void) collapse  //recursive (from to the bottom up to self)
{
  //find my new location based on children's locations
  //(only if my location wasn't defined yet)
  if (NSEqualPoints (NSZeroPoint, [self location])){
    NSEnumerator *en = [children objectEnumerator];
    NSRect ur = NSZeroRect;
    TrivaGraph* child;
    while ((child = [en nextObject])){
      NSRect cRect;
      NSPoint cLoc = [child location];
      NSRect cBB = [child boundingBox];
      cRect.origin = NSMakePoint (cLoc.x - cBB.size.width/2,
                                  cLoc.y - cBB.size.height/2);
      cRect.size = cBB.size;
      ur = NSUnionRect (ur, cRect);
    }
    NSPoint nc = NSMakePoint (ur.origin.x+ur.size.width/2,
                              ur.origin.y+ur.size.height/2);
    [self setLocation: nc];
  }

  NSEnumerator *en = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en nextObject])){
    [child collapse];
  }
  [self setExpanded: NO];
}

- (NSSet *) connectedNodes
{
  NSMutableSet *set = [NSMutableSet setWithSet: connectedNodes];
  [set intersectSet: [[self root] collapsedNodes]];
  return set;
}

/*
 * Return the root of the tree
 */
- (TrivaGraph *) root
{
  if (parent == nil){
    return self;
  }else{
    return [(TrivaGraph*)parent root];
  }
}

/*
 * Gives a set with all nodes below 'self' that are collapsed.
 */
- (NSSet *) collapsedNodes
{
  NSMutableSet *set = [NSMutableSet set];
  if ([self expanded]){
    NSEnumerator *en = [children objectEnumerator];
    TrivaGraph *child;
    while ((child = [en nextObject])){
      [set unionSet: [child collapsedNodes]];
    }
  }else{
    [set addObject: self];
  }
  return set;
}

- (BOOL) isEqual: (id) another
{
  if (![another isKindOfClass: [TrivaGraph class]]){
    return NO;
  }else{
    return [name isEqual: [(TrivaGraph*)another name]];
  }
}

- (NSUInteger) hash
{
  return [name hash];
}
@end
