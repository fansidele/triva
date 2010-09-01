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
#include "TrivaGraphNode.h"
#include "NSPointFunctions.h"
#include <float.h>
#include <limits.h>

@implementation TrivaGraphNode
- (id) init
{
  self = [super init];
  bb = NSZeroRect;
  compositions = [[NSMutableDictionary alloc] init];
  currentOutsideBB = NSZeroRect;
  connectedNodes = [[NSMutableSet alloc] init];
  return self;
}

- (void) setType: (NSString *) n
{
  if (type){
    [type release];
  }
  type = n;
  [type retain];
}

- (NSString *) type
{
  return type;
}

- (void) setBoundingBox: (NSRect) b
{
  bb = b;
}

- (NSRect) bb
{
  return bb;
}

- (void) setDrawable: (BOOL) v
{
  drawable = v;
}

- (BOOL) drawable
{
  return drawable;
}

- (void) dealloc
{
  [compositions release];
  [connectedNodes release];
  [super dealloc];
}

- (void) refresh
{
  //check number of compositions that need space
  int count = 0;
  NSEnumerator *en = [compositions objectEnumerator];
  id composition;
  while ((composition = [en nextObject])){
    if ([composition needSpace]){
      count++;
    }
  }
  en = [compositions objectEnumerator];
  double accum_x = 0;
  currentOutsideBB = NSZeroRect;
  while ((composition = [en nextObject])){
    if ([composition needSpace]){
      NSRect rect = NSMakeRect (bb.origin.x + accum_x,
          bb.origin.y,
          bb.size.width/count,
          bb.size.height);
      [composition refreshWithinRect: rect];
      accum_x += bb.size.width/count;
    }else{
      //if there is more than one composition
      //draw them on the right of the node
      if (NSEqualRects (currentOutsideBB, NSZeroRect)){
        NSRect togo = NSMakeRect (bb.origin.x + bb.size.width + 1,
                                  bb.origin.y, 0, 0);
        [composition refreshWithinRect: togo];
      }else{
        NSRect togo = NSMakeRect (currentOutsideBB.origin.x +
                                        currentOutsideBB.size.width + 1,
                                  currentOutsideBB.origin.y, 0, 0);
        [composition refreshWithinRect: togo];
      }
      currentOutsideBB = [composition bb];
    }
  }
}

- (BOOL) draw
{
  //draw my components
  NSEnumerator *en = [compositions objectEnumerator];
  id comp;
  while ((comp = [en nextObject])){
    [comp draw];
  }

  //draw myself
  [[NSColor lightGrayColor] set];
  [NSBezierPath strokeRect: bb];

  return YES;
}

- (void) drawHighlight
{
  NSMutableString *str = [NSMutableString string];
  [str appendString: [self description]];
  [str appendString: @"\n"];
  //higlight components
  NSEnumerator *en = [compositions objectEnumerator];
  id comp;
  while ((comp = [en nextObject])){
    [str appendString: [comp description]];
  }
  //draw highlight text
  [str drawAtPoint: NSMakePoint (bb.origin.x + bb.size.width,
        bb.origin.y) withAttributes: nil];
}

- (void) setHighlight: (BOOL) highlight
{
  highlighted = highlight;
}

- (BOOL) highlighted
{
  return highlighted;
}

- (void) setTimeSliceTree: (TimeSliceTree *) t
{
  timeSliceTree = t;
}

- (void) addConnectedNode: (TrivaGraphNode*) n
{
  [connectedNodes addObject: n];
}

- (NSSet*) connectedNodes
{
  return connectedNodes;
}

- (BOOL) redefineLayoutWithConfiguration: (NSDictionary *) conf
                            withProvider: (TrivaFilter *) filter
                         withDifferences: (NSDictionary *) differences
                      andTimeSliceValues: (NSDictionary *) values
{
  //getting scale configuration for node
  TrivaScale scale;
  NSString *scaleconf = [conf objectForKey: @"scale"];
  if (!scaleconf){
    static int flag = 1;
    if (flag){
      NSLog (@"%s:%d: no 'scale' configuration for type %@."
        " Assuming its value as 'global'",
        __FUNCTION__, __LINE__, type);
      flag = 0;
    }
    scale = Global;
  }else{
    if ([scaleconf isEqualToString: @"global"]) {
      scale = Global;
    }else if ([scaleconf isEqualToString: @"local"]){
      scale = Local;
    }else{
      NSLog (@"%s:%d: unknow 'scale' configuration value "
        "(%@) for type %@",
        __FUNCTION__, __LINE__, scaleconf, type);
      return NO;
    }
  }

  //getting size configuration for node
  NSString *sizeconf = [conf objectForKey: @"size"];
  if (!sizeconf) {
    NSLog (@"%s:%d: no 'size' configuration for type %@",
      __FUNCTION__, __LINE__, type);
    return NO;
  }

  //check to see if there is difference in size
  if (differences){

    //only check if size is a variable
    if ([filter expressionHasVariables: sizeconf]){
      double val = [[differences objectForKey: sizeconf] doubleValue];
      if (val != 0){
        //platform is different, abort
        NSLog (@"%s:%d: 'size' configuration for type %@ (node %@) "
              "has different values during comparison",
          __FUNCTION__, __LINE__, type, name);
        return NO;
      }
    }
  }

  //getting max and min for size of node (integrate them in time slice)
  //size is mandatory
  double min, max;
  double screenSize;
  if ([filter expressionHasVariables: sizeconf]){
    [filter defineMax: &max
               andMin: &min
            withScale: scale
         fromVariable: sizeconf
             ofObject: name
             withType: type];
    double size = [filter evaluateWithValues: values withExpr: sizeconf];
    screenSize = [filter calculateScreenSizeBasedOnValue: size
                                                  andMax: max
                                                  andMin: min];
  }else{
    screenSize = [sizeconf doubleValue];
  }
  bb.size.width = screenSize;
  bb.size.height = screenSize;
/*
  //converting from graphviz center point to top-left origin
  if (userPositions == NO){
    bb.origin.x = bb.origin.x - bb.size.width/2;
    bb.origin.y = bb.origin.y - bb.size.height/2;
  }
*/

  //iterating through compositions
  NSMutableArray *ar = [NSMutableArray arrayWithArray: [conf allKeys]];
  NSEnumerator *en = [ar objectEnumerator];
  NSString *compositionName;
  while ((compositionName = [en nextObject])){
    NSDictionary *compconf = [conf objectForKey: compositionName];
    if (![compconf isKindOfClass: [NSDictionary class]])
      continue; //ignore if not dict
    if (![compconf count])
      continue; //ignore if dictionary is empty

    //check if composition already exist
    TrivaComposition *comp = [compositions objectForKey: compositionName];
    if (comp){
      //redefineLayout of Composition
      [comp redefineLayoutWithValues: values];
    }else{
      comp = [TrivaComposition compositionWithConfiguration: compconf
                                                   withName: compositionName
                                                  forObject: self
                                            withDifferences: differences
                                                 withValues: values
                                                andProvider: filter];
      [compositions setObject: comp forKey: compositionName];
    }
  }
  [self setDrawable: YES];
  return YES;
}

- (NSString *) description
{
  return [NSString stringWithFormat: @"%@ - %@", type, name];
}

- (BOOL) mouseInside: (NSPoint) mPoint
{
  return NSPointInRect (mPoint, bb);
}
@end
