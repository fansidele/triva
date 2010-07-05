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
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <General/PSortedArray.h>

@interface TrivaController : NSObject
{
  id reader;
  id simulator;
  id encapsulator;

  NSMutableDictionary *bundles;
  NSMutableDictionary *components;

  PSortedArray *chunkDates;
  BOOL timeLimitsChanged;

  NSMutableArray *parameters;
}
+ (NSArray *)treemapComponentGraph;
+ (NSArray *)graphComponentGraph;
+ (NSArray *)linkViewComponentGraph;
+ (NSArray *)dotComponentGraph;
+ (NSArray *)checkTraceComponentGraph;
+ (NSArray *)listComponentGraph;
+ (NSArray *)instancesComponentGraph;

- (void)activateTreemap;
- (void)activateGraph;
- (void)activateLinkView;
- (void)activateDot;
- (void)activateCheckTrace;
- (void)activateList;
- (void)activateInstances;
- (void)defineMajorComponents;
@end

@interface TrivaController (Bundles)
- (NSBundle *)loadTrivaBundleNamed:(NSString*)name;
- (NSBundle *)bundleWithName:(NSString *)name;
- (NSBundle *)loadBundleNamed:(NSString*)name;
@end

@interface TrivaController (Chunks)
- (void)readChunk:(int)chunkNumber;
- (void)startChunk:(int)chunkNumber;
- (void)endOfChunkLast:(BOOL)last;
- (void)missingChunk:(int)chunkNumber;
- (int)readNextChunk:(id)sender;
- (void)chunkFault:(NSNotification *)notification;
- (NSDate *) startTime; //starttime of the encapsulator
- (NSDate *) endTime; //endtime of the encapsulator
- (void) setReaderWithName: (NSString *) readerName;
- (BOOL) hasMoreData;
- (void)setSelectionStartTime:(NSDate *)from
                      endTime:(NSDate *)to;
- (void) addParameter: (NSString *) par;
- (NSString *) getParameterNumber: (int) index;
@end

@interface TrivaController (Components)
- (id)createComponentWithName:(NSString *)componentName
                 ofClassNamed:(NSString *)className;
- (void)connectComponent:(id)c1 toComponent:(id)c2;
- (id)componentWithName:(NSString *)name;
- (void)connectComponentNamed:(NSString *)n1
             toComponentNamed:(NSString *)n2;
- (void)addComponentSequence:(NSArray *)componentSequence;
- (void)addComponentSequences:(NSArray *)componentSequences;
@end
