#ifndef __TypeFilter_h
#define __TypeFilter_h
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>

@interface TypeFilter  : PajeFilter
{
	NSMutableSet *hiddenEntityTypes;
	NSMutableSet *hiddenContainers;
}
- (BOOL) isHiddenEntityType: (PajeEntityType *) type;
- (BOOL) isHiddenValue: (NSString *) value forEntityType: (PajeEntityType*)type;
- (BOOL) isHiddenContainer: (PajeContainer *) container forEntityType: (PajeEntityType*)type;
- (void) hideEntityType: (PajeEntityType *) type;
- (void) showEntityType: (PajeEntityType *) type;
- (void) hideValue: (NSString *) value forEntityType: (PajeEntityType *) type;
- (void) showValue: (NSString *) value forEntityType: (PajeEntityType *) type;
- (void) hideContainer: (PajeContainer *) container;
- (void) showContainer: (PajeContainer *) container;
- (PajeFilter *) inputComponent;
@end

#endif
