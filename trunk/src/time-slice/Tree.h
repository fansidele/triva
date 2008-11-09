#include <Foundation/Foundation.h>

@interface Tree : NSObject
{
	NSString *name;
	Tree *parent;
	NSMutableArray *children;
}
- (NSString *) name;
- (NSArray *) children;
- (Tree *) parent;
- (Tree *) searchChildByName: (NSString *) n;

- (void) setName: (NSString *) n;
- (void) setParent: (Tree *) p;
- (void) addChild: (Tree *) c;
@end
