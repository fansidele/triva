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
#include "StatTrace.h"
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

static double gettime ()
{
        struct timeval tr;
        gettimeofday(&tr, NULL);
        return (double)tr.tv_sec+(double)tr.tv_usec/1000000;
}

static int pega_memoria ()
{
  int pid = getpid();
  char command[200];
  snprintf (command, 200, "cat /proc/%d/status | grep VmSize| awk {'print $2'} > /tmp/pegando-memoria", pid);
  int y = system (command);
  if (y == -1){
    perror ("");
    return -1;
  }
  FILE *file = fopen ("/tmp/pegando-memoria", "r");
  if (!file) {
    perror ("");
    return -2;
  }
  int ret;
  int x = fscanf (file, "%d", &ret);
  if (!x){
    perror ("");
    ret = -3;
  }
  snprintf (command, 200, "rm /tmp/pegando-memoria");
  y = system(command);
  return ret;
}


@implementation StatTrace
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
  }
  nContainer = nState = nEvent = nVariable = nLink = 0;
  memUsed = 0;
  return self;
}

- (void)iteraNosDados:(id)instance level:(int)level
{
  nContainer++;

  PajeEntityType *et;
  NSEnumerator *en;
  en = [[self containedTypesForContainerType:[self entityTypeForEntity:instance]] objectEnumerator];
  while ((et = [en nextObject]) != nil) {
      if ([self isContainerEntityType:et]) {
          NSEnumerator *en2;
          PajeContainer *sub;
          en2 = [self enumeratorOfContainersTyped:et inContainer:instance];
          while ((sub = [en2 nextObject]) != nil) {
              [self iteraNosDados:sub level:level+2];
          }
      } else {
          NSEnumerator *en3;
          PajeEntity *ent;
          en3 = [self enumeratorOfEntitiesTyped:et
                                    inContainer:instance
                                       fromTime:[self startTime]
                                         toTime:[self endTime]
                                    minDuration:0];
          while ((ent = [en3 nextObject]) != nil) {
            PajeEntityType *type = [ent entityType];
            if ([type isKindOfClass: [PajeStateType class]]){
              nState++;
            }else if ([type isKindOfClass: [PajeVariableType class]]){
              nVariable++;
            }else if ([type isKindOfClass: [PajeEventType class]]){
              nEvent++;
            }else if ([type isKindOfClass: [PajeLinkType class]]){
              nLink++;
            }
          }
      }
  }
}

- (void)hierarchyChanged
{
  memUsed = pega_memoria();

  double t1 = gettime();
  [self iteraNosDados:[self rootInstance] level:0];
  double t2 = gettime();
  NSLog (@"Tracefile: %@", [self traceDescription]);
  NSLog (@"Trace time: [%@ %@]", [self startTime], [self endTime]);
  NSLog (@"Containers: %d", nContainer);
  NSLog (@"States: %d", nState);
  NSLog (@"Events: %d", nEvent);
  NSLog (@"Variables: %d", nVariable);
  NSLog (@"Links: %d", nLink);
  NSLog (@"Virtual Memory used (Mbytes): %d", (memUsed)/1024);
  NSLog (@"Traverse time (in seconds): %f", t2-t1);
  t1 = gettime();
  [self spatialIntegrationOfContainer: [self rootInstance]];
  t2 = gettime();
  NSLog (@"Time/Spatial Aggregation (in seconds): %f", t2-t1);
  [NSApp terminate: self];
}

@end
