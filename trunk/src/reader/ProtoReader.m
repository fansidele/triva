#include "ProtoReader.h"

#define NUMBER_OF_REVENTS_READ_AT_ONCE 10

@implementation ProtoReader
- (id) initWithArgc: (int) argc andArgv: (char **) argv
{
	self = [super init];
	Command *command;

	command = [[Command alloc] initWithArgc: argc andArgv: argv];
	
	NSLog (@"command = %@", command);

	integrator = [[IntegratorLib alloc] initWithCommand: command];
	if (integrator == nil){
		return nil;
	}
	moreData = YES;	


/*
	BundleCenter *b = [[BundleCenter alloc] init];
	NSLog (@"### LOADBUNDLE => %d",[b loadBundleWithName: @"dimvisual-kaapi.bundle"]);

	dataSource = [[NSClassFromString (@"KAAPIDataSource") alloc] init];
	NSMutableDictionary *conf = [[NSMutableDictionary alloc] initWithDictionary: [dataSource configuration]];
	NSArray *files = [NSArray arrayWithObjects:
@"/home/schnorr/dev/tracage/fibo/cas3/tracefile.0.sorted",
@"/home/schnorr/dev/tracage/fibo/cas3/tracefile.1.sorted",
@"/home/schnorr/dev/tracage/fibo/cas3/tracefile.2.sorted",nil];
	NSString *sync = @"/home/schnorr/dev/tracage/fibo/cas3/timesync";
	NSString *machine = @"/home/schnorr/dev/tracage/fibo/cas3/machine";
	[[conf objectForKey: @"parameters"] setObject: files forKey: @"file"];
	[[conf objectForKey: @"parameters"] setObject: sync forKey: @"sync"];
	[[conf objectForKey: @"parameters"] setObject: machine forKey: @"machine"];

	NSLog (@"%@", conf);
	dataSource = [dataSource initWithConfiguration: conf provider: nil];
	if (dataSource == nil){
		NSLog (@"dataSource is nil");
		exit(1);
	}
*/
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
	[self output: chunk];
	[chunk release];
	if (moreData == NO){
		NSLog (@"%s End Of Data", __FUNCTION__);
		[self endOfData];
	}
	return;
}

- (BOOL) hasMoreData
{
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
@end
