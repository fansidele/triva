#ifndef __TypeFilter_h
#define __TypeFilter_h
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>

@interface TypeFilter  : PajeFilter
{
	NSMutableDictionary *hiddenEntityValues;
	NSMutableSet *hiddenEntityTypes;
	NSMutableSet *hiddenContainers;

	BOOL enableNotifications;
}
- (void) setNotifications: (BOOL) notifications;
- (BOOL) isHiddenEntityType: (PajeEntityType *) type;
- (BOOL) isHiddenValue: (NSString *) value forEntityType: (PajeEntityType*)type;
- (BOOL) isHiddenContainer: (PajeContainer *) container forEntityType: (PajeEntityType*)type;
- (void) filterEntityType: (PajeEntityType *) type
                     show: (BOOL) show;
- (void) filterValue: (NSString *) value
       forEntityType: (PajeEntityType *) type
                show: (BOOL) show;
- (void) filterContainer: (PajeContainer *) container
                    show: (BOOL) show;
- (PajeFilter *) inputComponent;
- (NSArray *)unfilteredObjectsForEntityType:(PajeEntityType *)entityType;
@end

#endif
