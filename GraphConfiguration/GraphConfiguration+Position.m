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

#include "GraphConfiguration.h"

@implementation GraphConfiguration (Position)
- (NSString *) traceUniqueLabel
{
  NSString *filename = [self traceDescription];
  if (filename){
    return [[filename pathComponents] lastObject];
  }
  return nil;
}

- (void) saveGraphPositionsToUserDefaults: (NSString *) label
{
  NSUserDefaults *defaults;
  NSString *key;
  NSEnumerator *en;
  TrivaGraphNode *node;
  NSMutableDictionary *dict;

  defaults = [NSUserDefaults standardUserDefaults];
  key = [NSString stringWithFormat: @"%@-GraphConfigurationPosition", label];
  //check if it already exists on defaults
  if ([defaults objectForKey: key]){
    //if it exits, delete and continue
    [defaults removeObjectForKey: key];
  }
  en = [nodes objectEnumerator];
  dict = [NSMutableDictionary dictionary];
  while ((node = [en nextObject])){
    NSString *xk = [NSString stringWithFormat: @"%@-x", [node description]];
    NSString *xv = [NSString stringWithFormat: @"%f", [node bb].origin.x];
    NSString *yk = [NSString stringWithFormat: @"%@-y", [node description]];
    NSString *yv = [NSString stringWithFormat: @"%f", [node bb].origin.y];
    [dict setObject: xv forKey: xk];
    [dict setObject: yv forKey: yk];
  }
  [defaults setObject: dict forKey: key];
  [defaults synchronize];
}

- (BOOL) retrieveGraphPositionsFromUserDefaults: (NSString *) label
{
  NSUserDefaults *defaults;
  NSString *key;
  NSEnumerator *en;
  TrivaGraphNode *node;
  NSMutableDictionary *dict;
  NSException *exception;

  exception = [NSException exceptionWithName: @"GraphConfigurationException"
                  reason: @"User defaults has no or incomplete position "
                          "configuration for the elements of this trace file."
                    userInfo: nil];

  defaults = [NSUserDefaults standardUserDefaults];
  key = [NSString stringWithFormat: @"%@-GraphConfigurationPosition", label];
  //check if it already exists on defaults
  dict = [defaults objectForKey: key];
  if (!dict){
    [exception raise];
    return NO;
  }
  en = [nodes objectEnumerator];
  while ((node = [en nextObject])){
    NSString *xk = [NSString stringWithFormat: @"%@-x", [node description]];
    NSString *xv;
    NSString *yk = [NSString stringWithFormat: @"%@-y", [node description]];
    NSString *yv;

    if (!xk || !yk) {
      [exception raise];
      return NO;
    }

    xv = [dict objectForKey: xk];
    yv = [dict objectForKey: yk];

    NSRect bb = [node bb];
    bb.origin.x = [xv doubleValue];
    bb.origin.y = [yv doubleValue];
    [node setBoundingBox: bb];
  }
  return YES;
}

- (BOOL) retrieveGraphPositionsFromConfiguration: (NSDictionary *) conf
{
  NSEnumerator *en;

  en = [nodes objectEnumerator];
  TrivaGraphNode *node;

  NSMutableArray *missingNodePosition = [NSMutableArray array];

  while ((node = [en nextObject])){
    NSDictionary *pos = [conf objectForKey: [node name]];
    NSRect bb = [node bb];
    if (pos){
      bb.origin.x = [[pos objectForKey: @"x"] doubleValue];
      bb.origin.y = [[pos objectForKey: @"y"] doubleValue];
      [node setBoundingBox: bb];
    }else{
      [missingNodePosition addObject: [node name]];
    }
  }
  if ([missingNodePosition count]){
      [NSException raise:@"GraphConfigurationException"
                  format:@"User defined positions are incomplete. "
                          "Need to have a position for  nodes: %@", 
                                                   missingNodePosition];
      return NO;
  }
  return YES;
}

- (BOOL) retrieveGraphPositionsFromGraphviz: (NSDictionary *) conf
{
  //we have to run graphviz layout (slow)
  NSLog (@"%s:%d Executing GraphViz Layout... (this might "
            "take a while)", __FUNCTION__, __LINE__);
  NSString *algo = [conf objectForKey: @"graphviz-algorithm"];
  gvFreeLayout (gvc, graph);
  if (algo){
    gvLayout (gvc, graph, (char*)[algo cString]);
  }else{
    gvLayout (gvc, graph, (char*)"neato");
  }
  NSLog (@"%s:%d GraphViz Layout done", __FUNCTION__, __LINE__);
  NSLog (@"%s:%d Got %d nodes and %d edges", __FUNCTION__, __LINE__,
      [nodes count], [edges count]);

  //copy that information to nodes
  NSEnumerator *en = [nodes objectEnumerator];
  TrivaGraphNode *node;

  while ((node = [en nextObject])){
    NSRect bb = [node bb];
    Agnode_t *n = agfindnode (graph, (char *)[[node name] cString]);
    if (n){
#ifdef GNUSTEP
      bb.origin.x = ND_coord_i(n).x;
      bb.origin.y = ND_coord_i(n).y;
#else
      bb.origin.x = ND_coord(n).x;
      bb.origin.y = ND_coord(n).y;
#endif
    }
    [node setBoundingBox: bb];
  }
  return YES;
}
@end
