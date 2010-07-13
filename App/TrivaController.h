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
#ifndef TrivaController_h_
#define TrivaController_h_

#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <General/PSortedArray.h>

@class TrivaComparisonController;

@interface TrivaController : NSObject
{
  id reader;
  id encapsulator;

  NSMutableDictionary *bundles;
  NSMutableDictionary *components;
}
+ (id) controllerWithArguments: (struct arguments) arguments;
- (void) setInputFiles: (NSArray *) files;
@end

@interface TrivaController (Bundles)
- (NSBundle *)loadTrivaBundleNamed:(NSString*)name;
- (NSBundle *)bundleWithName:(NSString *)name;
- (NSBundle *)loadBundleNamed:(NSString*)name;
@end

@interface TrivaController (Chunks)
- (void)missingChunk:(int)chunkNumber;
- (void)readAllTracefileFrom: (id) r;

- (NSDate *) startTime; //starttime of the encapsulator
- (NSDate *) endTime; //endtime of the encapsulator
- (BOOL) hasMoreData;
- (void)setSelectionStartTime:(NSDate *)from
                      endTime:(NSDate *)to;
@end

@interface TrivaController (Components)
- (id)createComponentWithName:(NSString *)componentName
                 ofClassNamed:(NSString *)className
               withDictionary:(NSMutableDictionary *) comps;
- (void)connectComponent:(id)c1 toComponent:(id)c2;
- (id)componentWithName:(NSString *)name
         fromDictionary:(NSMutableDictionary *) comps;
- (void)connectComponentNamed:(NSString *)n1
             toComponentNamed:(NSString *)n2
               fromDictionary:(NSMutableDictionary *) comps;
- (void)addComponentSequence:(NSArray *)componentSequence
              withDictionary:(NSMutableDictionary *) comps;
- (void)addComponentSequences:(NSArray *)componentSequences
              withDictionary:(NSMutableDictionary *) comps;
@end

/*
 * Triva Controllers
 */
@interface TrivaTreemapController : TrivaController
@end

@interface TrivaGraphController : TrivaController
@end

@interface TrivaLinkController : TrivaController
@end

@interface TrivaDotController : TrivaController
@end

@interface TrivaCheckController : TrivaController
@end

@interface TrivaListController : TrivaController
@end

@interface TrivaInstanceController : TrivaController
@end

#include "TrivaComparisonController.h"

#endif
