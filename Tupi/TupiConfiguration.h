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
#ifndef __TupiConfiguration_h
#define __TupiConfiguration_h
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

@protocol TupiConfiguration
- (BOOL) graphviz;
- (BOOL) userPosition;
- (NSRect) userRect;
- (NSArray*) nodeTypes;
- (NSArray*) edgeTypes;
@end

@interface TupiConfiguration : NSObject <TupiConfiguration>
{
  NSDictionary *configuration;
  BOOL graphviz;
  BOOL userPosition;
  NSRect userRect;
  NSArray *nodeTypes;
  NSArray *edgeTypes;
  NSString *graphvizAlgorithm;
}
- (id) initWithDictionary: (NSDictionary*) conf;
- (NSDictionary*) configurationForType: (NSString*) type;
- (NSString*) graphvizAlgorithm;
@end

#endif
