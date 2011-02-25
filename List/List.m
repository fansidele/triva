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
#include "List.h"

@implementation List
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
  }
  return self;
}

- (void) list: (id) type level: (int) level
{
  NSEnumerator *en = [[self containedTypesForContainerType: type]
                        objectEnumerator];
  id et;
  NSLog(@"i%*.*s%@", level, level, "", [type description]);
  int tlevel = level+1;
  while ((et = [en nextObject]) != nil) {
    if ([self isContainerEntityType: et]) {
      [self list: et level: level+2];      
    }else{
      if ([et isKindOfClass: [PajeStateType class]]){
        NSLog (@"s%*.*s%@", tlevel, tlevel, "", [et description]);
      }else if ([et isKindOfClass: [PajeLinkType class]]){
        NSLog (@"l%*.*s%@", tlevel, tlevel, "", [et description]);
      }else if ([et isKindOfClass: [PajeVariableType class]]){
        NSLog (@"v%*.*s%@", tlevel, tlevel, "", [et description]);
      }else if ([et isKindOfClass: [PajeEventType class]]){
        NSLog (@"e%*.*s%@", tlevel, tlevel, "", [et description]);
      }
    }
  }
  return;
}

- (void)hierarchyChanged
{
  [self list: [[self rootInstance] entityType] level: 0];
  exit(0);
}

@end
