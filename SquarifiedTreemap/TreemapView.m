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

  [self resetHighlighted];
  currentRoot = nroot;
  [self setNeedsDisplay: YES];
}

- (void) resetCurrentRoot
{
  currentRoot = nil;
  [self resetHighlighted];
}

- (void) resetHighlighted
{
  if (highlighted){
    [highlighted setHighlighted: NO];
    highlighted = nil;
  }
  [self setNeedsDisplay: YES];
}

- (void)drawTree:(TrivaTreemap*) tree
{
  BOOL entropyDisaggregate = ([filter zoomType] == EntropyZoom
                              && [filter entropyLetDisaggregateContainer: [tree container]]);
  BOOL globalDisaggregate = ([filter zoomType] == GlobalZoom
                             && [tree depth] != maxDepthToDraw);
  BOOL localDisaggregate = ([filter zoomType] == LocalZoom
                            && [tree expanded]);
  if (entropyDisaggregate || globalDisaggregate || localDisaggregate){
    //recurse
    NSEnumerator *en = [[tree children] objectEnumerator];
    TrivaTreemap *child;
    while ((child = [en nextObject])){
      [self drawTree: child];
    }
    
    //draw border
    [tree drawBorder];
  }else{
    [tree drawTreemap];
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

  //draw highlighted node information
  if (highlighted){
    [highlighted drawHighlighted];

    //draw information
    NSRect tela = [self bounds];
    NSString *str = [highlighted description];
    NSSize size = [str sizeWithAttributes: nil];
    double base = tela.size.height - size.height-10;
    NSRect infoRect = NSMakeRect (10, base, size.width, size.height);
    [[[NSColor whiteColor] colorWithAlphaComponent: 0.8] set];
    NSRectFill (infoRect);
    [[NSColor blackColor] set];
    [str drawAtPoint: NSMakePoint(10, base)
      withAttributes: nil];
  }
}

- (void)scrollWheel:(NSEvent *)event
{
  if (([event modifierFlags] & NSControlKeyMask)){
  }else{
    if ([event deltaY] > 0){
      if (maxDepthToDraw < [currentRoot maxDepth]){
        maxDepthToDraw++;
        [self mouseMoved: event];
        [self setNeedsDisplay: YES];
      }
    }else{
      if (maxDepthToDraw > [currentRoot depth]){
        maxDepthToDraw--;
        [self mouseMoved: event];
        [self setNeedsDisplay: YES];
      }
    }
  }
}

- (void) mouseMoved:(NSEvent *)event
{
  NSPoint p;
  p = [self convertPoint:[event locationInWindow] fromView:nil];
  TrivaTreemap *node = [self searchAtPoint: p
                                  withNode: currentRoot
                              withZoomType: [filter zoomType]];
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
  TrivaTreemap *node = [self searchAtPoint: p
                                  withNode: currentRoot
                              withZoomType: [filter zoomType]];
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

- (TrivaTreemap*) searchAtPoint: (NSPoint) p
                       withNode: (TrivaTreemap*) root
                   withZoomType: (ZoomType) zoom
{
  TrivaTreemap *ret = nil;
  if ([root hasPoint: p]){
    BOOL entropySearch = (zoom == EntropyZoom &&
                          [filter entropyLetShowContainer: [root container]]);
    BOOL globalSearch = (zoom == GlobalZoom &&
                         [root depth] == maxDepthToDraw);
    BOOL localSearch = (zoom == LocalZoom &&
                        ![root expanded]);
    if (entropySearch || globalSearch || localSearch){
      ret = root;
    }else{
      NSEnumerator *en = [[root children] objectEnumerator];
      TrivaTreemap *child;
      while ((child = [en nextObject])){
        ret = [self searchAtPoint: p withNode: child withZoomType: zoom];
        if (ret) break;
      }
    }
  }
  return ret; 
}
@end
