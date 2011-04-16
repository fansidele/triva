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

#include "TreemapView.h"

@implementation TreemapView
- (id)initWithFrame:(NSRect)frameRect
{
  self = [super initWithFrame: frameRect];
  maxDepthToDraw = 0;
  highlighted = nil;
  currentRoot = nil;
  showLevelKey = NO;
  return self;
}

- (void) setCurrentRoot: (TrivaTreemap *) nroot
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

- (void)drawTree:(TrivaTreemap*) tree
{
  if ([tree depth] == maxDepthToDraw){
    [tree drawTreemap];
  }else{
    //recurse
    NSEnumerator *en = [[tree children] objectEnumerator];
    TrivaTreemap *child;
    while ((child = [en nextObject])){
      [self drawTree: child];
    }
    
    //draw border
    [tree drawBorder];
  }
}

- (void)drawRect:(NSRect)frame
{
  if (currentRoot == nil){
    [self setCurrentRoot: [filter tree]];
  }
  [currentRoot refreshWithBoundingBox: [self bounds]];
  [self drawTree: currentRoot];

  //draw key
  if (showLevelKey){
    NSRect b = [self bounds];
    int numberOfLevels = [[filter tree] maxDepth];
    NSBezierPath *p = [NSBezierPath bezierPath];
    [p setLineWidth: 1];
    double top = b.size.height-10;
    [p moveToPoint:NSMakePoint(10,top)];
    [p lineToPoint:NSMakePoint(10,top-((numberOfLevels)*20))];
    int i;
    for (i = 0; i <= numberOfLevels; i++){
      [p moveToPoint:NSMakePoint(5,top-(i)*20)];
      [p lineToPoint:NSMakePoint(15,top-(i)*20)];
    }
    [[NSColor whiteColor] set];
    [p stroke];
    p = [NSBezierPath bezierPath];
    [p setLineWidth: 2];
    [p moveToPoint:NSMakePoint(5,top-(maxDepthToDraw)*20)];
    [p lineToPoint:NSMakePoint(15,top-(maxDepthToDraw)*20)];
    [[NSColor blackColor] set];
    [p stroke];
  }
}

- (void)scrollWheel:(NSEvent *)event
{
  if (([event modifierFlags] & NSControlKeyMask)){
  }else{
    if ([event deltaY] > 0){
      if (maxDepthToDraw < [currentRoot maxDepth]){
        maxDepthToDraw++;
        [self setNeedsDisplay: YES];
      }
    }else{
      if (maxDepthToDraw > [currentRoot depth]){
        maxDepthToDraw--;
        [self setNeedsDisplay: YES];
      }
    }
  }
}

- (void) mouseMoved:(NSEvent *)event
{
  NSPoint p;
  p = [self convertPoint:[event locationInWindow] fromView:nil];
  TrivaTreemap *node=(TrivaTreemap*)[currentRoot searchAtPoint: p
                                                      maxDepth: maxDepthToDraw];
  [highlighted setHighlighted: NO];
  [node setHighlighted: YES];
  highlighted = node;
  [self setNeedsDisplay: YES];
}

- (void) rightMouseDown: (NSEvent *) event
{
  [self resetCurrentRoot];
  [self setNeedsDisplay: YES];
}

- (void) mouseDown:(NSEvent *) event
{
  NSPoint p;
  p = [self convertPoint:[event locationInWindow] fromView:nil];
  TrivaTreemap *node =(TrivaTreemap*)[currentRoot searchAtPoint: p
                                                       maxDepth:maxDepthToDraw];
  [self setCurrentRoot: node];
}

- (void)keyDown:(NSEvent *)theEvent
{
  int code = [theEvent keyCode];
  switch (code){
    case 33: [self printTreemap]; break; //P
    case 27: [filter setRecordMode]; break; //R
    case 24: [self resetCurrentRoot]; [self setNeedsDisplay: YES]; break; //Q
    case 52: //Z
      [highlighted setHighlighted: NO];
      highlighted = nil;
      [self setNeedsDisplay: YES];
      break;
    case 45: //K
      showLevelKey = !showLevelKey;
      [self setNeedsDisplay: YES];
      break;
    default:
      break;
  }
  return;
}

#ifdef GNUSTEP
- (BOOL)acceptsFirstResponder
{
    return YES;
}
#endif

- (BOOL)becomeFirstResponder
{
    [[self window] setAcceptsMouseMovedEvents: YES];
    return YES;
}

- (void) setFilter: (SquarifiedTreemap *) f
{
  filter = f;
  [self setCurrentRoot: [filter tree]];
}

- (void) setCurrentStatusString: (NSString *)str
{
  [str drawAtPoint: NSMakePoint (0, 0)
      withAttributes: nil];
}


- (void) printTreemap
{
  static int counter = 0;
  NSPrintOperation *op;
  NSMutableData *data = [NSMutableData data];
  op = [NSPrintOperation EPSOperationWithView: self
                                   insideRect: [self bounds]
                                       toData: data];
  [op runOperation];
  NSString *filename = [NSString stringWithFormat: @"%03d-treemap-%@-%@.eps", counter++,
    [filter selectionStartTime], [filter selectionEndTime]];
  [data writeToFile: filename atomically: YES];
  NSLog (@"screenshot written to %@", filename);
}
@end

/*
@implementation TreemapView
- (id)initWithFrame:(NSRect)frameRect
{
  self = [super initWithFrame: frameRect];
  maxDepthToDraw = 0;
  current = nil;
  highlighted = nil;
  updateCurrentTreemap = YES;
  offset = 0;
  return self;
}

- (void) drawTreemap: (TrivaTreemap*) treemap
{
  if ([treemap treemapValue] == 0){
    return;
  }
  if ([treemap depth] == maxDepthToDraw){
    //draw aggregates
    int nAggChildren, i;
    nAggChildren = [[treemap aggregatedChildren] count];
    for (i = 0; i < nAggChildren; i++){
      TrivaTreemap *child = [[treemap aggregatedChildren]
          objectAtIndex: i];
      [child draw];
    }
  }else{
    //recurse
    int i;
    for (i = 0; i < [[treemap children] count]; i++){
      [self drawTreemap: [[treemap children]
            objectAtIndex: i]];
    }
  }
}

- (BOOL) isFlipped
{
  return NO;
}

- (void)drawRect:(NSRect)frame
{
  NSRect b = [self bounds];
  if (updateCurrentTreemap){
    TimeSliceTree *tree = [filter timeSliceTree];
    if (tree == nil){
      [[NSColor whiteColor] set];
      NSRectFill (b);
      [[NSColor blackColor] set];
      NSString *message = @"Please, set a time slice.";
      NSSize size = [message sizeWithAttributes: nil];
      NSPoint p = NSMakePoint (b.size.width/2 - size.width/2, b.size.height/2);
      [message drawAtPoint: p withAttributes: nil];
      return;
    }
        
    if (maxDepthToDraw > [tree maxDepth]){
      maxDepthToDraw = [tree maxDepth];
    }
        
    if (current){
      [current release];
    }
    current = [[TrivaTreemap alloc] initWithTimeSliceTree: tree
        andProvider: filter];
    [current setBoundingBox: b];
    [current setOffset: offset];
    [current refresh];
    //timeslicetree changed, highlighted is no longer valid
    highlighted = nil;
  }
  [self drawTreemap: current];
  if (highlighted){
    [self setCurrentStatusString: [[highlighted hierarchy] description]];
    [self highlightHierarchy];
  }
  updateCurrentTreemap = YES;
}

- (void) setMaxDepthToDraw: (int) d
{
  maxDepthToDraw = d;
}

- (int) maxDepthToDraw
{
  return maxDepthToDraw;
}


- (void) mouseMoved:(NSEvent *)event
{
  NSPoint p;
  p = [self convertPoint:[event locationInWindow] fromView:nil];

  id node = [current searchWith: p limitToDepth: maxDepthToDraw];
  if (node != highlighted){
    [self setHighlight: highlighted highlight: NO];
    [self setHighlight: node highlight: YES];
    updateCurrentTreemap = NO;
    [self setNeedsDisplay: YES];
    highlighted = node;
  }
}

#ifdef GNUSTEP
- (BOOL)acceptsFirstResponder
{
    return YES;
}
#endif


- (BOOL)becomeFirstResponder
{
    [[self window] setAcceptsMouseMovedEvents: YES];
    return YES;
}

- (void) highlightHierarchy
{
  //highlight hierarchy
  NSRect bounds = [self bounds];

  double lineWidth = bounds.size.width*.001; 
  if (lineWidth < 1) lineWidth = 1;
  id p = [highlighted parent];
  while (p){
    if (![p parent]) break;
    if ([[p children] count] > 1){
      NSRect pbb = [p boundingBox];
      NSRect border = NSMakeRect (pbb.origin.x + 1,
                                  pbb.origin.y + 1,
                                  pbb.size.width - 1,
                                  pbb.size.height -1);
      NSBezierPath *path = [NSBezierPath bezierPathWithRect: border];
      [path setLineWidth: lineWidth];
      [path stroke];
    }
    p = [p parent];
    lineWidth += lineWidth * 0.1;
  }
}
@end
*/
