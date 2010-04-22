/* 
   Project: SimGridColors

   Copyright (C) 2010 Free Software Foundation

   Author: Lucas Schnorr,,,

   Created: 2010-04-21 15:25:28 +0200 by schnorr
   
   Application Controller

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#include "AppController.h"
#include "ColorWellTextFieldCell.h"

@implementation AppController

+ (void)initialize
{
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];

  /*
   * Register your app's defaults here by adding objects to the
   * dictionary, eg
   *
   * [defaults setObject:anObject forKey:keyForThatObject];
   *
   */
  
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)init
{
  if ((self = [super init]))
    {
    }
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (void)awakeFromNib
{
  [[NSApp mainMenu] setTitle:@"SimGridColors"];
  NSRect rect = [view frame];
  matrix = [[NSMatrix alloc]initWithFrame: [view frame]];
  [view setDocumentView: matrix];
  [matrix setCellClass: [ColorWellTextFieldCell class]];
  while ([matrix numberOfRows] > 0){
    [matrix removeRow: 0];
  }
  [matrix setCellSize: NSMakeSize (rect.size.width/2,20)];

  //get nsuserdefaults
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *colors = [defaults objectForKey: @"SimGridCategoriesColor"];
  if (colors){
    //updating matrix
    [matrix renewRows: [colors count] columns: 2];

    NSEnumerator *en = [colors keyEnumerator];
    NSString *category;
    int i;
    for (i = 0; ((category = [en nextObject])); i++){
      ColorWellTextFieldCell *cell;

      //category name
      cell = [matrix cellAtRow: i column: 0];
      [cell setWellColor: NO];
      [cell setStringValue: category];
      cell = nil;

      //category color
      cell = [matrix cellAtRow: i column: 1];
      [cell setWellColor: YES];
      //obtaining color
      NSString *c = [colors objectForKey: category];
      double red = [[[c componentsSeparatedByString: @" "] objectAtIndex: 0] doubleValue];
      double green = [[[c componentsSeparatedByString: @" "] objectAtIndex: 1] doubleValue];
      double blue = [[[c componentsSeparatedByString: @" "] objectAtIndex: 2] doubleValue];
      NSColor *color = [NSColor colorWithCalibratedRed: red green: green blue: blue alpha: 1];
      [cell setColor: color];
    }

    [matrix sizeToCells];
    [matrix setNeedsDisplay:YES];
  }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotif
{
// Uncomment if your application is Renaissance-based
//  [NSBundle loadGSMarkupNamed:@"Main" owner:self];
}

- (BOOL)applicationShouldTerminate:(id)sender
{
  return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotif
{
}

- (BOOL)application:(NSApplication *)application openFile:(NSString *)fileName
{
  return NO;
}

- (void)showPrefPanel:(id)sender
{
}

- (BOOL) windowShouldClose: (id) sender
{
  [[NSApplication sharedApplication] terminate:self];
  return YES;
}

- (void) add: (id) sender
{
  int nrows = [matrix numberOfRows];
  [matrix renewRows: nrows+1 columns: 2];
  [[matrix cellAtRow: nrows column: 0] setWellColor: NO];
  [[matrix cellAtRow: nrows column: 1] setWellColor: YES];
  [matrix sizeToCells];
  [matrix setNeedsDisplay:YES];
}

- (void) apply: (id) sender
{
  NSMutableDictionary *colors = [NSMutableDictionary dictionary];

  int i;
  for (i = 0; i < [matrix numberOfRows]; i++){
    NSString *category = [[matrix cellAtRow: i column: 0] stringValue];
    NSColor *color = [[matrix cellAtRow: i column: 1] color];
    if (category && color){
      [colors setObject: [color description] forKey: category];
    }
  }
  //saving in nsuserdefaults
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject: colors forKey: @"SimGridCategoriesColor"];
  [defaults synchronize];

  //saving in "Triva" domain name
  NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:
      [defaults persistentDomainForName: @"Triva"]];
  NSEnumerator *en = [colors keyEnumerator];
  NSString *category;
  while ((category = [en nextObject])){
    if (![category isEqualToString: @""]){
      [dictionary setObject: [colors objectForKey: category]
                forKey: [NSString stringWithFormat: @"p%@ Color", category]];
      [dictionary setObject: [colors objectForKey: category]
                forKey: [NSString stringWithFormat: @"b%@ Color", category]];

      NSMutableDictionary *categoryColors = [dictionary objectForKey: @"category Colors"];
      if (!categoryColors){
        categoryColors = [NSMutableDictionary dictionary];
      }
      [categoryColors setObject: [colors objectForKey: category]
                    forKey: category];
      [dictionary setObject: categoryColors forKey: @"category Colors"];
    }
  }
  [defaults setPersistentDomain: dictionary forName: @"Triva"];
  [defaults synchronize];
}


- (void) delete: (id) sender
{
  [matrix renewRows: 0 columns: 0];
  [matrix sizeToCells];
  [matrix setNeedsDisplay:YES];
}
@end
