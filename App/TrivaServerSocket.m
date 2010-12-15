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
  NSException *ex;
  NSString *reason;

  server_socket = socket (AF_INET, SOCK_STREAM, 0);
  if (server_socket < 0){
    reason = [NSString stringWithFormat: @"server socket creation failed"];
    ex = [NSException exceptionWithName: @"TrivaServerSocketException"
                                 reason: reason
                               userInfo: nil];
    [ex raise];
    return nil;
  }

  sin.sin_family = AF_INET;
  sin.sin_port = htons(server_port);
  sin.sin_addr.s_addr  = INADDR_ANY;

  int b = bind (server_socket, (struct sockaddr *)&sin, sizeof(sin));
  if (b < 0){
    reason = [NSString stringWithFormat:
                @"binding failed (server socket port %d)", server_port];
    ex = [NSException exceptionWithName: @"TrivaServerSocketException"
                                 reason: reason
                               userInfo: nil];
    [ex raise];
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
  NSException *ex;
  NSString *reason;

  if (listen(server_socket, 1)) {
    reason = [NSString stringWithFormat:
                    @"listen failed (port %d)", server_port];
    ex = [NSException exceptionWithName: @"TrivaServerSocketException"
                                 reason: reason
                               userInfo: nil];
    [ex raise];
    return;
  }

  NSLog (@"TrivaServerSocket running on port %d", server_port);

  unsigned int sinlen = sizeof (sin);
  while (keepListening){
    int client = accept(server_socket, (struct sockaddr *) &sin, &sinlen);
    if (client < 0){
      reason = [NSString stringWithFormat:
                    @"accept failed (port %d)", server_port];
      ex = [NSException exceptionWithName: @"TrivaServerSocketException"
                                 reason: reason
                               userInfo: nil];
      [ex raise];
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

- (int) getLineWithBuffer: (char**) buf
                  andSize: (size_t*) n
                andStream: (FILE*) stream
{
  size_t i;
  int ch;

  if (!*buf) {
    *buf = malloc(512);
    *n = 512;
  }

  if (feof(stream))
    return (ssize_t) - 1;

  for (i = 0; (ch = fgetc(stream)) != EOF; i++) {
    if (ch == '\r') { i--; continue; };

    if (i >= (*n) + 1)
      *buf = realloc(*buf, *n += 512);

    (*buf)[i] = ch;

    if ((*buf)[i] == '\n') {
      //i++;
      (*buf)[i] = '\0';
      break;
    }
  }

  if (i == *n)
    *buf = realloc(*buf, *n += 1);

  (*buf)[i] = '\0';

  return (ssize_t) i;
}

- (void) serveClient: (id) controller
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSDictionary *dict = [[NSThread currentThread] threadDictionary];
  int client_socket = [[dict objectForKey: @"client"] intValue];
  FILE *stream = fdopen (client_socket, "r");
  if (stream == NULL) return;
  while (1){
    char *buffer = NULL;
    size_t length = 0;
    ssize_t read;

    read = [self getLineWithBuffer: &buffer andSize: &length andStream: stream];
    if (read <= 0) break;
    NSString *message;
    TrivaConfiguration *conf = nil;
    message = [NSString stringWithFormat: @"%s", buffer];
NS_DURING
    conf = [[TrivaConfiguration alloc] initWithString: message
                             andDefaultOptions: [controller defaultOptions]];
NS_HANDLER
    NSLog (@"Exception on creating the configuration.");
    NSLog (@"Info: %@", [localException userInfo]);
    NSLog (@"Name: %@", [localException name]);
    NSLog (@"Reason: %@", [localException reason]);
    NSLog (@"Socket message: [%@]", message);
    continue;
NS_ENDHANDLER
    [conf removeAllInputFiles]; //socket-based conf without opening of files
    [conf setIgnore: YES];
    if ([conf configurationState] == TrivaConfigurationOK){
      [controller
                performSelectorOnMainThread: @selector(updateWithConfiguration:)
                                 withObject: conf
                              waitUntilDone: YES];
    }
    [conf release];
    free (buffer);
  }
  close (client_socket);

  [pool release];
}
@end
