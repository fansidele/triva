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
#include "TupiConfiguration.h"

@implementation TupiConfiguration
- (id) init
{
  self = [super init];
  configuration = nil;
  graphviz = NO;
  userPosition = NO;
  return self;
}

- (void) dealloc
{
  [configuration release];
  [super dealloc];
}

- (id) initWithDictionary: (NSDictionary*) conf
{
  self = [self init];
  [configuration = [NSDictionary dictionaryWithDictionary: conf] retain];
  
  //check if graphviz should be used
  graphvizAlgorithm = [configuration objectForKey: @"graphviz-algorithm"];
  if (graphvizAlgorithm){
    [graphvizAlgorithm retain];
    graphviz = YES;
  }else{
    graphviz = NO;
  }

  //checking if user provided positions for nodes
  id area = [conf objectForKey: @"area"];
  if (area){
    userRect.origin.x = [[area objectForKey: @"x"] doubleValue];
    userRect.origin.y = [[area objectForKey: @"y"] doubleValue];
    userRect.size.width = [[area objectForKey: @"width"] doubleValue];
    userRect.size.height = [[area objectForKey: @"height"] doubleValue];
    userPosition = YES;
  }else{
    userPosition = NO;
  }

  //obtaining node type based on configuration
  nodeTypes = [conf objectForKey: @"node"];
  if (!nodeTypes || ![nodeTypes isKindOfClass: [NSArray class]]){
    //FIXME
    NSLog (@"FIXME %s:%d", __FUNCTION__, __LINE__);
    exit(1);
  }
  [nodeTypes retain];

  //obtaining edge type based on configuration
  edgeTypes = [conf objectForKey: @"edge"];
  if (!edgeTypes || ![edgeTypes isKindOfClass: [NSArray class]]){
    //FIXME
    NSLog (@"FIXME %s:%d", __FUNCTION__, __LINE__);
    exit(1);
  }
  [edgeTypes retain];
  return self;
}

- (BOOL) graphviz
{
  return graphviz;
}

- (BOOL) userPosition
{
  return userPosition;
}

- (NSRect) userRect
{
  return userRect;
}

- (NSArray*) nodeTypes
{
  return nodeTypes;
}
- (NSArray*) edgeTypes
{
  return edgeTypes;
}

- (NSDictionary*) configurationForType: (NSString*) type
{
  return [configuration objectForKey: type];
}

- (NSString*) graphvizAlgorithm
{
  return graphvizAlgorithm;
}
@end
