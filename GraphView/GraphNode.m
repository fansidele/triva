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
#include "GraphNode.h"

@implementation GraphNode
- (id) initWithTrivaNode: (TrivaGraph*) n
{
  self = [super init];
  node = n;
  connected = [[NSMutableSet alloc] init];
  particle = nil;
  return self;
}

- (void) dealloc
{
  [connected release];
  [super dealloc];
}

/* The TupiNode protocol implementation */
- (NSPoint) position
{
  return pos;
}

- (void) setPosition: (NSPoint) newPosition
{
  pos = newPosition;

  //set the TrivaGraph node position
  [node setLocation: NSMakePoint(pos.x*100, pos.y*100)];
}

- (NSSet *) connectedNodes
{
  return connected;
}

- (void) setParticle: (id)p
{
  //don't retain
  particle = p;
}

- (id) particle
{
  return particle;
}

- (NSString *) name
{
  return [node name];
}
@end
