#include "ProtoComponent.h"

@implementation ProtoComponent (Queries)
- (BOOL) hasMoreData
{
	if (input != nil){
		return [input hasMoreData];
	}else{
		return 0;
	}
}

/*
- (ProtoObject *) nextObject;
{	
	if (input != nil){
		return [input nextObject];
	}else{
		return nil;
	}
}
*/

- (XContainer *) root
{
	if (input != nil){
		return [input root];
	}else{
		return nil;
	}
}

- (NSString *) startTime
{
	return [input startTime];
}

- (NSString *) endTime
{
	return [input endTime];
}

- (id) hierarchy
{
	return [input hierarchy];
}

- (NSDictionary *) newLinksBetweenContainers
{
	return [input newLinksBetweenContainers];
}

	
- (NSDictionary *) hierarchyOrganization
{
	return [input hierarchyOrganization];
}

- (XObject *) objectWithIdentifier: (NSString *) identifier
{
	return [input objectWithIdentifier: identifier];
}

- (NSArray *) dimvisualBundlesAvailable
{
	NSLog (@"%s %@ input=%@", __FUNCTION__,self,input);
	return [input dimvisualBundlesAvailable];
}

- (BOOL) isDIMVisualBundleLoaded: (NSString *) name
{
	return [input isDIMVisualBundleLoaded: name];
}

- (NSDictionary *) getConfigurationOptionsFromDIMVisualBundle: (NSString *)name
{
	return [input getConfigurationOptionsFromDIMVisualBundle: name];
}

- (BOOL) setConfiguration: (NSDictionary *) conf forDIMVisualBundle: (NSString *) name
{
	return [input setConfiguration: conf forDIMVisualBundle: name];
}
@end
