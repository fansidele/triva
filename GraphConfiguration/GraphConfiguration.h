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
#ifndef __GraphConfiguration_h
#define __GraphConfiguration_h
#include <graphviz/gvc.h>
#include "../Triva/TrivaFilter.h"
#include "../Triva/TrivaWindow.h"

@interface GraphConfiguration : TrivaFilter
{
  // current graph configuration 
  NSDictionary *currentGraphConfiguration;

  //values, colors, min, max dictionaries
  NSMutableDictionary *colors;
  NSMutableDictionary *minValues;
  NSMutableDictionary *maxValues;

  // interface variables 
  id confView;
  NSTextField *title;
  NSButton *ok;
  TrivaWindow *window;

  BOOL hideWindow;

  //to get node position from graphviz dot file
  Agraph_t *graph;
  GVC_t *gvc;
}
/*
 * Called by interface and command-line options to set a new configuration
 */
- (void) saveGraphConfiguration: (NSString *) conf
                      withTitle: (NSString *) t;
/*
 * Called by interface and command-line options to apply the new configuration
 */
- (void) applyGraphConfiguration;

//
- (void) resetMinMaxColor;
- (void) updateMinMaxColorForContainerType:(PajeEntityType*)type;
@end

@interface GraphConfiguration (Interface)
- (void) initInterface;
- (void) refreshInterfaceWithConfiguration: (NSString *) gc
                      withTitle: (NSString *) gct;
- (void) apply: (id)sender;
- (void) updateTitle: (id)sender;
- (void) textDidChange: (id) sender;
@end

@interface GraphConfiguration (Protocol)
@end

#endif
