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
#include "GraphConfiguration.h"

#define MAX_SIZE   40

@implementation GraphConfiguration
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
    [NSBundle loadGSMarkupNamed: @"GraphConfiguration" owner: self];
  }
  [self initInterface];
  //initialiation of graphviz
  gvc = gvContext();

  hideWindow = NO;
  return self;
}

- (void) dealloc
{
  [configuration release];
  [super dealloc];
}

//  Entry method from interface: a new configuration arrives
- (void) setGraphConfiguration: (NSString *) c
                     withTitle: (NSString *) t
{

  NSData* plistData = [c dataUsingEncoding:NSUTF8StringEncoding];
  NSString *error;
  NSPropertyListFormat format;
  NSDictionary* plist = [NSPropertyListSerialization
                                propertyListFromData: plistData
                                    mutabilityOption:NSPropertyListImmutable
                                              format:&format
                                    errorDescription:&error];

  //update the configuration that is used for creating the graph
  if (configuration){
    [configuration release];
  }
  configuration = plist;
  [configuration retain];

  //save in file the new configuration
  [c writeToFile: t atomically: YES];

  //graph 
  [self destroyGraph];
  [self parseConfiguration: configuration];

  //interface
  [self refreshInterfaceWithConfiguration: c withTitle: t];

  //let's inform other components that we have changes
  [self hierarchyChanged];
}

- (void) hierarchyChanged
{
  if (configurationParsed){
    if (![self createGraphWithConfiguration: configuration]){
      NSException *exception = [NSException exceptionWithName: @"TrivaException"
                   reason: @"Graph could not be created. Check configuration."
                 userInfo: nil];
      [exception raise];
    }
    [self timeSelectionChanged];
  }
}

- (void) timeSelectionChanged
{
  static int first_time = 1;
  if (first_time){
    first_time = 0;
  }else{
    [self redefineLayoutOfGraphWithConfiguration: configuration];
    [super timeSelectionChanged];
  }
}

- (void) entitySelectionChanged
{
  [self timeSelectionChanged];
}

- (void) containerSelectionChanged
{
  [self timeSelectionChanged];
}

- (void) dataChangedForEntityType: (PajeEntityType *) type
{
  [self timeSelectionChanged];
}

- (double) calculateScreenSizeBasedOnValue: (double) size
  andMax: (double)max andMin: (double)min
{
  double s = 0;
  if ((max - min) != 0) {
    s = MAX_SIZE * (size) /
      (max - min);
  }else{
    s = MAX_SIZE * (size) /(max);
  }
  return s * [self graphComponentScaling];
}

/*
//TODO: OLD CODE _ get X and Y variables from TRACE

- (double) getVariableOfTypeName: (NSString *)variable
            ofContainerName: (NSString *)cont
{
  PajeEntityType *type = [self entityTypeWithName: variable];
  PajeContainerType *containerType = [self containerTypeForType: type];
  PajeContainer *container = [self containerWithName: cont
                                        type: containerType];
  if (!type) return 0;
  NSEnumerator *en = [self enumeratorOfEntitiesTyped: type
                          inContainer: container
                              fromTime: [self startTime]
                                toTime: [self endTime]
                                  minDuration: 0];
  id ent;
  while ((ent = [en nextObject])){
    if (ent){
      return [ent doubleValue];
    }
  }
  return 0;
}


//TODO: get X and Y from traces
- (void) redefineLayoutOf: (TrivaGraphNode*) obj
{
  if (0){
  }else{
    //ok, user registered in the tracefile the values of x and y
    //we should not take their values integrated in time, because
    //they can be negative values.... 
    NSString *xconf = [objconf objectForKey: @"x"];
    NSString *yconf = [objconf objectForKey: @"y"];

    bb.origin.x=[self getVariableOfTypeName: xconf ofContainerName: [obj name]];
    bb.origin.y=[self getVariableOfTypeName: yconf ofContainerName: [obj name]];

    PajeEntityType *xtype = [self entityTypeWithName: xconf];
    PajeEntityType *ytype = [self entityTypeWithName: yconf];

    double xmax = FLT_MAX, xmin = -FLT_MAX, ymax = FLT_MAX, ymin = -FLT_MAX;
    xmin = [self minValueForEntityType: xtype];
    xmax = [self maxValueForEntityType: xtype];
    ymin = [self minValueForEntityType: ytype];
    ymax = [self maxValueForEntityType: ytype];

    graphSize.origin.x = xmin - (xmax-xmin)*.1;
    graphSize.origin.y = ymin - (ymax-ymin)*.1;
    graphSize.size.width = xmax-xmin + 2*((xmax-xmin)*.1);
    graphSize.size.height = ymax-ymin + 2*((ymax-ymin)*.1);
  }

//(...) 

  //TODO: converting from graphviz center point to top-left origin
  if (userPositions == NO){
    bb.origin.x = bb.origin.x - bb.size.width/2;
    bb.origin.y = bb.origin.y - bb.size.height/2;
  }
*/

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
    }else if([key isEqualToString: @"gc_apply"]){
      apply = YES;
    }
  }

  if (apply){
    if (gc){
      [self setGraphConfiguration: gc
                        withTitle: gct];
    }else{
      //nothing to apply, try GUI
      [self apply: self];
    }
  }
}

- (void) show
{
  if (!hideWindow){
    [window orderFront: self];
  }
}
@end
