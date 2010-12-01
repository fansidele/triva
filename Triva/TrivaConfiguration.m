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
  return self;
}

- (void) dealloc
{
  [conf release];
  [input release];
  [super dealloc];
}

- (TrivaVisualizationComponent) visualizationComponent
{
  if ([conf objectForKey: @"graph"]) return TrivaGraphView;
  if ([conf objectForKey: @"treemap"]) return TrivaSquarifiedTreemap;
  if ([conf objectForKey: @"merge"]) return TrivaMerge;
  if ([conf objectForKey: @"comparison"]) return TrivaComparison;
  if ([conf objectForKey: @"linkview"]) return TrivaLinkView;
  if ([conf objectForKey: @"stat"]) return TrivaStat;
  if ([conf objectForKey: @"check"]) return TrivaCheck;
  if ([conf objectForKey: @"hierarchy"]) return TrivaHierarchy;
  if ([conf objectForKey: @"list"]) return TrivaList;
  if ([conf objectForKey: @"instances"]) return TrivaInstances;
  return TrivaCheck;
}

- (void) setOption: (NSString*) option withValue: (NSString*) value
{
  [conf setObject: value forKey: option];
}

- (void) addInputFile: (NSString *) filename
{
  [input addObject: filename];
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
    NSString *value = [options objectForKey: key];
    if ([options objectForKey: key]){
      [ret setObject: [options objectForKey: key] forKey: key];
    }
  }

  return ret;
}
@end
