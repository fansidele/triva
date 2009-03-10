#ifndef __TIMESLICE_H
#define __TIMESLICE_H
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "Treemap.h"
#include "TreeIntegrated.h"

/**
 * <code>TimeSlice</code> interacts with other Paje filters (through
 * enumerators) to create a hierarchical structure that represents the
 * behavior of selected entity types instances for a certain interval of time.
 */
@interface TimeSlice  : PajeFilter
{
	NSDate *sliceStartTime;
	NSDate *sliceEndTime;

	Treemap *treemap;

	/* Configuration */
	BOOL fillWithEmptyNodes;
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
- (Treemap *) treemapWithWidth: (int) width
		     andHeight: (int) height
		      andDepth: (int) depth;

/**
 * Method returns a string describing a certain node of the treemap. The
 * description depends on the type of the node.
 */
- (NSString *) descriptionForNode: (Treemap *) node;

/**
 * Internal method that implements the time slice algorithm.
 */
- (void) timeSliceAt: (id) instance 
	      ofType: (id) type
	    withNode: (Treemap *) node;

/**
 * Internal method that is called by the hierarchyChanged implementation of
 * this filter. It creates a hierarchical structure (by allocating Treemap
 * objects) considering paje containers type and their instances. It also
 * applies to this structure the time slice algorithm, through the timeSliceAt
 * method.
 */
- (Treemap *) createInstanceHierarchy: (id) instance parent:(Treemap *) parent;

/**
 * Internal method to limit the treemap to a certain depth. Its
 * implementation results in an aggregated tree with intermediary
 * nodes annotated with a summary of leaf nodes.
 */
- (void) limitTreemap: (Treemap *) tree toDepth: (int) depth;

@end

#endif
