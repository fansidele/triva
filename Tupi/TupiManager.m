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
  selectedNode = nil;
  configuration = nil;
  gvc = gvContext();
  graph = agopen ((char *)"graph", AGRAPHSTRICT);
  agnodeattr (graph, (char*)"label", (char*)"");
  agraphattr (graph, (char*)"overlap", (char*)"false");
  agraphattr (graph, (char*)"splines", (char*)"true");
  return self;
}

- (id) initWithConfigurationDictionary: (NSDictionary*) conf
                         andPajeFilter: (PajeFilter*) f
{
  self = [self init];
  configuration = [[TupiConfiguration alloc] initWithDictionary: conf];
  filter = f;
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

- (void) createNodeWithName: (NSString*) name type: (id) type
{
  NSDictionary *dict = [configuration configurationForType: type];
  Tupi *node = [[Tupi alloc] initWithConfiguration: dict];
  [node setName: name];
  [node setType: type];
  agnode (graph, (char*)[[node name] cString]);
  [nodes setObject: node forKey: name];
  [node release];
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

- (void) layoutOfNode: (Tupi*) node withValues: (NSDictionary*) values minValues: (NSDictionary*) min maxValues: (NSDictionary*) max colors: (NSDictionary*) colors
{
  NSDictionary *conf;
  conf = [configuration configurationForType: [[node type] description]];
  [node layoutWith:conf
            values:values
         minValues:min
         maxValues:max
            colors:colors];
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

- (BOOL) searchAndHighlightAtPoint: (NSPoint) p
{
  BOOL wasSelected = NO;
  if (selectedNode) {
    [selectedNode setHighlight: NO];
    wasSelected = YES;
  }
  NSEnumerator *en = [nodes objectEnumerator];
  Tupi *node;
  while ((node = [en nextObject])){
    if ([node pointInside: p]){
      selectedNode = node;
      [node setHighlight: YES];
      return YES;
    }
  }
  selectedNode = nil;
  return wasSelected;
}

- (BOOL) moveHighlightToPoint: (NSPoint) p
{
  if (!selectedNode) return NO;
  NSRect nodebb = [selectedNode boundingBox];
  nodebb.origin.x = p.x - nodebb.size.width/2;
  nodebb.origin.y = p.y - nodebb.size.height/2;
  [selectedNode setBoundingBox: nodebb];
  return YES;
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

- (TupiGroup*) treeWithContainer: (PajeContainer *) cont
                           depth: (int) depth
                          parent: (TupiGroup*) p
{
}

- (void) createGraph
{
  [tree release];
  tree = [self treeWithContainer: [filter rootInstance]
                           depth: 0  
                          parent: nil];
  [tree retain];
}
@end
