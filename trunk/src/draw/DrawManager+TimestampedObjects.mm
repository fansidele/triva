#include "DrawManager.h"
#include "draw/position/Position.h"
#include "draw/layout/Layout.h"

void DrawManager::createTimestampedObjects ()
{
	id instance = [viewController rootInstance];
	this->drawTimestampedObjects (instance);
}

void DrawManager::drawStates (PajeEntityType *et, id container)
{
	Ogre::SceneNode *n = mSceneMgr->getSceneNode ([[container name] cString]);
	NSEnumerator *en3;
	en3 = [viewController enumeratorOfEntitiesTyped: et
			inContainer: container
			fromTime:[viewController startTime]
			toTime:[viewController endTime]
			minDuration: 0];
	PajeEntity *ent;
	while ((ent = [en3 nextObject]) != nil) {
		Ogre::SceneNode *ssn;
		ssn = n->createChildSceneNode();
		NSString *ide = [NSString stringWithFormat: @"%@-#-#-%@-#-#-%@-#-#-%@", [ent description], [container name], [et name], [[container entityType] name]];
		Ogre::Entity *ste;
		std::string name = std::string ([ide cString]);
		try {
			ste = mSceneMgr->getEntity(name);
		}catch (Ogre::Exception ex){
			ste = mSceneMgr->createEntity (name,
				Ogre::SceneManager::PT_CUBE);
		}
		Ogre::ColourValue ogreColor = this->getRegisteredColor (std::string([[[ent entityType] name] cString]), [[ent name] cString]);
		this->createMaterial(std::string([[ent name] cString]), ogreColor);

		ste->setMaterialName ([[ent name] cString]);
		ste->setQueryFlags(STATE_MASK);
		try {
			ssn->attachObject (ste);
		} catch (Ogre::Exception ex){
//			std::cout <<
//				"Error: visual object " << 
//				ste->getName() << 
//				"already present in the visualization." <<
//				" Ignoring." <<
//				std::endl;
		}
		double start;
		double end;
		int imbric;

		start = [[[ent startTime] description] doubleValue];
		end = [[[ent endTime] description] doubleValue];
		imbric = [ent imbricationLevel];

		double kk = 0.3-(0.3/5*imbric);

		ssn->setPosition (0,(end-start)/2+start,0);
		ssn->setScale (kk,(end-start)/100,kk);
	}
}

void DrawManager::drawLinks (PajeEntityType *et, id container)
{
	Ogre::SceneNode *n = mSceneMgr->getSceneNode ([[container name] cString]);
	NSEnumerator *en4;
	en4 = [viewController enumeratorOfCompleteEntitiesTyped: et
			inContainer: container
			fromTime:[viewController startTime]
			toTime:[viewController endTime]
			minDuration: 0];
	PajeEntity *ent;
	while ((ent = [en4 nextObject]) != nil) {
		NSString *ide = [NSString stringWithFormat: @"%@-#-#-%@-#-#-%@-#-#-%@", [ent description], [container name], [et name], [[container entityType] name]];
		std::string name;
		name = std::string ([ide cString]);

		NSString *sn = [[ent sourceContainer] name];
		NSString *dn = [[ent destContainer] name];

		[position addLinkBetweenNode: sn andNode: dn];

	        Ogre::Vector3 op = mSceneMgr->getSceneNode ([sn cString])->getWorldPosition();
		Ogre::Vector3 dp = mSceneMgr->getSceneNode ([dn cString])->getWorldPosition();

		Ogre::Vector3 dif = dp - op;
		
		double start;
		double end;
		start = [[[ent time] description] doubleValue];
		end = [[[ent endTime] description] doubleValue];

		Ogre::ManualObject *ste;
		try {
			ste = mSceneMgr->getManualObject(name);
		}catch (Ogre::Exception ex){
			ste = mSceneMgr->createManualObject(name);
		}
		Ogre::ColourValue ogreColor = this->getRegisteredColor (std::string([[[ent entityType] name] cString]), [[ent name] cString]);
		this->createMaterial(std::string([[ent name] cString]), ogreColor);

		ste->clear();
		ste->begin(std::string([[ent name] cString]), Ogre::RenderOperation::OT_LINE_STRIP);
		ste->position (op.x, start, op.z);
		ste->position (dp.x, end, dp.z);
		ste->end();
		ste->setQueryFlags (LINK_MASK);
		Ogre::SceneNode *dsn = n->createChildSceneNode();
		try{
			dsn->attachObject (ste);
		}catch (Ogre::Exception ex){
		}
	}
}

void DrawManager::drawTimestampedObjects (id entity)
{
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
			this->drawStates (et, entity);
		}else if ([et isKindOfClass: [PajeLinkType class]]){
			this->drawLinks (et, entity);
		}
	}
}

void DrawManager::updateLinksPositions (PajeEntityType *et, id container)
{
	NSEnumerator *en4;
	en4 = [viewController enumeratorOfCompleteEntitiesTyped: et
			inContainer: container
			fromTime:[viewController startTime]
			toTime:[viewController endTime]
			minDuration: 0];
	PajeEntity *ent;
	while ((ent = [en4 nextObject]) != nil) {
		NSString *ide = [NSString stringWithFormat: @"%@-#-#-%@-#-#-%@-#-#-%@", [ent description], [container name], [et name], [[container entityType] name]];
		std::string name;
		name = std::string ([ide cString]);

		NSString *sn = [[ent sourceContainer] name];
		NSString *dn = [[ent destContainer] name];

	        Ogre::Vector3 op = mSceneMgr->getSceneNode ([sn cString])->getWorldPosition();
		Ogre::Vector3 dp = mSceneMgr->getSceneNode ([dn cString])->getWorldPosition();

		Ogre::Vector3 dif = dp - op;
		
		double start;
		double end;
		start = [[[ent time] description] doubleValue];
		end = [[[ent endTime] description] doubleValue];

		Ogre::ManualObject *ste;
		try {
			ste = mSceneMgr->getManualObject(name);
		}catch (Ogre::Exception ex){
			std::cout << "Link named " << name << " does not exists." << std::endl;
			return;
		}
		ste->clear();
		ste->begin(std::string([[ent name] cString]), Ogre::RenderOperation::OT_LINE_STRIP);
		ste->position (op.x, start, op.z);
		ste->position (dp.x, end, dp.z);
		ste->end();
	}
}

void DrawManager::updateLinksPositions (id entity)
{
	NSEnumerator *en = [[viewController containedTypesForContainerType:[viewController entityTypeForEntity:entity]] objectEnumerator];
	PajeEntityType *et;
	while ((et = [en nextObject]) != nil) {
		if ([viewController isContainerEntityType:et]) {
			NSEnumerator *en2;
			PajeContainer *sub;
			en2 = [viewController enumeratorOfContainersTyped:et
							inContainer:entity];
			while ((sub = [en2 nextObject]) != nil) {
				this->updateLinksPositions ((id)sub);
			}
		}else if ([et isKindOfClass: [PajeLinkType class]]){
			this->updateLinksPositions (et, entity);
		}
	}
}

void DrawManager::updateLinksPositions ()
{
	id instance = [viewController rootInstance];
	this->updateLinksPositions (instance);
}
