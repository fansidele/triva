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
#include "TrivaConfiguration.h"

@implementation TrivaConfiguration
- (id) init
{
  self = [super init];
  conf = [[NSMutableDictionary alloc] init];
  input = [[NSMutableArray alloc] init];
  ignorable = NO;
  return self;
}

- (id) initWithString: (NSString *) commands
          andDefaultOptions: (NSDictionary *) options
{
  self = [self init];

  NSException *ex;
  NSString *reason;
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  NSEnumerator *en = [options keyEnumerator];
  NSString *key;
  while ((key = [en nextObject])){
    [dict addEntriesFromDictionary: [options objectForKey: key]];
  }


  NSArray *ar = [commands componentsSeparatedByString: @" "];
  int i;
  for (i = 0; i < [ar count]; i++){
    const char *option = [[ar objectAtIndex: i] cString];
    const char *option_par;
    if (i+1 < [ar count]) option_par = [[ar objectAtIndex: i+1] cString];
    else option_par = NULL;

    //help escape
    if (!strcmp (option, "--help") || !strcmp (option, "-h")){
      state = TrivaConfigurationHelp;
      return self;
    }

    NSMutableString *optx = [NSMutableString stringWithFormat: @"%s", option];
    NSString *opt_par = [NSString stringWithFormat: @"%s", option_par];
    //check if option contains -'s, if it doens't consider as input file
    NSRange range = [optx rangeOfString: @"-"];
    if (range.length == 0 || (range.location != 0 && range.length != 0)) {
      [self addInputFile: optx];
      continue;
    }
    //treat as normal option 
    NSString *opt;
    opt = [optx stringByReplacingOccurrencesOfString: @"-" withString: @""];
    id detail = [dict objectForKey: opt];
    if (!detail){
      reason = [NSString stringWithFormat: @"unknown parameter %s", option];
      ex = [NSException exceptionWithName: @"TrivaCommandLineException"
                                   reason: reason
                                 userInfo: nil];
      [ex raise];
    }else{
      //check type
      NSString *type = [detail objectForKey: @"type"];
      if ([type isEqualToString: @"bool"]){
        [self setOption: opt withValue: @"1"];
      }else{
        //check parameter for option
        NSRange range = [opt_par rangeOfString: @"-"];
        if (range.location == 0 && (range.length == 1 || range.length == 2)){
          reason = [NSString stringWithFormat:
               @"parameter %s must be followed by a %@", option,
                  [detail objectForKey: @"type"]];
          ex = [NSException exceptionWithName: @"TrivaCommandLineException"
                                       reason: reason
                                     userInfo: nil];
          [ex raise];
        }else{
          [self setOption: opt withValue: opt_par];
          i++; //we used opt_par
        }
      }
    }
  }
  state = TrivaConfigurationOK;
  return self;
}

- (id) initWithArguments: (const char**)argv
                 andSize: (int) argc
       andDefaultOptions: (NSDictionary *) options
{
  self = [self init];

  NSMutableString *commands = [NSMutableString string];
  int i;
  for (i = 1; i < argc; i++){
    char *option = (char*)argv[i];
    [commands appendString: [NSString stringWithFormat: @"%s", option]];
    if (i + 1 < argc) [commands appendString: @" "];
  }
  return [self initWithString: commands andDefaultOptions: options];
}

- (void) dealloc
{
  [conf release];
  [input release];
  [super dealloc];
}

- (TrivaVisualizationComponent) visualizationComponent
{
  TrivaVisualizationComponent comp = 0;
  NSLog (@"%@", conf);
  if ([conf objectForKey: @"graph"]) comp |= TrivaGraphView;
  if ([conf objectForKey: @"treemap"]) comp |= TrivaSquarifiedTreemap;
  if ([conf objectForKey: @"merge"]) comp |= TrivaMerge;
  if ([conf objectForKey: @"comparison"]) comp |= TrivaComparison;
  if ([conf objectForKey: @"linkview"]) comp |= TrivaLinkView;
  if ([conf objectForKey: @"stat"]) comp |= TrivaStat;
  if ([conf objectForKey: @"check"]) comp |= TrivaCheck;
  if ([conf objectForKey: @"hierarchy"]) comp |= TrivaHierarchy;
  if ([conf objectForKey: @"list"]) comp |= TrivaList;
  if ([conf objectForKey: @"instances"]) comp |= TrivaInstances;
  NSLog (@"%s %d", __FUNCTION__, comp);
  return comp;
}

- (void) setOption: (NSString*) option withValue: (NSString*) value
{
  [conf setObject: value forKey: option];
}

- (void) addInputFile: (NSString *) filename
{
  [input addObject: filename];
}

- (void) removeAllInputFiles
{
  [input removeAllObjects];
}

- (NSArray *) inputFiles
{
  return input;
}

- (NSString*) description
{
  NSMutableString *ret = [NSMutableString string];
  NSEnumerator *en = [conf keyEnumerator];
  NSString *key;
  [ret appendString: @"configuration: "];
  while ((key = [en nextObject])) {
    [ret appendString:
      [NSString stringWithFormat: @"%@ = %@ ", key, [conf objectForKey: key]]];
  }
  en = [input objectEnumerator];
  NSString *filename;
  [ret appendString: @"; input files: "];
  while ((filename = [en nextObject])){
    [ret appendString: 
      [NSString stringWithFormat: @"%@, ", filename]];
  }
  [ret appendString: @"\n"];
  return ret;
}

- (NSDictionary *) configuredOptions
{
  return conf;
}

- (NSDictionary *) configuredOptionsForClass: (Class) componentClass
{
  //extract configuration for componentClass and put in ret dictionary
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];
  NSDictionary *options = conf;
  NSDictionary *base; 
  NSEnumerator *en;
  NSString *key;
  base = [[componentClass defaultOptions]
              objectForKey: NSStringFromClass(componentClass)];
  en = [base keyEnumerator];
  while ((key = [en nextObject])){
    //NSString *value = [options objectForKey: key];
    if ([options objectForKey: key]){
      [ret setObject: [options objectForKey: key] forKey: key];
    }
  }

  return ret;
}

- (BOOL) serverMode
{
  if ([conf objectForKey: @"server"]){
    return YES;
  }else{
    return NO;
  }
}

- (int) serverPort
{
  if ([self serverMode]){
    return [[conf objectForKey: @"server"] intValue];
  }else{
    return -1;
  }
}

- (TrivaConfigurationState) configurationState
{
  return state;
}

- (void) setIgnore: (BOOL) ign
{
  ignorable = ign;
}

- (BOOL) ignore
{
  return ignorable;
}
@end
