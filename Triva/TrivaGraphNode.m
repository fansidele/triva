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

- (NSRect) boundingBox
{
  return bb;
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
  NSRect currentOutsideBB = NSZeroRect;
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
  NSBezierPath *border = [NSBezierPath bezierPathWithRect: bb];
  if (compositionHighlighted){
    [[NSColor redColor] set];
    [border setLineWidth: 2]; 
  }else{
    [[NSColor lightGrayColor] set];
  }
  [border stroke];
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
  //draw highlight text in the highlighPoint
  [str drawAtPoint: highlightPoint withAttributes: nil];
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
  //getting the type of this node (should it be drawn as a NODE or as a EDGE
  NSString *drawType = [conf objectForKey: @"type"];
  if ([drawType isEqualToString: @"node"]){
    drawingType = TRIVA_NODE;
  }else if ([drawType isEqualToString: @"edge"]){
    drawingType = TRIVA_EDGE;
  }else{
    //FIXME
    NSLog (@"FIXME %s:%d", __FUNCTION__, __LINE__);
    exit(1);
  }

  //getting size configuration for node
  NSString *sizeconf = [conf objectForKey: @"size"];
  if (!sizeconf) {
    NSLog (@"%s:%d: no 'size' configuration for type %@",
      __FUNCTION__, __LINE__, type);
    return NO;
  }

  //getting max and min for size of node (within time slice)
  //size is mandatory
  double screenSize;
  if ([filter expressionHasVariables: sizeconf]){
    double max = [filter maxOfVariable: sizeconf withScale: scale
                          ofObject: name withType: type];
    double min = [filter minOfVariable: sizeconf withScale: scale
                          ofObject: name withType: type];
    double size = [filter evaluateWithValues: values withExpr: sizeconf];
//    screenSize = [filter calculateScreenSizeBasedOnValue: size
//                                                andMax: max
//                                                andMin: min];
  }else{
    screenSize = [sizeconf doubleValue];
  }
  bb.size.width = screenSize;
  bb.size.height = screenSize;

  //iterating through compositions
  NSMutableArray *ar = [NSMutableArray arrayWithArray: [conf allKeys]];
  NSEnumerator *en = [ar objectEnumerator];
  NSString *compositionName;
  compositionHighlighted = NO;
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
      compositionHighlighted |= [comp redefineLayoutWithValues: values];
    }else{
      comp = [TrivaComposition compositionWithConfiguration: compconf
                                                   withName: compositionName
                                                  forObject: self
                                            withDifferences: differences
                                                 withValues: values
                                                andProvider: filter];
      compositionHighlighted |= [comp redefineLayoutWithValues: values];
      [compositions setObject: comp forKey: compositionName];
    }
  }
  return YES;
}

- (NSString *) description
{
  return [NSString stringWithFormat: @"%@ - %@", type, name];
}

- (BOOL) mouseInside: (NSPoint) mPoint
{
  [self mouseInsideCompositions: mPoint withTransform: nil];
  return NSPointInRect (mPoint, bb);
}

- (BOOL) mouseInsideCompositions: (NSPoint) mPoint
                   withTransform: (NSAffineTransform*)transform
{
  //save highlight point
  highlightPoint = mPoint;

  //do the job
  NSEnumerator *en = [compositions objectEnumerator];
  id comp;
  BOOL found = NO;
  while ((comp = [en nextObject])){
    found = [comp mouseInside: mPoint withTransform: transform];
  }
  return found;
}

- (NSUInteger)hash
{
  return [name hash];
}

- (BOOL)isEqual:(id)anObject
{
  return [name isEqual: [anObject name]];
}
@end
