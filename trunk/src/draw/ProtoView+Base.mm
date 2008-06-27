#include "ProtoView.h"
#include "TrivaTreemapSquarified.h"

@implementation ProtoView (Base)
- (BOOL) squarifiedTreemapWithFile: (NSString *) file
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: file];
	if (dict == nil){
		return NO;
	}
	TrivaTreemapSquarified *root;
	root = [TrivaTreemapSquarified treemapWithDictionary: dict];
	[root calculateWithWidth: 500 height: 400];
//	[root navigate];


	drawManager->drawSquarifiedTreemap (root);
	
	return YES;
}

- (BOOL) originalTreemapWithFile: (NSString *) file
{
	return YES;
}


@end
