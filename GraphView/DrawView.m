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
/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "DrawView.h"
#include "Triva/NSPointFunctions.h"

@implementation DrawView
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  ratio = 1;
  scale = 1;
  return self;
}

- (BOOL) isFlipped
{
    return NO;
}

- (void) setFilter: (GraphView *)f
{
  filter = f;
}

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

- (NSAffineTransform*) transform
{
  NSAffineTransform* transform = [NSAffineTransform transform];
  [transform translateXBy: translate.x yBy: translate.y];
  [transform scaleXBy: ratio yBy: ratio];
  return transform;
}

- (void)drawRect:(NSRect)frame
{
  NSRect tela = [self bounds];

  //white fill on view
  [[NSColor whiteColor] set];
  NSRectFill(tela);

  //transformations
  NSAffineTransform *transform = [self transform];
  [transform concat];

  //set default line width based on ratio
  [NSBezierPath setDefaultLineWidth: 1/ratio];

  //draw nodes and edges
  NSEnumerator *en;
  TrivaGraphNode *node;
  TrivaGraphEdge *edge;
  en = [filter enumeratorOfEdges];
  while ((edge = [en nextObject])){
    if (![edge drawable]) continue;
    [edge refresh];
    [edge draw];
  }
  en = [filter enumeratorOfNodes];
  while ((node = [en nextObject])){
    if (![node drawable]) continue;
    [node refresh];
    [node draw];
  }

  //undo transformations
  [transform invert];
  [transform concat];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    [[self window] setAcceptsMouseMovedEvents: YES];
    return YES;
}

- (void) mouseDragged:(NSEvent *)event
{
  NSPoint p;
  p = [self convertPoint:[event locationInWindow] fromView:nil];
  if ([event modifierFlags] & NSControlKeyMask){
    //code for changing the position of a node
    if (selectedNode == nil) {
      return;
    }

    NSAffineTransform *t = [self transform];
    [t invert];
    NSPoint p2 = [t transformPoint: p];

    NSRect nodebb = [selectedNode bb];
    nodebb.origin.x = p2.x - nodebb.size.width/2;
    nodebb.origin.y = p2.y - nodebb.size.height/2;
    [selectedNode setBoundingBox: nodebb];
  }else{
    NSPoint dif;
    dif = NSSubtractPoints (p, move);
    if (NSEqualPoints (translate, NSZeroPoint)){
      translate = dif;
    }else{
      translate = NSAddPoints (translate, dif);
    }
    move = p;
  }
  [self setNeedsDisplay: YES];
}

- (void) mouseDown: (NSEvent *) event
{
  move = [self convertPoint:[event locationInWindow] fromView:nil];
}

- (void) mouseMoved:(NSEvent *)event
{
  NSPoint p, p2;
  p = [self convertPoint:[event locationInWindow] fromView:nil];

  NSAffineTransform *t = [self transform];
  [t invert];
  p2 = [t transformPoint: p];

  //search for nodes
  TrivaGraphNode *node;
  NSEnumerator *en = [filter enumeratorOfNodes];
  BOOL found = NO;
  while ((node = [en nextObject])){
    if(NSPointInRect (p2, [node bb])){
      if (selectedNode){
        [selectedNode setHighlight: NO];
      }
      selectedNode = node;
      [selectedNode setHighlight: YES];
      [self setNeedsDisplay: YES];
      found = YES;
      break;
    }
  }
  if (!found){
    if (selectedNode){
      [selectedNode setHighlight: NO];
      selectedNode = nil;
      [self setNeedsDisplay: YES];
    }
  }
}

- (void)scrollWheel:(NSEvent *)event
{
  if (([event modifierFlags] & NSControlKeyMask)){
    //change the scale of the drawing (used by GraphConfiguration filter)
    if ([event deltaY] > 0){
      scale += scale*0.1;
    }else{
      scale -= scale*0.1;
    }
    [filter graphComponentScalingChanged];
  }else{
    NSPoint b, a, p;
    NSAffineTransform *t;
 
    //register the transformed point before changing ratio
    p = [self convertPoint:[event locationInWindow] fromView:nil];
    t = [self transform];
    b = [t transformPoint: p];
 
    if ([event deltaY] > 0){
      ratio += ratio*0.1;
    }else{
      ratio -= ratio*0.1;
    }
 
    //register after changing ratio
    t = [self transform];
    a = [t transformPoint: p];
 
    //get the different before - after
    NSPoint p2 = NSSubtractPoints (b, a);
 
    //applies to the transformation variable
    if (NSEqualPoints (translate, NSZeroPoint)){
      translate = p2;
    }else{
      translate = NSAddPoints (translate, p2);
    }
  }
  [self setNeedsDisplay: YES];
}

- (void) printGraph
{
  static int counter = 0;
  NSPrintOperation *op;
  NSMutableData *data = [NSMutableData data];
  op = [NSPrintOperation EPSOperationWithView: self
                                   insideRect: [self bounds]
                                       toData: data];
  [op runOperation];
  NSString *filename = [NSString stringWithFormat: @"%03d-graph-%@-%@.eps",
    counter++, [filter selectionStartTime], [filter selectionEndTime]];
  [data writeToFile: filename atomically: YES];
  NSLog (@"screenshot written to %@", filename);
}

- (void)keyDown:(NSEvent *)theEvent
{
  if (([theEvent modifierFlags] | NSAlternateKeyMask) &&
    [theEvent keyCode] == 33){ //ALT + P
    [self printGraph];
  }else if (([theEvent modifierFlags] | NSAlternateKeyMask) &&
    [theEvent keyCode] == 26){

    TrivaGraphNode *node;
    NSEnumerator *en = [filter enumeratorOfNodes];
    while ((node = [en nextObject])){
      NSPoint p = [node bb].origin;
      NSLog (@"%@ = { x = %f; y = %f; };", [node name], p.x, p.y);
    }
    NSRect rect = [filter sizeForGraph];
    NSLog (@"Area = { x = %f; y = %f; width = %f; height = %f; };",
      rect.origin.x,
      rect.origin.y,
      rect.size.width,
      rect.size.height);
  }else if (([theEvent modifierFlags] | NSAlternateKeyMask) &&
    [theEvent keyCode] == 27){ //ALT + R
    [filter setRecordMode];
  }
}

- (double) scale
{
  return scale;
}
@end
