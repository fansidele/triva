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

@implementation TrivaController (Chunks)
- (void)missingChunk:(int)chunkNumber
{
  NSString *str;
  str = [NSString stringWithFormat:
    @"%@: %s received by TrivaController.", self, __FUNCTION__];
  [[NSException exceptionWithName: @"Triva" 
        reason: str
        userInfo: nil] raise];
}

- (void)readAllTracefileFrom: (id)r
{
  int chunkNumber = 0;
  NSFileManager *fm = [NSFileManager defaultManager];
  NSDictionary *dict = [fm fileAttributesAtPath: [r inputFilename]
                                   traverseLink: NO];
  unsigned long long fileSize = [dict fileSize];

  //set chunk size
  [r setUserChunkSize: fileSize];

  //read up to the end
  while ([r hasMoreData]){
    [r startChunk: chunkNumber++];
    [r readNextChunk];
    [r endOfChunkLast: ![r hasMoreData]];
  }
}

- (NSDate *) startTime
{
  return [encapsulator startTime];
}

- (NSDate *) endTime
{
  return [encapsulator endTime];
}

- (BOOL) hasMoreData
{
        return [reader hasMoreData];
}
@end
