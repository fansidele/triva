#include "ProtoView.h"

@implementation ProtoView
- (id)initWithController:(PajeTraceController *)c
{
        self = [super initWithController: c];
        if (self != nil){
		mRoot = Ogre::Root::getSingletonPtr ();
		NSLog (@"initializating drawManager");
		drawManager = new DrawManager (self);
        }
        return self;
}

//- (void) setColorWindow: (TrivaColorWindowEvents *) window
//{
//        mwin = window;
//	return;
//}


- (void) dealloc
{
        NSLog (@"%@ %s", self, __FUNCTION__);
//	[pajeOgreFilter release];
//	delete drawManager;
	[super dealloc];
}

- (void)dataChangedForEntityType:(PajeEntityType *)entityType
{
    NSLog(@"%@ root=%@", NSStringFromSelector(_cmd), [self nameForContainer:[self rootInstance]]);
}

- (void)limitsChangedForEntityType:(PajeEntityType *)entityType
{
    NSLog(@"%@ root=%@", NSStringFromSelector(_cmd), [self nameForContainer:[self rootInstance]]);
}

- (void)colorChangedForEntityType:(PajeEntityType *)entityType
{
    NSLog(@"%@ root=%@", NSStringFromSelector(_cmd), [self nameForContainer:[self rootInstance]]);
}

- (void)orderChangedForContainerType:(PajeEntityType *)containerType;
{
    NSLog(@"%@ root=%@", NSStringFromSelector(_cmd), [self nameForContainer:[self rootInstance]]);
}

- (void)timeSelectionChanged
{
    NSLog(@"%@ root=%@", NSStringFromSelector(_cmd), [self nameForContainer:[self rootInstance]]);
}

- (void)containerSelectionChanged
{
    NSLog(@"%@ root=%@", NSStringFromSelector(_cmd), [self nameForContainer:[self rootInstance]]);
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
                                         fromTime:[self startTime]
                                           toTime:[self endTime]
                                      minDuration:1/pointsPerSecond];
            while ((ent = [en3 nextObject]) != nil) {
                NSLog(@"e%*.*s%@", level+2, level+2, "", [self descriptionForEntity:ent]);
            }
        }
    }
}


- (void)printAll
{
    [self printInstance:[self rootInstance] level:0];
}


- (void)hierarchyChanged
{
	if (baseState == ApplicationGraph){
		[self recalculateApplicationGraphWithApplicationData];
		drawManager->applicationAnimatedGraphDraw
					(applicationGraphPosition, 0.4);
		drawManager->createTimestampedObjects ();
	}else if (baseState == SquarifiedTreemap){
		[self recalculateSquarifiedTreemapWithApplicationData];
		drawManager->squarifiedTreemapDraw (squarifiedTreemap);
		drawManager->drawContainersIntoTreemapBase ();
		drawManager->createTimestampedObjects ();
	}else if (baseState == ResourcesGraph){
		[self recalculateResourcesGraphWithApplicationData];
		drawManager->resourcesGraphDraw (resourcesGraph);
		drawManager->drawContainersIntoResourcesGraphBase ();
		drawManager->createTimestampedObjects ();
	}
	[self updateScrollbar];
}

- (void) timeLimitsChanged
{
	[self hierarchyChanged];
}

- (DrawManager *) drawManager
{
	return drawManager;
}

- (void) setPointsPerSecond: (double) nv
{
	pointsPerSecond = nv;
	NSLog (@"pointsPerSecond is %f", nv);
	[self hierarchyChanged];
}

- (double) pointsPerSecond
{
	return pointsPerSecond;
}

- (void) updateScrollbar
{
	//updating scroll bar
	float s, e;
	s = [[NSString stringWithFormat: @"%@", [self startTime]] floatValue];
	e = [[NSString stringWithFormat: @"%@", [self endTime]] floatValue];
	s = s * pointsPerSecond;
	e = e * pointsPerSecond;
	drawManager->trivaController->scrollbarUpdate (s, e);
}

- (NSDate *) startTime
{
	NSDate *ret;
	float s = drawManager->trivaController->windowStartTime ();
	if (s < 0){
		ret = [super startTime];
	}else{
		ret = [NSDate dateWithTimeIntervalSinceReferenceDate: s];
	}
	return ret;
}

- (NSDate *) endTime
{
	NSDate *ret;
	float s = drawManager->trivaController->windowEndTime ();
	if (s < 0){
		ret = [super endTime];
	}else{
		NSDate *d = [NSDate dateWithTimeIntervalSinceReferenceDate: s];
		ret = [d earlierDate: [super endTime]];
	}
	return ret;
}

- (Position *) getApplicationGraphPosition
{
        return applicationGraphPosition;
}

@end
