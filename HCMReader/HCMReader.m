/*
    This file is part of Triva.

    Triva is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Triva is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Triva.  If not, see <http://www.gnu.org/licenses/>.
*/
#import "HCMReader.h"

@implementation HCMReader

- (void) launchDIMVClientWithArgs: (NSDictionary *)args
{
  [integrator launchDIMVClientWithId: [args objectForKey:@"CLIENTID"]
    andAggregators: [args objectForKey:@"AGGREGATORS"]];
}

- (id) initWithController: (id) cont
{
//  NSDictionary *gangliaHCMConf;
  NSFileManager *fManager;
  NSString *callDir;
  
  self = [super initWithController: cont];
  buffer = [[NSMutableArray alloc] init];
  bufferLock =  [[NSConditionLock alloc] initWithCondition: 0];
  headerCenter = [[PajeHeaderCenter alloc] initWithDefaultHeader];
  integrator = [[IntegratorLib alloc] init];
  clientId = nil;
  aggregatorNames = nil;
  /*There's a bug in the bundlecenter wich cahnges the work directory.
   * So, we must save the curren directory in order to go back there
   * after configuring the bundle.*/
  fManager = [[NSFileManager defaultManager] retain];
  callDir = [[fManager currentDirectoryPath] retain];
/*
  [integrator loadDIMVisualBundle: @"dimvisual-ganglia-hcm.bundle"];
  gangliaHCMConf = [integrator 
    getConfigurationOptionsFromDIMVisualBundle:
    @"dimvisual-ganglia-hcm.bundle"];
  [integrator setConfiguration: gangliaHCMConf forDIMVisualBundle:
   @"dimvisual-ganglia-hcm.bundle"];
  [gangliaHCMConf autorelease];
*/
  [fManager changeCurrentDirectoryPath: callDir];
  NSString *fName = [[[NSHost currentHost] name] stringByAppendingString: @"-paje.output"];
  [fName retain];
  if([fManager createFileAtPath: fName contents: nil 
    attributes: nil] == NO){
    NSLog(@"ERROR: couldn't create the output file.");
    return nil;
  }
  [callDir release];
  [fManager release];
  outFile = [NSFileHandle fileHandleForWritingAtPath: fName];
  [fName release];
  
  return self;
}

- (BOOL)applyConfiguration: (NSDictionary *)conf
{
  NSArray *bundleNames;
  NSDictionary *bundleConfig;
  int i;
  
  [conf retain];
  
  clientId = [[conf objectForKey: @"id"] retain];
  aggregatorNames = [[conf objectForKey: @"aggregators"] retain];
  bundleNames = [conf objectForKey: @"bundles"];
  if(!(clientId && aggregatorNames && bundleNames)){
    NSLog(@"ERROR: The configuration file is incomplete.");
    return NO;
  }

  for (i = 0; i < [bundleNames count]; i++){
    [integrator loadDIMVisualBundle: @"dimvisual-ganglia-hcm.bundle"];
    bundleConfig = [conf objectForKey: [[bundleNames
     objectAtIndex: i] stringByAppendingString: @"_config"]];
    if(bundleConfig == nil){
      bundleConfig = [integrator 
        getConfigurationOptionsFromDIMVisualBundle:
        @"dimvisual-ganglia-hcm.bundle"];
      
    }
    [integrator setConfiguration: bundleConfig forDIMVisualBundle:
      @"dimvisual-ganglia-hcm.bundle"];
  }
  [conf release];
  return YES;
}

- (void) dealloc
{
  if(aggregatorNames){
    [aggregatorNames release];
  }
  if(clientId){
    [clientId release];
  }
  [headerCenter release];
  [integrator release];
  [buffer release];
  [bufferLock release];
  [super dealloc];
}

- (NSString *)traceDescription
{
  return @"HCMReader";
}

- (void) waitForDataFromHCM: (id) object
{
  NSData *data;
  int i;
  int long long chunkNumber = 0;
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  BOOL canEndChunkBeforeData = YES;
  while (1){ //wait for data forever
//    [NSThread sleepForTimeInterval: 2.4]; //sleep for 2.4 secs
//    NSLog (@"%s: lock", __FUNCTION__);
    [bufferLock lockWhenCondition: 1];
//    NSLog (@"%s: got (%d) data", __FUNCTION__, [buffer count]);
    for(i=0; i < [buffer count]; i++){
      data = [buffer objectAtIndex: i];
//       printf("%s:\n%s\n",
//        (canEndChunkBeforeData?"newChunk":"sameChunk"), 
//        (char *)[data bytes]);
//      [outFile writeData: data];
//      [outFile synchronizeFile];
      if(canEndChunkBeforeData == YES){
        canEndChunkBeforeData = NO;
        [super startChunk: chunkNumber++];
        [self outputEntity: data];
      }else if((canEndChunkBeforeData = 
        [self canEndChunkBefore: data])){
        [super endOfChunkLast: 0];
        [controller 
          setSelectionStartTime: [controller startTime]
          endTime: [controller endTime]];
      }
    }
    [buffer removeAllObjects];
    [bufferLock unlockWithCondition: 0]; 
  }
  [pool release];
}

- (BOOL) sendToPaje: (NSData *) data
{
  [data retain];
  [bufferLock lock]; //it doesnt matter the condition, we just produce
//  NSLog (@"%s: lock", __FUNCTION__);
  [buffer addObject: data];
//  NSLog (@"%s: data generated", __FUNCTION__);
  [bufferLock unlockWithCondition: 1];
  [data autorelease];
  return YES;
}

- (NSData *)eventsAsData
{
  NSMutableData *outData;
  NSMutableArray *events;
  LibPajeEvent *event;
  int i, code;

  outData = [[NSMutableData data] retain];
  events = [integrator convert];
  [events retain];
  for(i = 0; i < [events  count]; i++){
    event = [events objectAtIndex: i];
    if([headerCenter headerIsPresent: [event header]] == NO){
      [headerCenter addHeader: [event header]];
      code = [headerCenter codeForHeader: [event header]];
//      NSLog(@"%@", [headerCenter printHeaderWithCode: code]);
      [outData appendData: 
        [[headerCenter printHeaderWithCode: code]
        dataUsingEncoding: NSASCIIStringEncoding]];
    }
//  NSLog(@"%@", [event printWithProvider: headerCenter]);
  [outData appendData: [[event printWithProvider: headerCenter]
    dataUsingEncoding: NSASCIIStringEncoding]];
  }
  [outData autorelease];
  return outData;
}

- (void) producer: (id) args
{  
  NSData *data;
  NSDictionary *clientArgs;
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSLog(@"Will launch the DIMVClient now.");
  if(args == nil){
    clientArgs = [NSDictionary dictionaryWithObjectsAndKeys:
      clientId, @"CLIENTID",
      aggregatorNames, @"AGGREGATORS",
      nil];
  }else{
    clientArgs = args;
  
  }
  [clientArgs retain];
  [self launchDIMVClientWithArgs: clientArgs];
  [clientArgs autorelease];
  //Send the headers.
  NSLog(@"Sending the headers.");
//  NSLog(@"%@", [headerCenter print]);
  [self sendToPaje: [[headerCenter print] dataUsingEncoding: 
    NSASCIIStringEncoding]];
  NSLog(@"Beginning the main producer loop of the HCMReader.");
  while ((data = [[self eventsAsData] retain]) != nil){
//    [NSThread sleepForTimeInterval: 1.1]; //sleep for 1.1 secs
//    NSLog (@"%s", __FUNCTION__);
    [self sendToPaje: data];
    [data autorelease];
  }
  [pool release];
}

@end
