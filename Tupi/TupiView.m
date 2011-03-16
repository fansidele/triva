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
  //draw
  Tupi *node;
  NSEnumerator *en = [tupiManager enumeratorOfNodes];
  while ((node = [en nextObject])){
    [node drawLayout];
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

- (void)scrollWheel:(NSEvent *)event
{
}
@end
