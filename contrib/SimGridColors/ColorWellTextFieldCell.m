/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "ColorWellTextFieldCell.h"

@implementation ColorWellTextFieldCell
- (id) init
{
  self = [super init];
  colorWell = nil;
  return self;
}

- (void) dealloc
{
  [colorWell release];
  [super dealloc];
}

- (void) setWellColor: (BOOL) wc
{
  if (wc){
    colorWell = [[NSColorWell alloc] init];
    double red = drand48();
    double green = drand48();
    double blue = drand48();
    [colorWell setColor: [NSColor colorWithCalibratedRed: red green: green blue: blue alpha: 1]];
  }else{
    [self setDrawsBackground: YES];
    [self setBackgroundColor: [NSColor whiteColor]];
    [self setBezeled: YES];
    [self setSelectable: NO];
    [self setEditable: YES];
  }
}

- (NSColor*)color
{
  return [colorWell color];
}

- (void) setColor: (NSColor*) color
{
  [colorWell setColor: color];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
  if (colorWell){
    [colorWell drawWellInside: cellFrame];
  }else{
    [super drawInteriorWithFrame: cellFrame inView: controlView];
  }
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{
  if (colorWell){
    [colorWell activate: YES];
    return YES;
  }else{
    return [super continueTracking: lastPoint at: currentPoint inView: controlView];
  }
}
@end
