#ifndef __TrivaGraphNode_h
#define __TrivaGraphNode_h
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>

@interface TrivaGraphNode : NSObject
{
	NSString *name;
	NSRect size;
	NSPoint position;
	NSDictionary *values;

	BOOL drawable; //is it ready to draw?
}
- (void) setName: (NSString *) n;
- (NSString *) name;
- (void) setSize: (NSRect) r;
- (NSRect) size;
- (void) setPosition: (NSPoint) p;
- (NSPoint) position;
- (void) setValues: (NSDictionary*)v;
- (NSDictionary*) values;
- (void) setDrawable: (BOOL) v;
- (BOOL) drawable;
@end

#endif
