#include "DrawManager.h"
#include "draw/position/Position.h"
#include "draw/layout/Layout.h"

//static NSDictionary *pos;
static int count;

void DrawManager::createTimestampedObjects ()
{
	id instance = [viewController rootInstance];
	this->drawTimestampedObjects (instance);
}

void DrawManager::drawTimestampedObjects (id entity)
{
	Ogre::SceneNode *n = mSceneMgr->getSceneNode ([[entity name] cString]);
	NSLog (@"entity name = %@ %d", [entity name], n->getInheritScale());



	NSEnumerator *en = [[viewController containedTypesForContainerType:[viewController entityTypeForEntity:entity]] objectEnumerator];
	PajeEntityType *et;
	while ((et = [en nextObject]) != nil) {
		if ([viewController isContainerEntityType:et]) {
			NSEnumerator *en2;
			PajeContainer *sub;
			en2 = [viewController enumeratorOfContainersTyped:et
							inContainer:entity];
			while ((sub = [en2 nextObject]) != nil) {
				this->drawTimestampedObjects ((id)sub);
			}
		}else if ([et isKindOfClass: [PajeStateType class]]){
			NSEnumerator *en3;
			PajeEntity *ent;
		
			en3 = [viewController enumeratorOfEntitiesTyped:et
					inContainer:entity
					fromTime:[viewController startTime]
					toTime:[viewController endTime]
					minDuration: 0];
			while ((ent = [en3 nextObject]) != nil) {
				Ogre::SceneNode *ssn;
				ssn = n->createChildSceneNode();
				NSString *ide = [NSString stringWithFormat: @"%@-#-#-%d", [[ent entityType] name], count++];
				Ogre::Entity *ste = mSceneMgr->createEntity ([ide cString], Ogre::SceneManager::PT_CUBE);
				NSLog (@"%@", [ent name]);

//				[viewController createMaterialNamed: [ent name]];

//				ste->setMaterialName ([[ent name] cString]);
				ste->setMaterialName ("VisuApp/RUNNING");
				ste->setQueryFlags(STATE_MASK);
				ssn->attachObject (ste);
				double start;
				double end;

				start = [[[ent time] description] doubleValue];
				end = [[[ent endTime] description] doubleValue];

				ssn->setPosition (0,(end-start)/2+start,0);
				ssn->setScale (0.3,(end-start)/100,0.3);
				
//				NSLog (@"State name=%@ starttime=%f endtime=%f", [ent name], [[[ent time] description] doubleValue], [[[ent endTime] description] doubleValue]);
//				[st redraw];
//				[ret addState:st];
			}
		}
	}
}

