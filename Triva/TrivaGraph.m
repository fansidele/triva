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
    posCalculated = NO;
    isVisible = NO;

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
  [connectedNodes addObject: n];
}

- (BOOL) isConnectedTo: (TrivaGraph*) c
{
  //return YES if connected directly to me 
  //or any of my children
  if ([connectedNodes containsObject: c]) return YES;
  NSEnumerator *en = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en nextObject])){
    if ([child isConnectedTo: c]) return YES;
  }
  return NO;
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

  //recurse to my children
  NSEnumerator *en1 = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en1 nextObject])){
    [child timeSelectionChanged];
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
 * Search method
 */
- (TrivaGraph *) searchWith: (NSPoint) point
               limitToDepth: (int) d
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

- (NSSet*) connectedNodes;
{
  return connectedNodes;
}

- (void) resetVelocity
{
  velocity = NSZeroPoint;
}

- (void) resetLocation
{
  location = NSZeroPoint;
}

- (void) setVelocity: (NSPoint)v
{
  velocity = v;
}

- (void) setLocation: (NSPoint)l
{
  location = l;
}

- (NSPoint) velocity
{
  return velocity;
}

- (NSPoint) location
{
  return location;
}

- (void) recursiveResetPositions
{
  location = NSZeroPoint;

  NSEnumerator *en = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en nextObject])){
    [child recursiveResetPositions];
  }
}

- (void) setExpanded: (BOOL) e
{
  [super setExpanded: e];

  if (e){
    if ([children count] == 0) return;

    //I disappear, my children appear
    [self setVisible: NO];
    [self setChildrenVisible: YES];

    NSEnumerator *en = [children objectEnumerator];
    TrivaGraph *child;
    while ((child = [en nextObject])){
      if (![child positionsAlreadyCalculated]){
        [child setLocation: [self location]];
        [child setPositionsAlreadyCalculated: YES];
      }
    }
  }else{
    //I appear, my children disappear
    [self setVisible: YES];
    [self setChildrenVisible: NO];

    //find my new location based on children's locations
    NSRect ur = NSZeroRect;
    NSEnumerator *en = [children objectEnumerator];
    TrivaGraph *child;
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
}

- (void) setVisible: (BOOL) v
{
  isVisible = v;
}

- (void) setChildrenVisible: (BOOL) v
{
  NSEnumerator *en = [children objectEnumerator];
  TrivaGraph *child;
  while ((child = [en nextObject])){
    [child setVisible: v];
  }
}

- (BOOL) visible
{
  return isVisible;
}

- (TrivaGraph *) higherVisibleParent
{
  if ([(TrivaGraph*)parent visible]){
    return (TrivaGraph*)parent;
  }else{
    return [(TrivaGraph*)parent higherVisibleParent];
  }
}

- (BOOL) positionsAlreadyCalculated
{
  return posCalculated;
}

- (void) setPositionsAlreadyCalculated: (BOOL) p
{
  posCalculated = p;
}

- (double) charge
{
  //charge = space occupied in view (calculated from time/space trace data)
  double ret = bb.size.width;
  return ret;
}

- (double) spring: (TrivaGraph*) n
{
  //spring to a given node = the sum of our charges
  double ret = [self charge] + [n charge];
  return ret;
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
  return [[compositions objectForKey: compName] evaluateSize];
}
@end
