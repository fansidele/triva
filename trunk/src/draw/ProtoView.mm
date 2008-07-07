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
                                      minDuration:0];
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
	drawManager->resetCurrentVisualization();
	if (baseState == ApplicationGraph){
		[self recalculateApplicationGraphWithApplicationData];
		drawManager->applicationGraphDraw (applicationGraphPosition);
		drawManager->createTimestampedObjects ();
	}else if (baseState == SquarifiedTreemap){
		[self recalculateSquarifiedTreemapWithApplicationData];
		drawManager->squarifiedTreemapDraw (squarifiedTreemap);
		drawManager->drawContainersIntoTreemapBase ();
		drawManager->createTimestampedObjects ();
	}
//	[self printAll];
}


/*
- (void) setFilter: (id) filter
{
	pajeOgreFilter = filter;
	[pajeOgreFilter retain];
}
*/

/*
- (void) input: (id) object
{
	//NSLog (@"%@", [object class]);
	NSString *str;
	 str = [NSString stringWithFormat: @"%s: TODO", __FUNCTION__];
	[[NSException exceptionWithName: @"ProtoView"
			reason: str userInfo: nil] raise];
}

- (void) timeLimitsChanged
{
	drawManager->movePointer();
	drawManager->createStatesDrawings ();
	drawManager->updateStatesDrawings ();
	drawManager->createLinksDrawings ();

	//cameraManager->newPositionForCamera (atof([[self endTime] cString]));

	//NSLog (@"%s %p %@", __FUNCTION__, drawManager, [self endTime]);
//	ProtoContainer *r = [self root];
//	NSLog (@"%@", [r identifier]);
}

- (void) hierarchyChanged
{
	drawManager->updateContainersPositions();
	drawManager->updateContainerDrawings();
	drawManager->updateLinksDrawings ();
}

- (void) connectionsChanged
{
	drawManager->updateContainersPositions();
}

- (XContainer *) root
{
	if (root == nil){
		root = [super root];
	}
	return root;
}

- (void) changePositionAlgorithm
{
	NSLog (@"%s", __FUNCTION__);
	drawManager->changePositionAlgorithm();
	drawManager->updateLinksDrawings ();
}

- (void) switchStatesLabels
{
	statesLabelsAppearance = !statesLabelsAppearance;
	if (statesLabelsAppearance){
		drawManager->showStatesLabels ();
	}else{
		drawManager->hideStatesLabels ();
	}
}

- (void) switchContainersLabels
{
	containersLabelsAppearance = !containersLabelsAppearance;
	if (containersLabelsAppearance){
		drawManager->showContainersLabels ();
	}else{
		drawManager->hideContainersLabels ();
	}
}

- (bool) statesLabelsAppearance
{
	return statesLabelsAppearance;
}

- (bool) containersLabelsAppearance
{
	return containersLabelsAppearance;
}
*/

- (DrawManager *) drawManager
{
	return drawManager;
}
@end
