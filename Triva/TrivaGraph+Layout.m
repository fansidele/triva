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
#include "TrivaGraph.h"

@implementation TrivaGraph (Layout)
- (void) recursiveLayout
{
  if ([self expanded] == NO){
    [self layout];
  }else{
    //recurse
    NSEnumerator *en = [children objectEnumerator];
    TrivaGraph *child;
    while ((child = [en nextObject])){
      [child recursiveLayout];
    }
  }
}

- (void) layout
{
  //calculate my bounding box based on my compositions
  NSRect nbb = NSZeroRect;
  NSEnumerator *en = [compositions objectEnumerator];
  TrivaComposition *composition;
  while ((composition = [en nextObject])){
    [composition layout];
    NSRect compbb = [composition bb];
    nbb.size.width += compbb.size.width;
    nbb.size.height = fmax (nbb.size.height, compbb.size.height);
  }
  [self setBoundingBox: nbb];
}

- (void) recursiveDrawLayout
{
  if ([self expanded] == NO){
    [self drawLayout];
  }else{
    //recurse
    NSEnumerator *en = [children objectEnumerator];
    TrivaGraph *child;
    while ((child = [en nextObject])){
      [child recursiveDrawLayout];
    }
  }
}

- (void) drawCompositions
{
  NSEnumerator *en = [compositions objectEnumerator];
  TrivaComposition *composition;
  double composition_origin = 0;
  while ((composition = [en nextObject])){
    NSAffineTransform *t = [NSAffineTransform transform];    
    [t translateXBy: composition_origin yBy: 0];
    [t concat];
    [composition drawLayout];
    [t invert];
    [t concat];
    composition_origin += [composition bb].size.width;
  }  
}

- (void) drawLayout
{
  NSAffineTransform *t = [NSAffineTransform transform];
  [t translateXBy: location.x - bb.size.width/2
              yBy: location.y - bb.size.height/2];
  [t concat];

  //draw my compositions
  [self drawCompositions];

  //draw myself
  if ([self highlighted]){
    [[NSColor redColor] set];
    double m = .05;
    NSRect x = NSMakeRect (bb.origin.x - bb.size.width*m,
                           bb.origin.y - bb.size.height*m,
                           bb.size.width + 2*bb.size.width*m,
                           bb.size.height + 2*bb.size.height*m);
    [[NSBezierPath bezierPathWithRect: x] stroke];
  }else{
    [[NSColor lightGrayColor] set];
  }
  // if ([children count]){
  //   NSBezierPath *path = [NSBezierPath bezierPath];
  //   [path appendBezierPathWithArcWithCenter: NSMakePoint(bb.size.width,
  //                                                        bb.size.height)
  //                                    radius: 5
  //                                startAngle: 270
  //                                  endAngle: 180];
  //   [path fill];
  // }

  [t invert];
  [t concat];
}
@end
