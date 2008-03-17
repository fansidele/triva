#include "ProtoReader.h"

#define NUMBER_OF_REVENTS_READ_AT_ONCE 10

@implementation ProtoReader
- (id) init //WithArgc: (int) argc andArgv: (char **) argv
{
	self = [super init];
/*
	Command *command;

	command = [[Command alloc] initWithArgc: argc andArgv: argv];
	
	NSLog (@"command = %@", command);

	integrator = [[IntegratorLib alloc] initWithCommand: command];
	if (integrator == nil){
		return nil;
	}
*/
	integrator = [[IntegratorLib alloc] init];
	moreData = YES;	

	return self;
}

- (void) read
{
	NSMutableArray *chunk = [[NSMutableArray alloc] init];
	int i;
	for (i = 0; i < NUMBER_OF_REVENTS_READ_AT_ONCE; i++){
		NSMutableArray *a = [integrator convert];
		if (a != nil){
			[chunk addObjectsFromArray: a];
		}else{
			moreData = NO;
			break;
		}
	}
//	[self output: chunk];

	static int flag = 0;
	if (!flag){
		NSLog (@"%@", [headerCenter print]);
		flag = 1;
	}
	for (i = 0; i < [chunk count]; i++){
		LibPajeEvent *ev = [chunk objectAtIndex: i];
		if ([headerCenter headerIsPresent: [ev header]] == NO){
			[headerCenter addHeader: [ev header]];
			int code = [headerCenter codeForHeader: [ev header]];
			NSLog (@"%@", [headerCenter printHeaderWithCode: code]);
		}
		NSLog (@"%@", [ev printWithProvider: headerCenter]);
	}

	[chunk release];
	if (moreData == NO){
		NSLog (@"%s End Of Data", __FUNCTION__);
		[self endOfData];
	}
	return;
}

- (BOOL) hasMoreData
{
	NSLog (@"moreData = %d", moreData);
	return moreData;
/*
	if ([integrator time] == nil){
		return 0;
	}else{
		return 1;
	}
*/

}

/* ancient to be used with the datasource only of dimvisual
- (void) read
{
	int i, flag = 0;
	NSMutableArray *chunk = [[NSMutableArray alloc] init];
	NSMutableArray *single;

	if ([dataSource time] == nil){
		return;
	}

	for (i = 0; i < 50; i++){
		single = [dataSource convert];
		[single retain];
		if ([dataSource time] == nil){
			flag = 1;
			break;
		}else{
			[chunk addObjectsFromArray: single];
		}
		[single release];
	}
	[self output: chunk];
	[chunk release];
	return;
}

- (BOOL) hasMoreData
{
	if ([dataSource time] == nil){
		return 0;
	}else{
		return 1;
	}
}
*/

- (id) hierarchy
{
	return [integrator hierarchy];
}

- (NSArray *) dimvisualBundlesAvailable
{
	NSLog (@"%s", __FUNCTION__);
	return [integrator dimvisualBundlesAvailable];
}

- (BOOL) isDIMVisualBundleLoaded: (NSString *) name
{
	return [integrator isDIMVisualBundleLoaded: name];
}

- (BOOL) loadDIMVisualBundle: (NSString *) bundleName
{
	return [integrator loadDIMVisualBundle: bundleName];
}
- (NSDictionary *) getConfigurationOptionsFromDIMVisualBundle: (NSString *)name
{
	return [integrator getConfigurationOptionsFromDIMVisualBundle: name];
}

- (BOOL) setConfiguration: (NSDictionary *) conf forDIMVisualBundle: (NSString *) name
{
	BOOL ret = [integrator setConfiguration: conf forDIMVisualBundle: name];
	if (ret == YES){
		headerCenter = [integrator pajeHeaderCenter];	
		return YES;
	}else{
		return NO;
	}
}
@end
