#include <Foundation/Foundation.h>
#include "TreeValue.h"

@interface Treemap : TreeValue 
{
	float width, height;
	float x, y;
	float depth;
}
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

- (void) calculateWithWidth: (float) w andHeight: (float) h;
- (void) calculateWithWidth: (float) W
              height: (float) H
              factor: (float) factor
                depth: (float) d;
@end
