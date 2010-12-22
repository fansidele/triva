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
#ifndef __Tupi_h
#define __Tupi_h
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

typedef enum {
  TUPI_NODE,
  TUPI_EDGE,
} TupiType;

@interface Tupi : NSObject
{
  NSString *name;
  NSString *type;
  TupiType tupiType;
  NSMutableSet *connectedNodes;
  NSRect bb;
}
- (void) setName: (NSString *) n;
- (void) setType: (NSString *) n;
- (void) setTupiType: (TupiType) n;
- (void) setBoundingBox: (NSRect) b;
- (void) connectToNode: (Tupi*) n;

- (NSString *) name;
- (NSString *) type;
- (TupiType) tupiType;
- (NSRect) boundingBox;
- (NSSet*) connectedNodes;

- (void) draw;

- (void) layoutWith: (NSDictionary*)conf andValues: (NSDictionary*)values andProvider: (id) provider;
@end

#include <Triva/TrivaComposition.h>
#endif
