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
#include <Renaissance/Renaissance.h>
#include "GraphConfiguration.h"

@implementation GraphConfiguration
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
    [NSBundle loadGSMarkupNamed: @"GraphConfiguration" owner: self];
    colors = [[NSMutableDictionary alloc] init];
    minValues = [[NSMutableDictionary alloc] init];
    maxValues = [[NSMutableDictionary alloc] init];
  }
  [self initInterface];
  hideWindow = NO;
  graph = NULL;
  return self;
}

- (void) dealloc
{
  if (graph){
    agclose(graph);
    gvFreeContext(gvc);
  }
  [colors release];
  [minValues release];
  [maxValues release];
  [super dealloc];
}

//  Entry method from interface: a new configuration arrives
- (void) saveGraphConfiguration: (NSString *) c
                     withTitle: (NSString *) t
{
  //parsing to check format is ok
  NSData* plistData = [c dataUsingEncoding:NSUTF8StringEncoding];
  NSString *error;
  NSPropertyListFormat format;
  NSDictionary *plist = [NSPropertyListSerialization
                propertyListFromData: plistData
                    mutabilityOption:NSPropertyListImmutable
                              format:&format
                    errorDescription:&error];

  //save in file the new configuration
  [c writeToFile: t atomically: YES];

  //save a copy of conf
  [currentGraphConfiguration release];
  currentGraphConfiguration = [NSDictionary dictionaryWithDictionary: plist];
  [currentGraphConfiguration retain];

  //interface
  [self refreshInterfaceWithConfiguration: c withTitle: t];
}

- (void) applyGraphConfiguration
{
  //let's inform other components that we have changes
  [self hierarchyChanged];
}

- (void) timeSelectionChanged
{
  [self resetMinMaxColor];
  [super timeSelectionChanged];
}

- (void) entitySelectionChanged
{
  [self timeSelectionChanged];
  [super entitySelectionChanged];
}

- (void) containerSelectionChanged
{
  [self timeSelectionChanged];
  [super containerSelectionChanged];
}

- (void) dataChangedForEntityType: (PajeEntityType *) type
{
  [self timeSelectionChanged];
  [super dataChangedForEntityType: type];
}

+ (NSDictionary *) defaultOptions
{
  NSBundle *bundle;
  bundle = [NSBundle bundleForClass: NSClassFromString(@"GraphConfiguration")];
  NSString *file = [bundle pathForResource: @"GraphConfiguration"
                                    ofType: @"plist"];
  return [NSDictionary dictionaryWithContentsOfFile: file];
}

- (void) setConfiguration: (TrivaConfiguration *) conf
{
  //extract my configuration and put in myOptions dictionary
  NSDictionary *myOptions = [conf configuredOptionsForClass: [self class]];

  //configure myself using the configuration in myOptions
  NSString *gc = nil;
  NSString *gct = nil;
  NSEnumerator *en = [myOptions keyEnumerator];
  NSString *key;
  BOOL apply = NO;
  while ((key = [en nextObject])){
    NSString *value = [myOptions objectForKey: key];
    if (0){
    }else if([key isEqualToString: @"gc_conf"]){
      gct = value;
      gc = [NSString stringWithContentsOfFile: value];
      if (!gc){
        //file not found, launch exception
        NSException *ex;
        ex = [NSException exceptionWithName: @"GraphConfigurationFileNotFound"
                   reason: [NSString stringWithFormat: @"file = %@", value]
                 userInfo: nil];
        [ex raise];
      }
    }else if([key isEqualToString: @"gc_hide"]){
      hideWindow = YES;
    }else if([key isEqualToString: @"gc_show"]){
      hideWindow = NO;
    }else if([key isEqualToString: @"gc_apply"]){
      apply = YES;
    }else if([key isEqualToString: @"gc_dot"]){
      FILE *fp = fopen ([value cString], "r");
      if (fp == NULL){
        //file not found, launch exception
        NSException *ex;
        ex = [NSException exceptionWithName: @"GraphConfigurationDotFileNotFound"
                   reason: [NSString stringWithFormat: @"file = %@", value]
                 userInfo: nil];
        [ex raise];
      }
      gvc = gvContext();
      graph = agread(fp);
    }
  }

  if (gc){
    [self saveGraphConfiguration: gc
                      withTitle: gct];
  }

  if (apply){
    [self applyGraphConfiguration];
  }

  if (hideWindow){
    [self hide];
  }else{
    [self show];
  }
}

- (void) hide
{
  if (hideWindow){
    [window orderOut: self];
  }
}

- (void) show
{
  if (!hideWindow){
    [window orderFront: self];
  }
}

- (void) show: (id) sender
{
  [self show];
}

- (void) resetMinMaxColor
{
  [minValues removeAllObjects];
  [maxValues removeAllObjects];
  [colors removeAllObjects];
}

/* values for the current time-slice */
- (void) updateMinMaxColorForContainerType:(PajeEntityType*)type
{
  NSEnumerator *en;
  if ([[type description] isEqualToString:
                            [[[self rootInstance] entityType] description]]){
    en = [[NSArray arrayWithObjects: [self rootInstance], nil]
           objectEnumerator];
  }else{
    en = [self enumeratorOfContainersTyped: type
                               inContainer: [self rootInstance]];
  }

  NSMutableDictionary *min, *max, *color;
  min = [NSMutableDictionary dictionary];
  max = [NSMutableDictionary dictionary];
  color = [NSMutableDictionary dictionary];

  PajeContainer *container;
  while ((container = [en nextObject])){
    NSDictionary *contValues = [self spatialIntegrationOfContainer: container];

    //calculate min and maxValues
    NSEnumerator *en2 = [contValues keyEnumerator];
    NSString *valueName, *value;
    while ((valueName = [en2 nextObject])){
      value = [contValues objectForKey:valueName];
      //minValue
      if ([min objectForKey:valueName] == nil){
        [min setObject:value
                      forKey:valueName];
      }else{
        if ([value doubleValue] <
            [[min objectForKey:valueName] doubleValue]){
          [min setObject:value
                        forKey:valueName];
        }
      }
      //maxValue
      if ([max objectForKey:valueName] == nil){
        [max setObject:value
                      forKey:valueName];
      }else{
        if ([value doubleValue] >
            [[max objectForKey:valueName] doubleValue]){
          [max setObject:value
                        forKey:valueName];
        }
      }

      //save colors
      [color setObject:[self colorForIntegratedValueNamed:valueName]
                 forKey:valueName];
    }
  }

  [minValues setObject: min forKey: type];
  [maxValues setObject: max forKey: type];
  [colors setObject: color forKey: type];
}
@end
