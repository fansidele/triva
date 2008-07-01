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
	[squarifiedTreemap setMainWidth: 500];
	[squarifiedTreemap setMainHeight: 400];
	[squarifiedTreemap calculateWithWidth: 500 height: 400];

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

- (void) recalculateSquarifiedTreemapsWith: (id) entity;
{
	/* TODO: this method must be configurable because it updates
		the squarified treemap visualization base based on the
		application data (paje trace) 
		
		For now, it uses the presence of a container in a
		treemap node to change its value and recalculate the
		squarified treemap.

		After calling this method, the visualization base must
		be updated.
	*/
	PajeEntityType *et;
	NSEnumerator *en = [[self containedTypesForContainerType:[self entityTypeForEntity: entity]] objectEnumerator];
	while ((et = [en nextObject]) != nil) {
		if ([self isContainerEntityType:et]) {
			PajeContainer *sub;
			NSEnumerator *en2 = [self enumeratorOfContainersTyped:et inContainer: entity];
			while ((sub = [en2 nextObject]) != nil) {
				TrivaTreemap *treemap = [self
					searchWithPartialName: [sub name]];
				if (treemap == nil){
					NSLog (@"error, throw exception?");
				}else{
					[treemap incrementValue];
				}
			}
		}
	}
}

- (void) recalculateSquarifiedTreemapWithApplicationData
{
	id instance = [self rootInstance];
	[self recalculateSquarifiedTreemapsWith: instance];
	[squarifiedTreemap recalculate];
}
@end
