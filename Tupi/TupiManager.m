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
#include "TupiManager.h"

@implementation TupiManager
- (id) init
{
  self = [super init];
  nodes = [[NSMutableDictionary alloc] init];
  configuration = nil;
  gvc = gvContext();
  graph = agopen ((char *)"graph", AGRAPHSTRICT);
  agnodeattr (graph, (char*)"label", (char*)"");
  agraphattr (graph, (char*)"overlap", (char*)"false");
  agraphattr (graph, (char*)"splines", (char*)"true");
  return self;
}

- (id) initWithConfigurationDictionary: (NSDictionary*) conf
{
  self = [self init];
  configuration = [[TupiConfiguration alloc] initWithDictionary: conf];
  return self;
}


- (void) dealloc
{
  [nodes release];
  gvFreeLayout (gvc, graph);
  agclose (graph);
  gvFreeContext (gvc);
  [super dealloc];
}

- (void) addNode: (Tupi*) node
{
  [nodes setObject: node forKey: [node name]];
  agnode (graph, (char*)[[node name] cString]);
}

- (void) connectNode: (Tupi*) n1 toNode: (Tupi*) n2
{
  if (![[n1 name] isEqualToString: [n2 name]]){ 
    [n1 connectToNode: n2];
    [n2 connectToNode: n1];

    Agnode_t *s = agfindnode (graph, (char*)[[n1 name] cString]);
    Agnode_t *d = agfindnode (graph, (char*)[[n2 name] cString]);
    agedge (graph, s, d);
  }
}

- (NSEnumerator*) enumeratorOfNodes
{
  return [[nodes allValues] objectEnumerator];
}

- (Tupi*) findNodeByName: (NSString*) name
{
  return [nodes objectForKey: name];
}

- (void) layoutOfNode: (Tupi*) node withValues: (NSDictionary*) values andProvider: (id) provider
{
  NSDictionary *nodeConf = [configuration configurationForType: [node type]];
  [node layoutWith: nodeConf andValues: values andProvider: provider];
}

- (NSRect) sizeForGraph
{
  //FIXME
  return NSZeroRect;
}

- (void) startAdding
{
}

- (void) endAdding
{
  NSString *algo = [configuration graphvizAlgorithm];
  if (algo){
    gvLayout (gvc, graph, (char*)[algo cString]);
  }else{
    gvLayout (gvc, graph, (char*)"neato");
  }

  //saving positions
  NSEnumerator *en = [self enumeratorOfNodes];
  Tupi *node;

  while ((node = [en nextObject])){
    NSRect bb = [node boundingBox];
    Agnode_t *n = agfindnode (graph, (char *)[[node name] cString]);
    if (n){
      bb.origin.x = ND_coord(n).x;
      bb.origin.y = ND_coord(n).y;
    }
    [node setBoundingBox: bb];
  }
}

/*
 * TupiConfiguration protocol
 */
- (BOOL) graphviz
{
  return [configuration graphviz];
}

- (BOOL) userPosition
{
  return [configuration userPosition];
}

- (NSRect) userRect
{
  return [configuration userRect];
}

- (NSArray*) nodeTypes
{
  return [configuration nodeTypes];
}

- (NSArray*) edgeTypes
{
  return [configuration edgeTypes];
}
@end
