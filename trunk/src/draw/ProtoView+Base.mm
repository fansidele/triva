#include "ProtoView.h"

@implementation ProtoView (Base)
- (void) setCombinedCounterConfiguration: (NSDictionary *) d
{
	[entityTypesChosen release];
	entityTypesChosen = d;
	[entityTypesChosen retain];
	[self hierarchyChanged];
}

- (float) combinedValueFor: (id) entityType inContainer: (id) container
	andConfig: (NSDictionary *) config
{
	/* 
	config is dictionary of multiple: values -> weight 
	of the corresponding entityType passed as parameter
	*/
	float ret = 0;
	NSEnumerator *en;
	PajeEntity *ent;
	en = [self enumeratorOfEntitiesTyped: entityType
                          inContainer: container
                             fromTime: [self startTime]
                               toTime: [self endTime]
                          minDuration: 1/pointsPerSecond];
	while ((ent = [en nextObject]) != nil) {
		NSString *weight = [config objectForKey: [ent value]];
		if (weight != nil){
			ret += [weight floatValue];
		}
	}
	return ret;
}

- (float) calculateValueForContainer: (id) container
{
	/* 
	input: (id) container,
	from config.: (NSDictionary *) entityTypesChosen
		key is the name of the entity type
		value is a dictionary
			keys are possible values
			values are corresponding weights 
	*/
	/* return value */
	float ret = 1;

	if (entityTypesChosen == nil){
		return ret;
	}

	NSSet *auxSet = [NSSet setWithArray: [entityTypesChosen allKeys]];

	PajeEntityType *et;
	NSEnumerator *en;
	en = [[self containedTypesForContainerType:
		[self entityTypeForEntity: container]] objectEnumerator];
	while ((et = [en nextObject]) != nil) {
		if (![self isContainerEntityType: et]){
			/*1 - check is et is present in configuredEntityTypes */
			if ([auxSet containsObject: [et name]]){
				NSDictionary *config;
				config = [entityTypesChosen objectForKey:
							[et name]];
				ret += [self combinedValueFor: et
						inContainer: container
						andConfig: config];
			}
		}
	}
	return ret;
}

/*============================================================================*/
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
		andSize: (NSString *) size
		andSeparationRate: (NSString *) sep
                andGraphvizAlgorithm: (NSString *) algo;
{
	if (baseState != ResourcesGraph){
		[self disableVisualizationBase: baseState];
	}

	resourcesGraph = [[TrivaResourcesGraph alloc] initWithFile: file];
	[resourcesGraph setAlgorithm: algo];
	[resourcesGraph setSize: size];
	[resourcesGraph setSeparationRate: sep];

	baseState = ResourcesGraph;
	[self hierarchyChanged];
	return YES;
}

- (BOOL) applicationGraphWithSize: (NSString *) sizeStr andGraphvizAlgorithm: (NSString *) algo;
{
	if (baseState != ApplicationGraph){
		[self disableVisualizationBase: baseState];
	}

	if (applicationGraphPosition == nil){
		applicationGraphPosition = [Position positionWithAlgorithm:@"graphviz"];
	}
	[applicationGraphPosition setSubAlgorithm: algo];

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
		drawManager->resourcesGraphDelete();
	}else if (baseCode == ApplicationGraph){

	}else{
		//launch exception?
	}
}

//for resource graph
- (void) recalculateResourcesGraphWith: (id) entity 
{
	PajeEntityType *et;
	NSEnumerator *en = [[self containedTypesForContainerType:[self entityTypeForEntity: entity]] objectEnumerator];
	while ((et = [en nextObject]) != nil) {
		if ([self isContainerEntityType:et]) {
			PajeContainer *sub;
			NSEnumerator *en2 = [self enumeratorOfContainersTyped:et inContainer: entity];
			while ((sub = [en2 nextObject]) != nil) {
				NSString *n = [sub name];
				NSString *nf;
			
				if ([self mustDrawContainer: sub]){
					nf = [resourcesGraph searchWithPartialName:n];
					if (nf == nil){
						NSLog (@"Resource Graph Configuration\
						file is complete: it should have a \
						node named %@, according to the \
						provided application data.", nf);
					}else{
						[resourcesGraph incrementNumberOfContainersOf: nf];
					}
				}
				[self recalculateResourcesGraphWith: sub];
			}
		}
	}
}

- (void) recalculateResourcesGraphWithApplicationData
{
	id instance = [self rootInstance];
	[resourcesGraph resetNumberOfContainers];
	[self recalculateResourcesGraphWith: instance];
	[resourcesGraph refreshLayout];
}

- (NSString *) searchRGWithPartialName: (NSString *) partialName
{
	return [resourcesGraph searchWithPartialName: partialName];
}

- (NSPoint) nextLocationRGForNodeName: (NSString *) nodeName
{
	return [resourcesGraph nextLocationForNodeName: nodeName];
}

//for squarified treemap
- (TrivaTreemap *) searchWithPartialName: (NSString *) partialName
{
	if (baseState == SquarifiedTreemap){
		return [squarifiedTreemap searchWithPartialName: partialName];
	}else if (baseState == ResourcesGraph) {
		return [resourcesGraph searchWithPartialName: partialName];
	}else{
		return nil;
	}
}

- (void) recalculateSquarifiedTreemapsWith: (id) entity;
{
	TrivaTreemap *treemap = [self
		searchWithPartialName: [entity name]];
	if (treemap != nil){
		float ret;
		ret = [self calculateValueForContainer: entity];
		[treemap addValue: ret]; /* TODO: what if we have multiple
			cddontainers for the same treemap node */
		[treemap incrementNumberOfContainers];
	}

	PajeEntityType *et;
	NSEnumerator *en = [[self containedTypesForContainerType:[self entityTypeForEntity: entity]] objectEnumerator];
	while ((et = [en nextObject]) != nil) {
		if ([self isContainerEntityType:et]) {
			PajeContainer *sub;
			NSEnumerator *en2;
			en2 = [self enumeratorOfContainersTyped: et
						inContainer: entity];
			while ((sub = [en2 nextObject]) != nil) {
				[self recalculateSquarifiedTreemapsWith: sub];
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
	if (entity == nil){
		return nil;
	}

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
                        minDuration: 1/pointsPerSecond];
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

- (BOOL) mustDrawContainer: (id) container
{
	BOOL answer = NO;

	if (container == [self rootInstance]){
		return answer;
	}

	NSEnumerator *en = [[self containedTypesForContainerType:
		[self entityTypeForEntity: container]] objectEnumerator];

	PajeEntityType *et;
	while ((et = [en nextObject]) != nil) {
		if ([et isKindOfClass: [PajeLinkType class]]){
			answer = YES;
		}else if ([et isKindOfClass: [PajeStateType class]]){
			answer = YES;
		}
	}	
	return answer;
}
@end
