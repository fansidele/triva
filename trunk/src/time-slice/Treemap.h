#include <Foundation/Foundation.h>
#include "TreeValue.h"

@interface Treemap : TreeValue 
{
	float width, height;
	float x, y;
	int depth;
}
- (float) width;
- (float) height;
- (float) x;
- (float) y;
- (int) depth;

- (void) setWidth: (float) w;
- (void) setHeight: (float) h;
- (void) setX: (float) xp;
- (void) setY: (float) yp;
- (void) setDepth: (int) d;

- (void) calculateWithWidth: (float) w andHeight: (float) h;
- (void) calculateWithWidth: (float) W
              height: (float) H
              factor: (float) factor
                depth: (int) d;
@end
