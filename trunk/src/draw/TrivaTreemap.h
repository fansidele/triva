#ifndef __TRIVA_TREEMAP_H
#define __TRIVA_TREEMAP_H
#include <Foundation/Foundation.h>

@interface TrivaTreemap : NSObject
{
        NSString *name;
	NSString *type;
        float value;

	float width, height;
	float x, y;
	float depth;

	NSMutableArray *children;
}
+ (id) treemapWithDictionary: (id) tree;
- (id) initWithDictionary: (id) tree;
- (id) initWithString: (id) tree;
- (float) value;
- (float) width;
- (float) height;
- (float) x;
- (float) y;
- (float) depth;
- (void) setWidth: (float) w;
- (void) setHeight: (float) h;
- (void) setX: (float) xp;
- (void) setY: (float) yp;
- (void) setDepth: (float) d;
- (NSString *) name;
- (NSString *) type;
- (NSArray *) children;
@end

#endif
