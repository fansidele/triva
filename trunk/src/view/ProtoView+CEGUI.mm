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
	NSDictionary *conf = [[super getConfigurationOptionsFromDIMVisualBundle: bundleName] objectForKey: @"parameters"];

	NSArray *keys = [conf allKeys];
	for (i = 0; i < [keys count]; i++){
		NSString *key = [keys objectAtIndex: i];
		id val = [conf objectForKey: key];
		std::string keyStr = [key cString];
		ceguiManager->addSubMenu (bundleNameStr, keyStr, val);
//		NSLog (@"key = %@, %@", [keys objectAtIndex: i], [conf objectForKey: [keys objectAtIndex: i]]);
	}

	[bundlesConfiguration setObject: [NSMutableDictionary dictionaryWithDictionary: conf] forKey: bundleName];

	//HACK (while CEGUI does not offer a easy way to create GUI
	NSMutableDictionary *thisBundleConf = [bundlesConfiguration objectForKey: bundleName];
	NSString *k = @"sync";
	[thisBundleConf setObject: [applicationController syncfile] forKey: k];
	
	std::string optionNameStr = [k cString];
	ceguiManager->setSubMenu (bundleNameStr, optionNameStr, (id)[applicationController syncfile]);

	k = @"files";	
	optionNameStr = [k cString];
	[thisBundleConf setObject: [applicationController tracefile] forKey: k];
	ceguiManager->setSubMenu (bundleNameStr, optionNameStr, (id)[applicationController tracefile]);
	//EOH
}

- (void) optionValue: (NSString *) bValue optionNamed: (NSString *) bOption ofBundle: (NSString *) bName
{
	NSLog (@"%@ %@ %@=%@", self, bName, bOption, bValue);

}
@end
