#include "DrawManager.h"
#include "draw/position/Position.h"
#include "draw/layout/Layout.h"

//static NSDictionary *pos;
static int mcount;

#include "draw/extras/Line3D.h"

void DrawManager::createTimestampedObjects ()
{
	id instance = [viewController rootInstance];
	this->drawTimestampedObjects (instance);
}

void DrawManager::drawTimestampedObjects (id entity)
{
	Ogre::SceneNode *n = mSceneMgr->getSceneNode ([[entity name] cString]);

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
				NSString *ide = [NSString stringWithFormat:
@"%@-#-#-%d", [[ent entityType] name], mcount++];
				Ogre::Entity *ste;
				std::string n;
				n = std::string ([ide cString]);
				try {
					ste = mSceneMgr->getEntity(n);
				}catch (Ogre::Exception ex){
					ste = mSceneMgr->createEntity (n,
						Ogre::SceneManager::PT_CUBE);
				}
				Ogre::ColourValue ogreColor = this->getRegisteredColor (std::string([[[ent entityType] name] cString]), [[ent name] cString]);
				this->createMaterial(std::string([[ent name]
cString]), ogreColor);

				ste->setMaterialName ([[ent name] cString]);
				ste->setQueryFlags(STATE_MASK);
				ssn->attachObject (ste);
				double start;
				double end;
				int imbric;

				start = [[[ent time] description] doubleValue];
				end = [[[ent endTime] description] doubleValue];
				imbric = [ent imbricationLevel];

				double kk = 0.3-(0.3/5*imbric);

				ssn->setPosition (0,(end-start)/2+start,0);
				ssn->setScale (kk,(end-start)/100,kk);
			}
		}else if ([et isKindOfClass: [PajeLinkType class]]){
			NSEnumerator *en4;
			PajeEntity *ent;
		
			en4 = [viewController enumeratorOfCompleteEntitiesTyped:et
					inContainer:entity
					fromTime:[viewController startTime]
					toTime:[viewController endTime]
					minDuration: 0];
			while ((ent = [en4 nextObject]) != nil) {
				Ogre::SceneNode *ssn;
				ssn = n->createChildSceneNode();
				NSString *ide = [NSString stringWithFormat: @"%@-%@-#-#-%d", [[ent sourceContainer] name], [[ent destContainer] name], mcount++];
				std::string n;
				n = std::string ([ide cString]);

				NSString *sn = [[ent sourceContainer] name];
				NSString *dn = [[ent destContainer] name];

				[position addLinkBetweenNode: sn andNode: dn];

			        Ogre::Vector3 op = mSceneMgr->getSceneNode ([sn
cString])->getWorldPosition();
				Ogre::Vector3 dp = mSceneMgr->getSceneNode ([dn
cString])->getWorldPosition();

				Ogre::Vector3 dif = dp - op;
				
				double start;
				double end;
				start = [[[ent time] description] doubleValue];
				end = [[[ent endTime] description] doubleValue];

/*
				try {
//					ste = mSceneMgr->getMovableObject(n);
				}catch (Ogre::Exception ex){
				}
				ste = new DynamicLines(Ogre::RenderOperation::OT_LINE_LIST);
*/
//				Ogre::ColourValue ogreColor = Ogre::ColourValue::White;
				Ogre::ColourValue ogreColor = this->getRegisteredColor (std::string([[[ent entityType] name] cString]), [[ent name] cString]);
				this->createMaterial(std::string([[ent name]
cString]), ogreColor);
/*
				ste->addPoint (op.x, start,op.z);
				ste->addPoint (dp.x, end, dp.z);
				ste->update();
*/
				Line3D *ste = new Line3D();
				ste->setQueryFlags (LINK_MASK);
				ste->setMaterial ([[ent name] cString]);
				ste->addPoint (Ogre::Vector3(op.x, start,op.z));
				ste->addPoint (Ogre::Vector3(dp.x, end, dp.z));
				ste->drawLines();
				ssn->attachObject (ste);
			}
		}
	}
}


void DrawManager::updateLinksPositions ()
{
        id instance = [viewController rootInstance];
}

