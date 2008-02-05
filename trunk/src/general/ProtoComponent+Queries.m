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
@end
