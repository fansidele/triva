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
#include "../Triva/NSPointFunctions.h"

@implementation FDDrawView
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];

  //for graphical translation and zoom
  ratio = 1;
  move = NSZeroPoint;
  translate = NSZeroPoint;
  movingSingleNode = NO;
  highlighted = nil;
  return self;
}

- (BOOL) isFlipped
{
    return NO;
}

- (void) setFilter: (FDGraphView *)f
{
  filter = f;
}

- (NSAffineTransform*) transform
{
  NSAffineTransform* transform = [NSAffineTransform transform];
  [transform translateXBy: translate.x yBy: translate.y];
  [transform scaleXBy: ratio yBy: ratio];
  return transform;
}

- (void)drawConnections:(TrivaGraph*)tree
{
  [NSBezierPath setDefaultLineWidth: 2];
  if ([tree expanded]){
    //recurse
    NSEnumerator *en = [[tree children] objectEnumerator];
    TrivaGraph *child;
    while ((child = [en nextObject])){
      [self drawConnections: child];
    }
  }else{
    NSEnumerator *en = [[tree connectedNodes] objectEnumerator];
    TrivaGraph *connected;
    while ((connected = [en nextObject])){
      NSPoint mp = [tree location];
      NSPoint pp = [connected location];
      [[[NSColor grayColor] colorWithAlphaComponent: 0.2] set];
      NSBezierPath *path = [NSBezierPath bezierPath];
      [path moveToPoint: mp];
      [path lineToPoint: pp];
      [path stroke];
    }
  }
}

- (void)drawRect:(NSRect)frame
{
  static BOOL firstDrawing = YES;
  if (firstDrawing){
    translate = NSAddPoints(translate,
                            NSMakePoint(frame.size.width/2,
                                        frame.size.height/2));
    firstDrawing = NO;
  }

  TrivaGraph *root = [filter tree];

  NSRect tela = [self bounds];

  //white fill on view
  [[NSColor whiteColor] set];
  NSRectFill(tela);

  //draw the name of the file
  [[filter traceDescription]
                          drawAtPoint: NSMakePoint(0,0)
                       withAttributes: nil];

  //apply the graphical transformation for translation and zoom
  NSAffineTransform *transform = [self transform];
  [transform concat];

  //set default line width based on ratio
  [NSBezierPath setDefaultLineWidth: 1/ratio];

  //draw connections first (so they appear in the background)
  [self drawConnections: root];

  //draw nodes
  [root recursiveDrawLayout];

  //invert the graphical transformation
  [transform invert];
  [transform concat];

  //write highlighted node information
  if (highlighted && !movingSingleNode){
    NSString *desc = [highlighted description];
    NSMutableString *str = [NSMutableString stringWithString: desc];
    [str appendString: @"\n"];
    NSSize size = [str sizeWithAttributes: nil];
    double base = tela.size.height - size.height;
    [str drawAtPoint: NSMakePoint(0, base)
      withAttributes: nil];

    //draw key
    NSDictionary *d = [filter spatialIntegrationOfContainer:
                                [highlighted container]];
    NSEnumerator *en = [d keyEnumerator];
    NSString *key;
    double current_base = base;
    while ((key = [en nextObject])){
      NSColor *color = [filter colorForIntegratedValueNamed: key];
      double value = [[d objectForKey: key] doubleValue];
      if (value == 0) continue;
      NSSize s = [key sizeWithAttributes: nil];
      NSRect r = NSMakeRect(0, current_base - s.height, 10, s.height);
      [color set];
      NSRectFill (r);
      [[NSColor blackColor] set];
      [key drawAtPoint: NSMakePoint (10, current_base - s.height)
        withAttributes: nil];
      current_base -= s.height-1;
    }
  }
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
  NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];

  if (highlighted == nil){
    //there is no node highlighted,
    //calculate new graphical transformation
    NSPoint dif = NSSubtractPoints (p, move);
    if (NSEqualPoints (translate, NSZeroPoint)){
      translate = dif;
    }else{
      translate = NSAddPoints (translate, dif);
    }
    move = p;
  }else{
    //there is a selected node
    //move it to the new place
    //change state to movingSingleNode
    movingSingleNode = YES;
    NSAffineTransform *t = [self transform];
    [t invert];
    NSPoint p2 = [t transformPoint: p];
    [filter moveNode: highlighted toLocation: p2];
  }
  [self setNeedsDisplay: YES];
  return;
}

- (void) mouseDown: (NSEvent *) event
{
  move = [self convertPoint:[event locationInWindow] fromView:nil];
  return;
}

- (void) rightMouseDown: (NSEvent *) event
{
  if (highlighted){
    [filter rightClickNode: highlighted];
  }
}

- (void) mouseUp: (NSEvent *) event
{
  move = [self convertPoint:[event locationInWindow] fromView:nil];

  if (highlighted && movingSingleNode == NO){
    [filter clickNode: highlighted];
  }

  if (movingSingleNode){
    [filter finishMoveNode: highlighted];
  }
  //all mouse operation has ended,
  // reset the movingSingleNode to its initial state
  movingSingleNode = NO;
  return;
}

- (void) mouseMoved:(NSEvent *)event
{
  NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];

  NSAffineTransform *t = [self transform];
  [t invert];
  NSPoint p2 = [t transformPoint: p];

  TrivaGraph *ret = [[filter tree] searchAtPoint: p2];
  if (ret == nil && highlighted == nil){
    return;
  }

  if (highlighted){
    [highlighted setHighlighted: NO];
    highlighted = nil;
  }

  if (ret){
    [ret setHighlighted: YES];
    highlighted = ret;
  }
  [self setNeedsDisplay: YES];
  return;
}

- (void)scrollWheel:(NSEvent *)event
{
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
                           NSSubtractPoints (screenPositionBefore,
                                             screenPositionAfter));
  [self setNeedsDisplay: YES];
}

- (void) reset
{
  [highlighted setHighlighted: NO];
  highlighted = nil;
  [self setNeedsDisplay: YES];
}
@end
