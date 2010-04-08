#include "Marco.h"
#include "MarcoDraw.h"

MarcoDraw *draw = NULL;

@implementation Marco
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	MarcoWindow *window = new MarcoWindow ((wxWindow*)NULL);
	window->Show();
	draw = window->getDraw();
	draw->setController ((id)self);
	return self;
}

- (NSArray *) findLinksAt: (id) instance
{
	NSEnumerator *en;
	en = [[self containedTypesForContainerType:
		[self entityTypeForEntity: instance]] objectEnumerator];
	NSMutableArray *ret = [NSMutableArray array];
	id type;
	while ((type = [en nextObject]) != nil){
		if (![self isContainerEntityType: type] &&
			[[type name] isEqualToString: @"PS"]){
			[ret addObjectsFromArray:
			   [[self enumeratorOfEntitiesTyped: type
				inContainer: instance
				fromTime: [self startTime]
				toTime: [self endTime]
				minDuration: 0]
					allObjects]];
	        }else if (![self isContainerEntityType: type] &&
			[[type name] isEqualToString: @"BS"]){
			[ret addObjectsFromArray:
			   [[self enumeratorOfEntitiesTyped: type
				inContainer: instance
				fromTime: [self startTime]
				toTime: [self endTime]
				minDuration: 0]
					allObjects]];
	        }else if (![self isContainerEntityType: type] &&
			[[type name] isEqualToString: @"SS"]){
			[ret addObjectsFromArray:
			   [[self enumeratorOfEntitiesTyped: type
				inContainer: instance
				fromTime: [self startTime]
				toTime: [self endTime]
				minDuration: 0]
					allObjects]];
	        }
	}
	return ret;
}

- (NSArray *) findContainersAt: (id) instance
{
	NSEnumerator *en;
	en = [[self containedTypesForContainerType:
		[self entityTypeForEntity: instance]] objectEnumerator];
	NSMutableArray *ret = [NSMutableArray array];
	id type;
	while ((type = [en nextObject]) != nil){
		if ([self isContainerEntityType: type] &&
		     [[type name] isEqualToString: @"processor"]){
			[ret addObjectsFromArray:
			   [[self enumeratorOfContainersTyped: type
				inContainer:instance] allObjects]];
		}else if ([self isContainerEntityType: type] &&
		     [[type name] isEqualToString: @"switch"]){
			[ret addObjectsFromArray:
			   [[self enumeratorOfContainersTyped: type
				inContainer:instance] allObjects]];
		}else if ([self isContainerEntityType: type] &&
		     [[type name] isEqualToString: @"cacheL2"]){
			[ret addObjectsFromArray:
			   [[self enumeratorOfContainersTyped: type
				inContainer:instance] allObjects]];
	        }
	}
	return ret;
}

- (NSDictionary *) findCacheStates
{
   NSMutableDictionary *ret = [NSMutableDictionary dictionary];
   NSEnumerator *en;
   en = [[self findContainersAt: [self rootInstance]] objectEnumerator];
   id container;
   while ((container = [en nextObject])){
      if ([[[container entityType] name] isEqualToString: @"cacheL2"]){
	 NSEnumerator *en2;
	 en2 = [self
	    enumeratorOfEntitiesTyped:[self entityTypeWithName: @"address"]
                          inContainer:container
                             fromTime:[self selectionStartTime]
                               toTime:[self selectionEndTime]
                          minDuration:0.0];
	 NSArray *states = [en2 allObjects];
	 if (states && [states count] > 0){
	    [ret setObject: states forKey: container];
	 }
      }
   }
   return ret;
}

- (BOOL) checkForMarcoHierarchy
{
	id type;
	NSEnumerator *en;
	BOOL p, s, c, ps, bs, ss, bb;
	p = s = c = ps = bs = ss = bb = NO;
	en = [[self containedTypesForContainerType:
		[self entityTypeForEntity: [self rootInstance]]]
		  objectEnumerator];
	while ((type = [en nextObject]) != nil){
	    if ([[type name] isEqualToString: @"processor"]){
	       p = YES;
	    }else if ([[type name] isEqualToString: @"cacheL2"]){
	       c = YES;
	    }else if ([[type name] isEqualToString: @"switch"]){
	       s = YES;
	    }else if ([[type name] isEqualToString: @"PS"]){
	       ps = YES;
	    }else if ([[type name] isEqualToString: @"BS"]){
	       bs = YES;
	    }else if ([[type name] isEqualToString: @"SS"]){
	       ss = YES;
	    }else if ([[type name] isEqualToString: @"BB"]){
	       bb = YES;
	    }
	}
	return p | s | c | ps | bs | ss | bb;
}

- (void)printInstance:(id)instance level:(int)level
{

    NSLog(@"i%*.*s%@", level, level, "", [self descriptionForEntity:instance]);
    PajeEntityType *et;
    NSEnumerator *en;
    en = [[self containedTypesForContainerType:[self entityTypeForEntity:instance]] objectEnumerator];
    while ((et = [en nextObject]) != nil) {
        NSLog(@"t%*.*s%@", level+1, level+1, "", [self descriptionForEntityType:et]);
        if ([self isContainerEntityType:et]) {
            NSEnumerator *en2;
            PajeContainer *sub;
            en2 = [self enumeratorOfContainersTyped:et inContainer:instance];
            while ((sub = [en2 nextObject]) != nil) {
                [self printInstance:sub level:level+2];
            }
        } else {
            NSEnumerator *en3;
            PajeEntity *ent;
            en3 = [self enumeratorOfEntitiesTyped:et
                                      inContainer:instance
                                         fromTime:[self selectionStartTime]
                                           toTime:[self selectionEndTime]
                                      minDuration:0.0];
            while ((ent = [en3 nextObject]) != nil) {
                NSLog(@"e%*.*s%@", level+2, level+2, "", [self descriptionForEntity:ent]);
            }
        }
    }
}


- (void) dumpTraceInTextualFormat
{
    [self printInstance:[self rootInstance] level:0];
}

- (void) activateRecordingOfClass: (NSString *)classname
{
  Class *x = GSDebugAllocationClassList();
  int i = 0;
  while (1&&x[i]){
     if ([[x[i] description] isEqualToString: classname]){
	 GSDebugAllocationActiveRecordingObjects(x[i]);
     }
     i++;
  }
}

- (void) listRecordedObjectsOfClass: (NSString *) classname
{
  Class *x = GSDebugAllocationClassList();
  int i = 0;
  while (1&&x[i]){
     if ([[x[i] description] isEqualToString: classname]){
	 NSLog (@"%@ => %d (peak:%d)", x[i],
	 [[[GSDebugAllocationListRecordedObjects(x[i]) objectEnumerator]
	 allObjects] count],
	 GSDebugAllocationPeak(x[i]));
	 NSEnumerator *en= [GSDebugAllocationListRecordedObjects(x[i])
	 objectEnumerator];
	 id obj;
	 while ((obj = [en nextObject])){
	    NSLog (@"\t%@", obj);
	 }
     }
     i++;
  }
}

- (void) debug
{
  GSDebugAllocationActive(YES);
  Class *x = GSDebugAllocationClassList();
  int i = 0;
  while (1&&x[i]){
     NSLog (@"%@ - %d\n", x[i],
     GSDebugAllocationPeak(x[i]));
     i++;
  }
}

- (void) timeSelectionChanged
{
   NSLog (@"%@", [self findCacheStates]);
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//[self debug];
//[self activateRecordingOfClass: @"GSMutableArray"];
//[self activateRecordingOfClass: @"GSMutableDictionary"];
//[self activateRecordingOfClass: @"NSGDate"];
//[self activateRecordingOfClass: @"GSCInlineString"];
//[self activateRecordingOfClass: @"GSCSubString"];
//[self printInstance:[self rootInstance] level:0];
   NSLog (@"%@(%@) - %@(%@)", [self selectionStartTime], [self startTime],
   [self selectionEndTime], [self endTime]);
   static int flag = 1;
   if (flag){
     draw->recreateResourcesGraph();
     flag = 0;
   }
//   [self printInstance: [self rootInstance] level: 0];
   draw->Refresh();
//   NSLog (@"########### pool count = %d", [pool retainCount]);
//[self listRecordedObjectsOfClass: @"GSMutableArray"];
//[self listRecordedObjectsOfClass: @"GSCInlineString"];
//[self listRecordedObjectsOfClass: @"GSMutableDictionary"];
//[self listRecordedObjectsOfClass: @"NSGDate"];
//[self listRecordedObjectsOfClass: @"GSArrayEnumerator"];
// [self listRecordedObjectsOfClass: @"GSCSubString"];
   [pool release];
//   draw->
}
@end
