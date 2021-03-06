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
#ifndef __TypeFilter_h
#define __TypeFilter_h
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Renaissance/Renaissance.h>
#include "../Triva/TrivaFilter.h"
#include "../Triva/TrivaWindow.h"
#include <regex.h>

@interface TypeFilter  : TrivaFilter
{
  NSMutableDictionary *hiddenEntityValues;
  NSMutableSet *hiddenEntityTypes;
  NSMutableSet *hiddenContainers;

  BOOL enableNotifications;

  TrivaWindow *window;

  id scrollview;
  id expression;
  id instances;


  id outlineview;
  id matrix;


  id entities;
  id selectedType;

  regex_t *regex;
}
- (void) updateGUI;
- (void) setNotifications: (BOOL) notifications;
- (BOOL) isHiddenEntityType: (PajeEntityType *) type;
- (BOOL) isHiddenValue: (NSString *) value forEntityType: (PajeEntityType*)type;
- (BOOL) isHiddenContainer: (PajeContainer *) container forEntityType: (PajeEntityType*)type;
- (void) filterEntityType: (PajeEntityType *) type
                     show: (BOOL) show;
- (void) filterValue: (NSString *) value
       forEntityType: (PajeEntityType *) type
                show: (BOOL) show;
- (void) filterValues: (NSMutableSet *) set
        forEntityType: (PajeEntityType *) type
                 show: (BOOL) show;
- (void) filterContainer: (PajeContainer *) container
                    show: (BOOL) show;
- (void) filterContainers: (NSSet *) set
                     show: (BOOL) show;
- (PajeFilter *) inputComponent;
- (NSArray *)unfilteredObjectsForEntityType:(PajeEntityType *)entityType;
@end

@interface TypeFilter (GUI)
- (void) configureGUI;
- (void) regularExpression: (id) sender;
@end

#endif
