#include "ProtoView.h"

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
	if (squarifiedTreemap != nil){
		[squarifiedTreemap release];
		squarifiedTreemap = nil;
	}

	squarifiedTreemap = [TrivaTreemapSquarified treemapWithDictionary:dict];
	[squarifiedTreemap calculateWithWidth: 500 height: 400];

	drawManager->squarifiedTreemapDraw (squarifiedTreemap);

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

- (TrivaTreemap *) searchWithPartialName: (NSString *) partialName
{
	if (baseState == SquarifiedTreemap){
		return [squarifiedTreemap searchWithPartialName: partialName];
	}else{
		return nil;
	}
}
@end
