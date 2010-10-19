/* 
   Project: SimGridColors

   Copyright (C) 2010 Free Software Foundation

   Author: Lucas Schnorr,,,

   Created: 2010-04-21 15:25:28 +0200 by schnorr

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

#include <AppKit/AppKit.h>

int 
main(int argc, const char *argv[])
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  int ret = 0;
  if (argc != 1){
    int i;
    srand48(time(NULL));

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *trivaDefaults;
    trivaDefaults = [[NSMutableDictionary alloc] initWithDictionary:
              [d persistentDomainForName: @"Triva"]];
    NSMutableArray *categories = [NSMutableArray array];
    for (i = 1; i < argc; i++){
      [categories addObject: [NSString stringWithFormat: @"%s", argv[i]]];
    }

    NSLog (@"Setting colors for: %@", categories);
    NSEnumerator *en = [categories objectEnumerator];
    NSString *category;
    NSMutableArray *pCategories = [NSMutableArray array];
    NSMutableArray *bCategories = [NSMutableArray array];
    while ((category = [en nextObject])){
      double red = drand48();
      double green = drand48();
      double blue = drand48();
      NSColor *color = [NSColor colorWithCalibratedRed: red
                                                 green: green
                                                  blue: blue
                                                 alpha: 1];
      NSString *p_category;
      NSString *b_category;
      p_category = [NSString stringWithFormat: @"p%@ Color", category];
      b_category = [NSString stringWithFormat: @"b%@ Color", category];
      [trivaDefaults setObject: color forKey: p_category];
      [trivaDefaults setObject: color forKey: b_category];

      [pCategories addObject: [NSString stringWithFormat: @"p%@", category]];
      [bCategories addObject: [NSString stringWithFormat: @"b%@", category]];
    }

    NSLog (@"Graph configuration with: %@", categories);    
    NSString *graphConfKey = @"SimGrid Graph Configuration";
    NSMutableDictionary *graphConf = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *hostConf = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *hostConfComp = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *linkConf = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *linkConfComp = [[NSMutableDictionary alloc] init];

    [graphConf setObject: [NSArray arrayWithObjects: @"HOST", nil]
                  forKey: @"node"];
    [graphConf setObject: [NSArray arrayWithObjects: @"LINK", nil]
                  forKey: @"edge"];
    [graphConf setObject: @"neato" forKey: @"graphviz-algorithm"];

    [hostConfComp setObject: @"power" forKey: @"size"];
    [hostConfComp setObject: @"separation" forKey: @"type"];
    [hostConfComp setObject: pCategories forKey: @"values"];
    [hostConf setObject: @"power" forKey: @"size"];
    [hostConf setObject: @"global" forKey: @"scale"];
    [hostConf setObject: hostConfComp forKey: @"composition001"];
    [graphConf setObject: hostConf forKey: @"HOST"];
  
    [linkConfComp setObject: @"bandwidth" forKey: @"size"];
    [linkConfComp setObject: @"separation" forKey: @"type"];
    [linkConfComp setObject: bCategories forKey: @"values"];
    [linkConf setObject: @"source" forKey: @"src"];
    [linkConf setObject: @"destination" forKey: @"dst"];
    [linkConf setObject: @"bandwidth" forKey: @"size"];
    [linkConf setObject: @"global" forKey: @"scale"];
    [linkConf setObject: linkConfComp forKey: @"composition001"];
    [graphConf setObject: linkConf forKey: @"LINK"];

    NSMutableDictionary *graphConfs;
    graphConfs = [[NSMutableDictionary alloc] initWithDictionary:
                    [trivaDefaults objectForKey: @"GraphConfigurationItems"]];
    [graphConfs setObject: [graphConf description] forKey: graphConfKey];
    [trivaDefaults setObject: graphConfs forKey: @"GraphConfigurationItems"];
    [trivaDefaults setObject: graphConfKey forKey: @"GraphConfigurationSelected"];
    [d setPersistentDomain: trivaDefaults forName: @"Triva"];
    [trivaDefaults release];
    [d synchronize];
  }else{
    ret = NSApplicationMain (argc, argv);
  }
  [pool release];
  return ret;
}

