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
#include "CheckTrace.h"
#include <sys/time.h>

static double gettime ()
{
        struct timeval tr;
        gettimeofday(&tr, NULL);
        return (double)tr.tv_sec+(double)tr.tv_usec/1000000;
}

@implementation CheckTrace
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
  }
  return self;
}

- (void)iteraNosDados:(id)instance level:(int)level
{
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
            }
        }
    }
}

- (void)hierarchyChanged
{
    double t1, t2;
    t1 = gettime();
    [self iteraNosDados:[self rootInstance] level:0];
    t2 = gettime();
    NSLog (@"Time to traverse: %f", t2 - t1);
    exit(0);
}

@end
