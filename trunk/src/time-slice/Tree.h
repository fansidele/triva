#ifndef __TREE_H_
#define __TREE_H_

#include <Foundation/Foundation.h>

@interface Tree : NSObject
{
	NSString *name;
	Tree *parent;
	NSMutableArray *children;
	int depth;
}
- (int) depth;
- (void) setDepth: (int) d;
- (int) maxDepth;

- (NSString *) name;
- (NSArray *) children;
- (Tree *) parent;
- (Tree *) searchChildByName: (NSString *) n;

- (void) setName: (NSString *) n;
- (void) setParent: (Tree *) p;
- (void) addChild: (Tree *) c;
- (void) removeAllChildren;
@end

#endif
