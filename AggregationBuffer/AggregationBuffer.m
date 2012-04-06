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
#include "AggregationBuffer.h"

@implementation AggregationBuffer
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
    cache = [[NSMutableDictionary alloc] init];
    sliceDuration = -1;
  }
  return self;
}

- (void) dealloc
{
  [cache release];
  [super dealloc];
}

- (NSDictionary *) spatialIntegrationOfContainer: (PajeContainer *) cont
{
  NSString *key = [NSString stringWithFormat: @"%@-%@",
                            selectionStartTime, selectionEndTime];
  NSMutableDictionary *cached = [cache objectForKey: key];
  if (cached){
    NSDictionary *old = [cached objectForKey: cont];
    if (!old){
      old = [super spatialIntegrationOfContainer: cont];
      [cached setObject: old forKey: cont];
    }
    return old;
  }else{
    cached = [NSMutableDictionary dictionary];
    NSDictionary *new = [super spatialIntegrationOfContainer: cont];
    [cached setObject: new forKey: cont];
    [cache setObject: cached forKey: key];
    return new;
  }
}

- (void) timeSelectionChanged
{
  [selectionStartTime release];
  [selectionEndTime release];
  selectionStartTime = [self selectionStartTime];
  selectionEndTime = [self selectionEndTime];
  [selectionStartTime retain];
  [selectionEndTime retain];
  double tsDuration = [selectionEndTime timeIntervalSinceDate:
                                          selectionStartTime];
  if (tsDuration != sliceDuration){
    //if the size of the time slice has changed, reset cache
    [cache removeAllObjects];
    sliceDuration = tsDuration;
  }
  [super timeSelectionChanged];
}

- (void) hierarchyChanged
{
  [cache removeAllObjects];
  [super hierarchyChanged];
}

- (void) containerSelectionChanged
{
  [cache removeAllObjects];
  [super containerSelectionChanged];
}

- (void) entitySelectionChanged
{
  [cache removeAllObjects];
  [super entitySelectionChanged];
}

- (void) dataChangedForEntityType: (PajeEntityType *) type
{
  [cache removeAllObjects];
  [super dataChangedForEntityType: type];
}
@end
