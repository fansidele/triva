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
#include "Triva/NSPointFunctions.h"

@implementation DrawView
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  translate = NSZeroPoint;
  move = NSZeroPoint;
  ratio = 1;

  movingSingleNode = NO;
  selectingArea = NO;
  selectedArea = NSZeroRect;

  highlighted = nil;
  return self;
}

- (BOOL) isFlipped
{
    return NO;
}

- (void) setFilter: (GraphView *)f
{
  filter = f;
  [self setCurrentRoot: [filter tree]];
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

- (void)drawTree:(TrivaGraph*)tree
{
  if ([tree expanded]){
    //recurse
    NSEnumerator *en = [[tree children] objectEnumerator];
    TrivaGraph *child;
    while ((child = [en nextObject])){
      [self drawTree: child];
    }
  }else{
    [tree drawLayout];
  }
}

- (void)drawRect:(NSRect)frame
{
  if (currentRoot == nil){
    [self setCurrentRoot: [filter tree]];
  }
 // [currentRoot refreshWithBoundingBox: [self bounds]];
  [self drawTree: currentRoot];

  NSRect tela = [self bounds];

  //white fill on view
  [[NSColor whiteColor] set];
  NSRectFill(tela);

  //draw the name of the file
  [[filter traceDescription]
                          drawAtPoint: NSMakePoint(0,0)
                       withAttributes: nil];

  //set default line width based on ratio
  [NSBezierPath setDefaultLineWidth: 1/ratio];


  NSAffineTransform *transform = [self transform];
  [transform concat];
  [self drawTree: currentRoot];
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
    //if something should be done for this event, do it here
    NSPoint dif;
    dif = NSSubtractPoints (p, move);
    if (NSEqualPoints (translate, NSZeroPoint)){
      translate = dif;
    }else{
      translate = NSAddPoints (translate, dif);
    }
    move = p;
 
    [self setNeedsDisplay: YES];
  }else{

    if (movingSingleNode){
      //code for changing the position of a node
      if (highlighted == nil) {
        return;
      }

      NSAffineTransform *t = [self transform];
      [t invert];
      NSPoint p2 = [t transformPoint: p];

      NSRect nodebb = [highlighted boundingBox];
      nodebb.origin.x = p2.x - nodebb.size.width/2;
      nodebb.origin.y = p2.y - nodebb.size.height/2;
      [highlighted setBoundingBox: nodebb];
      [self setNeedsDisplay: YES];
    }
  }
  return;
/*
  if (selectingArea){
    NSAffineTransform *t = [self transform];
    [t invert];
    NSPoint b = [t transformPoint: p];
    NSPoint a = selectedArea.origin;
 
    NSPoint origin, diagonal;
    NSSize size;
 
    if (b.x == a.x || b.y == a.y) return;
 
    if (b.x > a.x && b.y > a.y) {
      //top right
      origin = a;
      diagonal = b;
    } else if (b.x < a.x && b.y < a.y) {
      //bottom left
      origin = b;
      diagonal = NSMakePoint(a.x+selectedArea.size.width, a.y+selectedArea.size.height);
    } else if (b.x > a.x && b.y < a.y){
      //bottom right
      origin = NSMakePoint (a.x, b.y);
      diagonal = NSMakePoint (b.x, a.y + selectedArea.size.height);
    } else if (b.x < a.x && b.y > a.y) {
      //top left
      origin = NSMakePoint (b.x, a.y);
      diagonal = NSMakePoint (a.x + selectedArea.size.width, b.y);
    }
 
    size.width = diagonal.x - origin.x;
    size.height = diagonal.y - origin.y;
 
    selectedArea.origin = origin;
    selectedArea.size = size;
 
    [self setNeedsDisplay: YES];
  }

  if (movingSingleNode){
    //code for changing the position of a node
    if (selectedNode == nil) {
      return;
    }

    NSAffineTransform *t = [self transform];
    [t invert];
    NSPoint p2 = [t transformPoint: p];

    NSRect nodebb = [selectedNode boundingBox];
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
*/
}

- (void) mouseDown: (NSEvent *) event
{
  if ([event modifierFlags] & NSControlKeyMask){
    //if something should be done for this event, do it here
    move = [self convertPoint:[event locationInWindow] fromView:nil];
  }else{
    NSPoint p, p2;
    p = [self convertPoint:[event locationInWindow] fromView:nil];

    NSAffineTransform *t = [self transform];
    [t invert];
    p2 = [t transformPoint: p];

    movingSingleNode = YES;
  }
  return;
/*
  if ([event modifierFlags] & NSControlKeyMask){
    if (selectedNode != nil){
      //moving a single node
      movingSingleNode = YES;
    }else{
      //selecting area
      selectingArea = YES;
      NSAffineTransform *t = [self transform];
      [t invert];
      NSPoint pt = [t transformPoint: move];
      selectedArea.origin = pt;
      selectedArea.size = NSZeroSize;
    }
  }
*/
}

- (void) mouseUp: (NSEvent *) event
{
  if ([event modifierFlags] & NSControlKeyMask){
    //if something should be done for this event, do it here
  }
  [super mouseUp: event];
  return;
/*
  return;
  if (selectingArea){
    //do multiple node selection
  }

  selectingArea = NO;
*/
  movingSingleNode = NO;
}

- (void) mouseMoved:(NSEvent *)event
{
  if ([event modifierFlags] & NSControlKeyMask){
    //if something should be done for this event, do it here
  }
  NSPoint p, p2;
  p = [self convertPoint:[event locationInWindow] fromView:nil];

  NSAffineTransform *t = [self transform];
  [t invert];
  p2 = [t transformPoint: p];

  [highlighted setHighlighted: NO];

  TrivaGraph *ret = [currentRoot searchAtPoint: p2];
  if (ret){
    highlighted = ret;
    [highlighted setHighlighted: YES];
  }else{
    highlighted = nil;
  }
  [self setNeedsDisplay: YES];
  return;
}

- (void) rightMouseDown: (NSEvent *) event
{
  [self resetCurrentRoot];
  [self setNeedsDisplay: YES];
}

- (void)scrollWheel:(NSEvent *)event
{
  if ([event modifierFlags] & NSControlKeyMask){
    //if something should be done for this event, do it here

    NSPoint screenPositionAfter, screenPositionBefore, graphPoint;
    NSAffineTransform *t;
 
    screenPositionBefore = [self convertPoint: [event locationInWindow]
                                     fromView: nil];
    t = [self transform];
    [t invert];
    graphPoint = [t transformPoint: screenPositionBefore];
 
    //updating the ratio considering 10% of its value 
    if ([event deltaY] > 0){
      ratio += ratio*0.1;
    }else{
      ratio -= ratio*0.1;
    }
 
    t = [self transform];
    screenPositionAfter = [t transformPoint: graphPoint];
 
    //update translate to compensate change on scale
    translate = NSAddPoints (translate,
                    NSSubtractPoints (screenPositionBefore, screenPositionAfter));
 
    [self setNeedsDisplay: YES];
  }else{
    double delta = [event deltaY];
    if (highlighted){
      //if user is scrolling over a highlighted node
      //change its expansion level
      if (delta > 0){
        [highlighted setExpanded: YES];
      }else{
        [[highlighted parent] setExpanded: NO];
      }
      [highlighted setHighlighted: NO];
      highlighted = nil;
      [currentRoot recursiveLayout];
      [self setNeedsDisplay: YES];
    }
  }
  return;
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
    [theEvent keyCode] == 27){ //ALT + R
    [filter setRecordMode];
  }
}

- (void) setCurrentRoot: (TrivaGraph *) nroot
{
  if (!nroot) return;

  if (highlighted){
    [highlighted setHighlighted: NO];
    highlighted = nil;
  }
  currentRoot = nroot;
  [self setNeedsDisplay: YES];
}

- (void) resetCurrentRoot
{
  currentRoot = nil;
  highlighted = nil;
}
@end
