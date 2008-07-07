#include "ProtoView.h"

@implementation ProtoView (Base)
- (BOOL) squarifiedTreemapWithFile: (NSString *) file
	andWidth: (float) w andHeight: (float) h
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
	[squarifiedTreemap setMainWidth: w];
	[squarifiedTreemap setMainHeight: h];
	[squarifiedTreemap calculateWithWidth: w height: h];
	drawManager->squarifiedTreemapDraw (squarifiedTreemap);

	baseState = SquarifiedTreemap;	
	[self hierarchyChanged];
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
	[self hierarchyChanged];
	return YES;
}

- (void) disableVisualizationBase: (TrivaVisualizationBaseState) baseCode
{
	if (baseCode == SquarifiedTreemap){
		drawManager->squarifiedTreemapDelete ();
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
					[treemap incrementNumberOfContainers];
				}
			}
		}
	}
}

- (void) recalculateSquarifiedTreemapWithApplicationData
{
	id instance = [self rootInstance];
	[squarifiedTreemap recursiveResetValue];
	[squarifiedTreemap recursiveResetNumberOfContainers];
	[self recalculateSquarifiedTreemapsWith: instance];
	[squarifiedTreemap recalculate];
}

// for application graph
- (NSMutableDictionary *) dictionaryForApplicationGraph: (id) entity
{
        NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *me = [[NSMutableDictionary alloc] init];

        NSEnumerator *en = [[self containedTypesForContainerType:[self entityTypeForEntity:entity]] objectEnumerator];
        PajeEntityType *et;
        while ((et = [en nextObject]) != nil) {
                if ([self isContainerEntityType:et]) {
                        NSEnumerator *en2;
                        PajeContainer *sub;
                        en2 = [self enumeratorOfContainersTyped:et inContainer:entity];
                        while ((sub = [en2 nextObject]) != nil) {
                                NSMutableDictionary *d;
				d = [self dictionaryForApplicationGraph: sub];
                                [me addEntriesFromDictionary: d];
                        }
                }
        }
        [ret setObject: me forKey: [entity name]];
        [me release];
        [ret autorelease];
        return ret;
}

- (void) recalculateApplicationGraphWithApplicationData
{
	id instance = [self rootInstance];
	if (applicationGraphPosition != nil){
		[applicationGraphPosition release];
		applicationGraphPosition = nil;
	}	
	applicationGraphPosition = [Position positionWithAlgorithm:@"graphviz"];
	[applicationGraphPosition newHierarchyOrganization: 
			[self dictionaryForApplicationGraph: instance]];

        NSEnumerator *en = [[self containedTypesForContainerType:[self entityTypeForEntity:instance]] objectEnumerator];
        PajeEntityType *et;
        while ((et = [en nextObject]) != nil) {
                if ([et isKindOfClass: [PajeLinkType class]]){
                        NSEnumerator *en4;
                        en4 = [self enumeratorOfEntitiesTyped: et
                        inContainer: instance
                        fromTime:[self startTime]
                        toTime:[self endTime]
                        minDuration: 0];
                        PajeEntity *ent;
                        while ((ent = [en4 nextObject]) != nil) {
                                NSString *sn = [[ent sourceContainer] name];
                                NSString *dn = [[ent destContainer] name];
                                [applicationGraphPosition 
					addLinkBetweenNode: sn andNode: dn];

                        }

                }
        }
	//applicationGraphPosition contains PositionGraphviz
	[applicationGraphPosition refresh];
}
@end
