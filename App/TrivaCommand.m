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
#include "TrivaCommand.h"

@implementation TrivaCommand
- (id) initWithArguments: (const char**)argv
                 andSize: (int) argc
       andDefaultOptions: (NSDictionary *) options
{
  configuration = [[TrivaConfiguration alloc] init];
  NSException *ex;
  NSString *reason;
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  NSEnumerator *en = [options keyEnumerator];
  NSString *key;
  while ((key = [en nextObject])){
    [dict addEntriesFromDictionary: [options objectForKey: key]];
  }

  self = [super init];
  int i;
  for (i = 1; i < argc; i++){
    char *option = (char*)argv[i];
    char *option_par = (char*)argv[i+1];

    //help escape
    if (!strcmp (option, "--help") || !strcmp (option, "-h")){
      state = TrivaHelp;
      return self;
    }
    
    NSString *opt = [NSString stringWithFormat: @"%s", option];
    NSString *opt_par = [NSString stringWithFormat: @"%s", option_par];
    //check if option contains -'s, if it doens't consider as input file
    NSRange range = [opt rangeOfString: @"-"];
    if (range.length == 0 || (range.location != 0 && range.length != 0)) {
      [configuration addInputFile: opt];
      continue;
    }
    //treat as normal option 
    opt = [opt stringByReplacingOccurrencesOfString: @"-" withString: @""];
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
        [configuration setOption: opt withValue: @"1"];
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
          [configuration setOption: opt withValue: opt_par];
          i++; //we used opt_par
        }
      }
    }
  }
  state = TrivaCommandConfigured;
  return self;
}

- (TrivaCommandState) state
{
  return state;
}

- (TrivaConfiguration *) configuration
{
  return configuration;
}

+ (void) printSingleOption: (NSString *) name
            withAttributes: (NSDictionary *) attr
{
  NSString *type = [attr objectForKey: @"type"];
  NSString *description = [attr objectForKey: @"description"];
  NSString *simple = [attr objectForKey: @"short"];
  char aux[100];
  if ([type isEqualToString: @"bool"]){
    if (simple){
      snprintf (aux, 100, "    -%s, --%s", [simple cString],
                                           [name cString]);
    }else{
      snprintf (aux, 100, "    --%s", [name cString]);
    }
  }else if ([type isEqualToString: @"double"]){
    if (simple){
      snprintf (aux, 100, "    -%s, --%s {double}", [simple cString],
                                           [name cString]);
    }else{
      snprintf (aux, 100, "    --%s {double}", [name cString]);
    }
  }else if ([type isEqualToString: @"file"]){
    if (simple){
      snprintf (aux, 100, "    -%s, --%s {file}", [simple cString],
                                                  [name cString]);
    }else{
      snprintf (aux, 100, "    --%s {file}", [name cString]);
    }
  }
  int len = strlen (aux);
  printf ("%s%*.*s %s\n", aux, 30-len, 30-len, "", [description cString]);
}

+ (void) printFirstLevelOptions: (NSDictionary*) dict
{
  NSEnumerator *en = [dict keyEnumerator];
  NSString *key;
  BOOL grouped = [dict objectForKey: @"grouped"] ? YES : NO;
  while ((key = [en nextObject])){
    if ([key isEqualToString: @"grouped"]) continue;
    id contents = [dict objectForKey: key];
    if (grouped){
      printf ("  %s:\n", [key cString]);
      NSEnumerator *en2 = [contents keyEnumerator];
      NSString *name;
      while ((name = [en2 nextObject])){
        [self printSingleOption: name
               withAttributes: [contents objectForKey: name]];
      } 
    }else{
      [self printSingleOption: key
               withAttributes: contents];
    }
  }
}

+ (void) printOptions: (NSDictionary*) dictionary
{
  NSEnumerator *en = [dictionary keyEnumerator];
  NSString *key;
  printf ("Usage: Triva [OPTIONS...] TRACE0 [TRACE1]\n");
  printf ("Trace Analysis through Visualization\n");
  printf ("\n");
  while ((key = [en nextObject])){
    printf ("%s\n", [key cString]);
    NSDictionary *options = [dictionary objectForKey: key];
    [self printFirstLevelOptions: options];
  }

}
@end
