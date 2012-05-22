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
#ifndef __Entropy_H
#define __Entropy_H
#include <Foundation/Foundation.h>
#include "../Triva/TrivaFilter.h"

@interface Entropy  : TrivaFilter
{
  NSMutableArray *leafContainers;
}
- (NSMutableArray *) leafContainersInContainer: (PajeContainer *) cont;
- (NSMutableArray *) childrenOfContainer: (PajeContainer *) cont;
- (void) addThis: (NSDictionary *) origin
          toThis: (NSMutableDictionary *) destination;
- (void) subtractThis: (NSDictionary *) origin
             fromThis: (NSMutableDictionary *) destination;
- (NSDictionary*) vzeroOfType: (PajeEntityType*) type;
@end

#endif
