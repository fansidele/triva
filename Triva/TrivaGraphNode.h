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
		//if gradient is YES, the following variables must be defined
	NSString *gradientType;
	double gradientValue;
	double gradientMax;
	double gradientMin;

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

- (void) setGradientType: (NSString *) type withValue: (double) val
		withMax: (double) max withMin: (double) min;
- (NSString *) gradientType;
- (double) gradientValue;
- (double) gradientMax;
- (double) gradientMin;
@end

#endif
