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
	NSDate *sliceStartTime;
	NSDate *sliceEndTime;

	TimeSliceTree *tree;

	//dictionary to keep timeslicetree node names
	NSMutableDictionary *nodeNames; /*(NSString*)->(TimeSliceTree*) */

	BOOL sliceTimeChanged; /* to control the hierarchy creation */

	/* Configuration */
	BOOL considerExclusiveDuration;
	BOOL graphAggregationEnabled;
}
/**
 * Method to set the start time for the algorithm.
 */
- (void) setSliceStartTime: (NSDate *) time;

/**
 * Method to set the end time for the algorithm.
 */
- (void) setSliceEndTime: (NSDate *) time;

/**
 * Method that re-calculate the treemap considering the three parameters
 * and the slice start and end time previously defined. It results a 
 * squarified treemap.
 */
//- (TimeSliceTree *) treemapWithWidth: (int) width
//		     andHeight: (int) height
//		      andDepth: (int) depth
//		     andValues: (NSSet *) values;

/**
 * Internal method that implements the time slice algorithm.
 */
- (void) timeSliceAt: (id) instance 
	      ofType: (id) type
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
    withType: (id) type
    withNode: (TimeSliceTree *) node;
@end

@interface TimeSliceAggregation (Variable)
- (void) timeSliceOfVariableAt: (id) instance
    withType: (id) type
    withNode: (TimeSliceTree *) node;
@end

@interface TimeSliceAggregation (Link)
- (void) timeSliceOfLinkAt: (id) instance
    withType: (id) type
    withNode: (TimeSliceTree *) node;
- (void) createGraphBasedOnLinks: (id) instance
      withTree: (TimeSliceTree *) node;
@end

@interface TimeSliceAggregation (Debugging)
- (void) debug;
- (void) activateRecordingOfClass: (NSString *)classname;
- (void) listRecordedObjectsOfClass: (NSString *) classname;
- (void) debugOf: (PajeEntityType*) type At: (PajeContainer*) container;
@end

#endif
