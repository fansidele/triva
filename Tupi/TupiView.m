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

#include "TupiView.h"

@implementation TupiView
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  return self;
}

- (void) setTupiManager: (TupiManager*) m
{
  tupiManager = m;
}

- (NSAffineTransform *) transform
{
  /* should be implemented by sub-classes */
  return nil;
}

- (void)drawRect:(NSRect)frame
{
  NSRect tela = [self bounds];

  //white fill on view
  [[NSColor whiteColor] set];
  NSRectFill(tela);

  //write the name of the file
  [@"oi" drawAtPoint: NSMakePoint(0,0)
                          withAttributes: nil];

  //set default line width based on ratio
  //[NSBezierPath setDefaultLineWidth: 1/ratio];

  //draw
  Tupi *node;
  NSEnumerator *en = [tupiManager enumeratorOfNodes];
  while ((node = [en nextObject])){
    [node draw];
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
  NSPoint p;
  p = [self convertPoint:[event locationInWindow] fromView:nil];

  NSAffineTransform *t = [self transform];
  [t invert];
  NSPoint p2 = [t transformPoint: p];

  if ([tupiManager moveHighlightToPoint: p2]){
    [self setNeedsDisplay: YES];
  }
}

- (void) mouseDown: (NSEvent *) event
{
}

- (void) mouseUp: (NSEvent *) event
{
}

- (void) mouseMoved:(NSEvent *)event
{
  NSPoint p, p2;
  p = [self convertPoint:[event locationInWindow] fromView:nil];

  NSAffineTransform *t = [self transform];
  [t invert];
  p2 = [t transformPoint: p];

  //search for nodes
  if ([tupiManager searchAndHighlightAtPoint: p2]){
    [self setNeedsDisplay: YES];
  }
  return;
}

/*
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
      NSPoint p = [node boundingBox].origin;
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
*/
@end
