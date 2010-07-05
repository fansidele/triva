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
#include "TrivaController.h"
#include "config.h"

@implementation TrivaController (Chunks)
- (void)readChunk:(int)chunkNumber
{
  [reader readNextChunk];
}

- (void)startChunk:(int)chunkNumber
{
    [reader startChunk:chunkNumber];
    if ([reader hasMoreData] && (unsigned int)chunkNumber >= [chunkDates count]) {
//        [chunkDates addObject:[simulator currentTime]];
        timeLimitsChanged = YES;
    }
}

- (void)endOfChunkLast:(BOOL)last
{
    [reader endOfChunkLast:last];
    if (timeLimitsChanged) {
        [encapsulator timeLimitsChanged];
        timeLimitsChanged = NO;
    }
}

- (void)missingChunk:(int)chunkNumber
{
  NSString *str;
  str = [NSString stringWithFormat:
    @"%@: %s received by TrivaController.", self, __FUNCTION__];
  [[NSException exceptionWithName: @"Triva" 
        reason: str
        userInfo: nil] raise];
//    [self readChunk:chunkNumber];
}

#define CHUNK_SIZE (10*1024*1024)

- (int)readNextChunk:(id)sender
{
  static BOOL chunkStarted = NO;
  if (!chunkStarted){
    [self startChunk: [chunkDates count]];
    chunkStarted = YES;
  }

  [self readChunk: -1 /* method ignores this number */];

  if (![reader hasMoreData] && chunkStarted){
    [self endOfChunkLast: ![reader hasMoreData]];
    chunkStarted = NO;
  }

  if ([reader hasMoreData]){
    return 1;
  }else{
    return 0;
  }
}

- (void)chunkFault:(NSNotification *)notification
{
    int chunkNumber;

    chunkNumber = [[[notification userInfo]
                          objectForKey:@"ChunkNumber"] intValue];
    [self readChunk:chunkNumber];
}

- (NSDate *) startTime
{
  return [encapsulator startTime];
}

- (NSDate *) endTime
{
  return [encapsulator endTime];
}

- (void) setReaderWithName: (NSString *) readerName
{
  reader = [self componentWithName: readerName];
}

- (BOOL) hasMoreData
{
        return [reader hasMoreData];
}

- (void)setSelectionStartTime:(NSDate *)from
                      endTime:(NSDate *)to
{
    [encapsulator setSelectionStartTime:from
                                  endTime:to];
}

- (void) addParameter: (NSString *) par
{
  if (parameters == nil){
    parameters = [[NSMutableArray alloc] init];
  }else{
    [parameters addObject: par];
  }
}

- (NSString *) getParameterNumber: (int) index
{
  if ((unsigned int)index < [parameters count]){
    return [parameters objectAtIndex: index];
  }else{
    return nil;
  }
}
@end
