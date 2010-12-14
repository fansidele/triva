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
#include "TrivaServerSocket.h"

@implementation TrivaServerSocket
- (id) initWithPort: (int) port
{
  self = [super init];
  server_port = port;

  server_socket = socket (AF_INET, SOCK_STREAM, 0);
  if (server_socket < 0){
    NSLog (@"error on socket creation");
    return nil;
  }

  sin.sin_family = AF_INET;
  sin.sin_port = htons(server_port);
  sin.sin_addr.s_addr  = INADDR_ANY;

  int b = bind (server_socket, (struct sockaddr *)&sin, sizeof(sin));
  if (b < 0){
    NSLog (@"error on bind");
    close (server_socket);
    return nil;
  }
  return self;
}

- (void) stopServer
{
  keepListening = NO;
}

- (void) runServer: (id) controller
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  keepListening = YES;

  if (listen(server_socket, 1)) {
    NSLog (@"Error on listen");
    return;
  }

  NSLog (@"TrivaServerSocket running on port %d", server_port);

  unsigned int sinlen = sizeof (sin);
  while (keepListening){
    int client = accept(server_socket, (struct sockaddr *) &sin, &sinlen);
    if (client < 0){
      NSLog (@"Error on accept from server");
      break;
    }
    NSThread *thread = [[NSThread alloc] initWithTarget: self
                                       selector: @selector(serveClient:)
                                         object: controller];

    NSMutableDictionary *dict = [thread threadDictionary];
    [dict setObject: [NSString stringWithFormat: @"%d", client]
             forKey: @"client"];

    [thread start];
  } 
  [pool release];
}

- (void) dealloc
{
  keepListening = NO;
  close (server_socket);
  [super dealloc];
}

- (void) serveClient: (id) controller
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSDictionary *dict = [[NSThread currentThread] threadDictionary];
  int client_socket = [[dict objectForKey: @"client"] intValue];
  char msg[1024];
  while (1){
    int x = recv(client_socket, msg, sizeof(msg), 0);
    if (x <= 0){
      break;
    }
  }

  [pool release];
}
@end
