#ifndef __TIMESLICE_H
#define __TIMESLICE_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "TimeSliceTree.h"

/**
 * <code>TimeSlice</code> interacts with other Paje filters (through
 * enumerators) to create a hierarchical structure that represents the
 * behavior of selected entity types instances for a certain interval of time.
 */
@interface TimeSliceAggregation  : PajeFilter
{
	NSDate *sliceStartTime;
	NSDate *sliceEndTime;

	TimeSliceTree *tree;

	BOOL sliceTimeChanged; /* to control the hierarchy creation */

	/* Configuration */
	BOOL considerExclusiveDuration;
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

/**
 * Internal method to limit the treemap to a certain depth. Its
 * implementation results in an aggregated tree with intermediary
 * nodes annotated with a summary of leaf nodes. Leaf nodes are removed from
 * the structure.
 */
- (void) limitTree: (TimeSliceTree *) tree
		toDepth: (int) depth
		toValues: (NSSet *) values;

/**
 * Method so other Triva components can take an aggregated hierarchical
 * structure
 */
- (TimeSliceTree *) timeSliceTree;
@end

#endif
