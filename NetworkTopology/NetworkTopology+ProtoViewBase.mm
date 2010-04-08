#include "NetworkTopology.h"

@implementation NetworkTopology (ProtoViewBase)
- (BOOL) resourcesGraphWithFile: (NSString *) file
		andSize: (NSString *) size
		andSeparationRate: (NSString *) sep
                andGraphvizAlgorithm: (NSString *) algo;
{
	NSLog (@"%s", __FUNCTION__);

	resourcesGraph = [[TrivaResourcesGraph alloc] initWithFile: file];
	[resourcesGraph setAlgorithm: algo];
	[resourcesGraph setSize: size];
	[resourcesGraph setSeparationRate: sep];

	NSLog (@"\tCalling hierarchyChanged");
	[self hierarchyChanged];
	return YES;
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
					NSLog (@"%@ - %@", n, nf);
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
	NSLog (@"%s reset", __FUNCTION__);
	[resourcesGraph resetNumberOfContainers];
	NSLog (@"%s recalculate", __FUNCTION__);
	[self recalculateResourcesGraphWith: instance];
	NSLog (@"%s refresh", __FUNCTION__);
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
