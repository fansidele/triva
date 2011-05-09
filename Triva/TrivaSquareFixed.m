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
#include "TrivaSquareFixed.h"

@implementation TrivaSquareFixed
- (id) initWithConfiguration: (NSDictionary*) conf
                        name: (NSString*) n
                      values: (NSDictionary*) val
                        node: (TrivaGraph*) obj
                      filter: (TrivaFilter*) f
{
  self = [super initWithConfiguration: conf
                                 name: n
                               values: val
                                 node: obj
                               filter: f];

  NSArray *filterConf = [configuration objectForKey: @"filter"];
  if (!filterConf){
    NSLog (@"%s:%d: no 'filter' configuration for composition %@",
                        __FUNCTION__, __LINE__, configuration);
    return nil;
  }

  NSString *myType = [[[obj container] entityType] description];
  NSSet *set = [NSSet setWithArray: filterConf];
  if (![set containsObject: myType]){
    return nil;
  }

  NSString *sizeConf = [configuration objectForKey: @"size"];
  if (!filterConf){
    NSLog (@"%s:%d: no 'size' configuration for composition %@",
                        __FUNCTION__, __LINE__, configuration);
    return nil;
  }
  size = [sizeConf doubleValue];
  return self;
}

- (void) dealloc
{
  [super dealloc];
}

- (void) layout
{
  bb = NSMakeRect(0,0,size,size);
}

- (void) setBoundingBox: (NSRect) rect
{
  bb = rect;
}

- (void) drawLayout
{
  NSBezierPath *path = [NSBezierPath bezierPathWithRect: bb];
  [[NSColor blackColor] set];
  [path fill];
}

- (NSRect) bb
{
  return bb;
}

- (NSString *) description
{
  return nil;
}

- (BOOL) pointInside: (NSPoint)mPoint
{
  return NSPointInRect(mPoint, bb);
}
@end
