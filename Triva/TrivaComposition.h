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
#ifndef __TrivaComposition_h_
#define __TrivaComposition_h_
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include <Triva/Tree.h>
#include <Triva/TimeSliceTree.h>
#include <Triva/TrivaFilter.h>
#include <Triva/TrivaGraphNode.h>

@class TrivaGraphNode;
@class TrivaFilter;

@interface TrivaComposition : NSObject
{
  NSString *name;
  NSRect bb; //the bounding box
  TrivaGraphNode *node; //to which node this composition is part of
  NSDictionary *configuration;

  BOOL needSpace;
  TrivaFilter *filter;
}
+ (id) compositionWithConfiguration: (NSDictionary*) conf
                           withName: (NSString*) n
                          forObject: (TrivaGraphNode*)obj
                    withDifferences: (NSDictionary*) differences
                         withValues: (NSDictionary*) timeSliceValues
                        andProvider: (TrivaFilter*) prov;
- (id) initWithConfiguration: (NSDictionary*) conf
                    withName: (NSString*) n
                   forObject: (TrivaGraphNode*)obj
             withDifferences: (NSDictionary*) differences
                  withValues: (NSDictionary*) timeSliceValues
                 andProvider: (TrivaFilter*) prov;
- (id) initWithFilter: (TrivaFilter *) f
     andConfiguration: (NSDictionary *) conf
             andSpace: (BOOL) s
              andName: (NSString*) name
            andObject: (TrivaGraphNode *)obj;

- (void) redefineLayoutWithValues: (NSDictionary*) timeSliceValues;
- (BOOL) needSpace;
- (void) refreshWithinRect: (NSRect) rect;
- (BOOL) draw;
- (NSRect) bb;
- (NSString*) name;
- (BOOL) mouseInside: (NSPoint)mPoint
       withTransform: (NSAffineTransform*)transform;
@end

#endif
