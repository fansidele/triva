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
#ifndef __TRIVA_COMMAND_H
#define __TRIVA_COMMAND_H
#include <Foundation/Foundation.h>
#include <Triva/Triva.h>

typedef enum { TrivaHelp,
               TrivaError,
               TrivaCommandConfigured } TrivaCommandState;

@interface TrivaCommand : NSObject
{
  TrivaCommandState state;
  TrivaConfiguration *configuration;
}
+ (void) printSingleOption: (NSString *) name
            withAttributes: (NSDictionary *) attr;
+ (void) printFirstLevelOptions: (NSDictionary*) dict;
+ (void) printOptions: (NSDictionary*) dictionary;
- (id) initWithString: (NSString *) str
    andDefaultOptions: (NSDictionary *) options;
- (id) initWithArguments: (const char**)argv
                 andSize: (int) argc
       andDefaultOptions: (NSDictionary *) options;
- (TrivaCommandState) state;
- (TrivaConfiguration *) configuration;
@end

#endif
