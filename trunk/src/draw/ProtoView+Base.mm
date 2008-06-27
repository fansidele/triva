#include "ProtoView.h"
#include "TrivaTreemapSquarified.h"

@implementation ProtoView (Base)
- (BOOL) squarifiedTreemapWithFile: (NSString *) file
{
	if (baseState != SquarifiedTreemap){
		[self disableVisualizationBase: baseState];
	}

	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: file];
	if (dict == nil){
		return NO;
	}
	TrivaTreemapSquarified *root;
	root = [TrivaTreemapSquarified treemapWithDictionary: dict];
	[root calculateWithWidth: 500 height: 400];
//	[root navigate];


	drawManager->drawSquarifiedTreemap (root);

	baseState = SquarifiedTreemap;	
	return YES;
}

- (BOOL) originalTreemapWithFile: (NSString *) file
{
	if (baseState != OriginalTreemap){
		[self disableVisualizationBase: baseState];
	}
	baseState = OriginalTreemap;
	return YES;
}

- (BOOL) resourcesGraphWithFile: (NSString *) file
{
	if (baseState != ResourcesGraph){
		[self disableVisualizationBase: baseState];
	}
	baseState = ResourcesGraph;
	return YES;
}

- (BOOL) applicationGraph
{
	if (baseState != ApplicationGraph){
		[self disableVisualizationBase: baseState];
	}
	baseState = ApplicationGraph;
	return YES;
}

- (void) disableVisualizationBase: (TrivaVisualizationBaseState) baseCode
{
	if (baseCode == SquarifiedTreemap){

	}else if (baseCode == OriginalTreemap){

	}else if (baseCode == ResourcesGraph){

	}else if (baseCode == ApplicationGraph){

	}else{
		//launch exception?
	}
}
@end
