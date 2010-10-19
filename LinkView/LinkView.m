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
#include "LinkView.h"

@implementation LinkView
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
    [NSBundle loadGSMarkupNamed: @"LinkView" owner: self];
  }
  [view setFilter: self];
  [window setDelegate: self];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //window position
        NSPoint point;
        NSString *tx = [NSString stringWithFormat: @"%@OriginX", [window title]];
        NSString *ty = [NSString stringWithFormat: @"%@OriginY", [window title]];
        //check if it exists
        if ([defaults objectForKey: tx] && [defaults objectForKey: ty]){
                point.x = [[defaults objectForKey: tx] doubleValue];
                point.y = [[defaults objectForKey: ty] doubleValue];
                [window setFrameOrigin: point];
        }else{
                [window center];
        }
  return self;
}

- (void)windowDidMove:(NSNotification *)win
{
        NSPoint point = [window frame].origin;
        NSString *tx = [NSString stringWithFormat: @"%@OriginX", [window title]];
        NSString *ty = [NSString stringWithFormat: @"%@OriginY", [window title]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: [NSString stringWithFormat: @"%f", point.x] forKey: tx];
        [defaults setObject: [NSString stringWithFormat: @"%f", point.y] forKey: ty];
        [defaults synchronize];
}

- (void) timeSelectionChanged
{
  [view setNeedsDisplay: YES];
}

- (NSMutableDictionary *) nodes
{
  return nodes;
}

- (void) resetNodes
{
  if (nodes){
    [nodes release];
  }
  nodes = [[NSMutableDictionary alloc] init];
}


- (BOOL) windowShouldClose: (id) sender
{
  [[NSApplication sharedApplication] terminate:self];
  return YES;
}
@end
