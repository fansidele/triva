#include "ProtoView.h"

#ifndef TRIVAWXWIDGETS

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
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary: [[super getConfigurationOptionsFromDIMVisualBundle:
bundleName] objectForKey: @"parameters"]];


	NSArray *keys = [parameters allKeys];
	for (i = 0; i < [keys count]; i++){
		NSString *key = [keys objectAtIndex: i];
		id val = [parameters objectForKey: key];
		std::string keyStr = [key cString];
		ceguiManager->addSubMenu (bundleNameStr, keyStr, val);
	}

	//HACK 
	NSString *k = @"sync";
	[parameters setObject: [applicationController syncfile] forKey: k];
	std::string optionNameStr = [k cString];
	ceguiManager->setSubMenu (bundleNameStr, optionNameStr,
(id)[applicationController syncfile]);

	k = @"files";
	optionNameStr = [k cString];
	[parameters setObject: [applicationController tracefile] forKey: k];
	ceguiManager->setSubMenu (bundleNameStr, optionNameStr, (id)[applicationController tracefile]);
	//EOH

	NSMutableDictionary *conf = [NSMutableDictionary dictionaryWithDictionary: [super getConfigurationOptionsFromDIMVisualBundle: bundleName]];
	[conf setObject: parameters forKey: @"parameters"];

	[bundlesConfiguration setObject: conf forKey: bundleName];

	[self setConfiguration: conf forDIMVisualBundle: bundleName];
	[self setState: Configured];
}

- (void) optionValue: (NSString *) bValue optionNamed: (NSString *) bOption ofBundle: (NSString *) bName
{
	NSLog (@"%@ %@ %@=%@", self, bName, bOption, bValue);

}
@end

#endif
