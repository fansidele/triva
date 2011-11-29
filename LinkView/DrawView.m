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
#include <AppKit/AppKit.h>
#include "DrawView.h"

@implementation DrawView
- (id)initWithFrame:(NSRect)frameRect
{
  self = [super initWithFrame: frameRect];
  maxDepthToDraw = 0;
  updateCurrentTreemap = YES;
  return self;
}

- (BOOL) isFlipped
{
  return YES;
}

- (void) setFilter: (LinkView *)f
{
  filter = f;
}

/*
- (NSColor *) getColor: (NSColor *)c withSaturation: (double) saturation
{
  if (![[c colorSpaceName] isEqualToString:
      @"NSCalibratedRGBColorSpace"]){
    NSLog (@"%s:%d Color provided is not part of the "
        "RGB color space.", __FUNCTION__, __LINE__);
    return nil;
  }
  float h, s, b, a;
  [c getHue: &h saturation: &s brightness: &b alpha: &a];

  NSColor *ret = [NSColor colorWithCalibratedHue: h
    saturation: saturation
    brightness: b
    alpha: a];
  return ret;
}
*/

- (void) drawRecursive: (LinkViewNode *)node
{
  if ([node depth] == maxDepthToDraw+1){
    return;
  }
  [node draw];
  if ([node depth] == maxDepthToDraw){
    [node drawEdges];
  }
  int i;
  for (i = 0; i < [[node children] count]; i++){
    [self drawRecursive:[[node children] objectAtIndex: i]];
  }
}

- (void)drawRect:(NSRect)frame
{
  double offset = 2;

  NSRect tela = [self bounds];

  if (updateCurrentTreemap){
    [filter resetNodes];

    TimeSliceTree *tree = [filter timeSliceTree];
    current = [[LinkViewNode alloc] initWithTimeSliceTree: tree
                                                          andProvider: filter];
    [current setOffset: offset];
    [current setBoundingBox: tela];
    [current refresh];
  }
  [self drawRecursive: current];
  updateCurrentTreemap = YES;
}

- (void)scrollWheel:(NSEvent *)event
{
  if ([event deltaY] > 0){
    if (maxDepthToDraw < [current maxDepth]){
      maxDepthToDraw++;
      updateCurrentTreemap = NO;
      [self setNeedsDisplay: YES];
    }
  }else{
    if (maxDepthToDraw > 0){
      maxDepthToDraw--;
      updateCurrentTreemap = NO;
      [self setNeedsDisplay: YES];
    }
  }
}
@end
