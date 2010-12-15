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
#ifndef TrivaServerSocket_h_
#define TrivaServerSocket_h_

#include <Foundation/Foundation.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <Triva/TrivaConfiguration.h>

@interface TrivaServerSocket : NSObject
{
  BOOL keepListening;
  int server_port;
  int server_socket;
  struct sockaddr_in sin;
}
- (id) initWithPort: (int) port;
- (void) stopServer;
- (void) runServer: (id) sender;
- (void) serveClient: (id) controller;
- (int) getLineWithBuffer: (char**) buf
                  andSize: (size_t*) n
                andStream: (FILE*) stream;
@end

#endif
