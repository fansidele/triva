#include "ProtoView.h"

@implementation ProtoView (CEGUI)
- (void) loadBundles
{
	NSArray *b = [super dimvisualBundlesAvailable];
	if (b != nil){
		unsigned int i;
		for (i = 0; i < [b count]; i++){
			std::string strb = [[b objectAtIndex: i] cString];
			ceguiManager->addBundleMenu (strb);
		}
	}

	
}

- (void) loadBundleNamed: (NSString *) bundleName
{
	/* if it is already loaded, do nothing */
	//if ([super isDIMVisualBundleLoaded: bundleName]){
	//	return;
	//}

	std::string bundleNameStr = [bundleName cString];
	if (!ceguiManager->addMenuNamed (bundleNameStr)){
		return;
	}

	unsigned int i;
	NSDictionary *conf = [[super getConfigurationOptionsFromDIMVisualBundle:
bundleName] objectForKey: @"parameters"];
	NSArray *keys = [conf allKeys];
	for (i = 0; i < [keys count]; i++){
		NSString *key = [keys objectAtIndex: i];
		id val = [conf objectForKey: key];
		std::string keyStr = [key cString];
		ceguiManager->addSubMenu (bundleNameStr, keyStr, val);
//		NSLog (@"key = %@, %@", [keys objectAtIndex: i], [conf objectForKey: [keys objectAtIndex: i]]);
	}
}

- (void) optionValue: (NSString *) bValue optionNamed: (NSString *) bOption ofBundle: (NSString *) bName
{
	NSLog (@"%@ %@ %@=%@", self, bName, bOption, bValue);

}
@end
