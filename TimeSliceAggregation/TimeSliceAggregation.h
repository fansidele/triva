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
#ifndef __TIMESLICE_H
#define __TIMESLICE_H
#include <Foundation/Foundation.h>
#include <Triva/TrivaFilter.h>
#include <Triva/TimeSliceTree.h>
#include <Triva/TimeSliceGraph.h>

/**
 * <code>TimeSlice</code> interacts with other Paje filters (through
 * enumerators) to create a hierarchical structure that represents the
 * behavior of selected entity types instances for a certain interval of time.
 */
@interface TimeSliceAggregation  : TrivaFilter
{
  TimeSliceTree *tree;

  //dictionary to keep timeslicetree node names
  NSMutableDictionary *nodeNames; /*(NSString*)->(TimeSliceTree*) */

  /* Configuration */
  BOOL considerExclusiveDuration;
  BOOL graphAggregationEnabled;
}
/**
 * Internal method that implements the time slice algorithm.
 */
- (void) timeSliceAt: (id) instance 
        ofType: (PajeEntityType*) type
      withNode: (TimeSliceTree *) node;

/**
 * Internal method that is called by the hierarchyChanged implementation of
 * this filter. It creates a hierarchical structure (by allocating Tree
 * objects) considering paje containers type and their instances. It also
 * applies to this structure the time slice algorithm, through the timeSliceAt
 * method.
 */
- (TimeSliceTree *) createInstanceHierarchy: (id) instance parent:(TimeSliceTree *) parent;
@end

@interface TimeSliceAggregation (State)
- (void) timeSliceOfStateAt: (id) instance
    withType: (PajeStateType*) type
    withNode: (TimeSliceTree *) node;
@end

@interface TimeSliceAggregation (Variable)
- (void) timeSliceOfVariableAt: (id) instance
    withType: (PajeVariableType*) type
    withNode: (TimeSliceTree *) node;
@end

@interface TimeSliceAggregation (Link)
- (void) timeSliceOfLinkAt: (id) instance
    withType: (PajeLinkType*) type
    withNode: (TimeSliceTree *) node;
- (void) createGraphBasedOnLinks: (id) instance
      withTree: (TimeSliceTree *) node;
@end

@interface TimeSliceAggregation (Debugging)
#ifdef GNUSTEP
- (void) debug;
- (void) activateRecordingOfClass: (NSString *)classname;
- (void) listRecordedObjectsOfClass: (NSString *) classname;
- (void) debugOf: (PajeEntityType*) type At: (PajeContainer*) container;
#endif
@end

#endif
