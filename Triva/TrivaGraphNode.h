#ifndef __TrivaGraphNode_h
#define __TrivaGraphNode_h
#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>

@interface TrivaGraphNode : NSObject
{
	NSString *name;
	NSRect size;
	NSPoint position;
	NSDictionary *values; //color is implemented with a single value = 1
	BOOL separation; //indicates if a separation of values is used
		//if separation is YES, values variable has
		//	proportional values where the sum of them is < 1
	BOOL color; // indicates if a single color is used
		//if color is YES, values has just one key = 1
	BOOL gradient; //indicates if a gradient color is used
		//if gradient is YES, values has a color, a max and a min value

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
- (void) setSeparation: (BOOL) v;
- (void) setColor: (BOOL) v;
- (void) setGradient: (BOOL) v;
- (void) setDrawable: (BOOL) v;
- (BOOL) separation;
- (BOOL) color;
- (BOOL) gradient;
- (BOOL) drawable;
@end

#endif
