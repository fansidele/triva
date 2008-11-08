#include "DrawManager.h"
#include "draw/position/Position.h"
#include "draw/layout/Layout.h"

//extern double gettime();
//double t1, t2;
//t1 = gettime();
//t2 = gettime();
//NSLog (@"%f", t2-t1);

void DrawManager::createTimestampedObjects ()
{
	id instance = [viewController rootInstance];
	this->drawTimestampedObjects (instance);
}

void DrawManager::drawOneState (Ogre::SceneNode *visualContainer,
		id state)
{
	id container = [state container];
	id et = [state entityType];

	NSString *ide = [NSString stringWithFormat: @"%@-%@-%@-%@", 
		[state startTime], [state value], [et name], [container name]];
	NSString *idesn = [NSString stringWithFormat: @"%@-sn", ide];

	Ogre::SceneNode *ssn;
	try {
		ssn = mSceneMgr->getSceneNode ([idesn cString]);
	}catch (Ogre::Exception ex){
		ssn = visualContainer->createChildSceneNode([idesn cString]);
	}
		
	Ogre::Entity *ste;
	std::string name = std::string ([ide cString]);
	try {
		ste = mSceneMgr->getEntity(name);
	}catch (Ogre::Exception ex){
		ste = mSceneMgr->createEntity (name,
			Ogre::SceneManager::PT_CUBE);
		Ogre::ColourValue ogreColor;
		ogreColor = this->getRegisteredColor (
			std::string([[[state entityType] name] cString]),
			[[state name] cString]);
		this->createMaterial(std::string([[state name] cString]),
			ogreColor);

		ste->setMaterialName ([[state name] cString]);
		ste->setQueryFlags(STATE_MASK);

		ssn->attachObject (ste);
	}
	double start;
	double end;
	int imbric;

	start = [[[state startTime] description] doubleValue];
	start *= [viewController pointsPerSecond];
	end = [[[state endTime] description] doubleValue];
	end *= [viewController pointsPerSecond];
	imbric = [state imbricationLevel];

	double kk = 0.3-(0.3/5*imbric);

	ssn->setPosition (0,(end-start)/2+start,0);
	ssn->setScale (kk,(end-start)/100,kk);
}

void DrawManager::drawStates (PajeEntityType *et, id container)
{
	Ogre::SceneNode *n;
	n = mSceneMgr->getSceneNode ([[container name] cString]);
	NSEnumerator *en3;
	en3 = [viewController enumeratorOfEntitiesTyped: et
			inContainer: container
			fromTime:[viewController startTime]
			toTime:[viewController endTime]
			minDuration: 1/[viewController pointsPerSecond]];
	id ent;
	while ((ent = [en3 nextObject]) != nil) {
//		if ([[ent endTime] isEqualToDate: [viewController endTime]]){
			this->drawOneState (n, ent);
//		}
	}
}

void DrawManager::drawOneLink (id link)
{
	id container = [link container];
	id et = [link entityType];

	NSString *ide = [NSString stringWithFormat: @"%@-%@-%@-%@",
		[link startTime], [link value], [et name], [container name]];

	std::string name = std::string ([ide cString]);

	NSString *sn = [[link sourceContainer] name];
	NSString *dn = [[link destContainer] name];

//	[position addLinkBetweenNode: sn andNode: dn];

	Ogre::Vector3 op, dp;
#if OGRE_VERSION_MAJOR == 1 && OGRE_VERSION_MINOR == 6
	op = mSceneMgr->getSceneNode ([sn cString])->_getDerivedPosition();
	dp = mSceneMgr->getSceneNode ([dn cString])->_getDerivedPosition();
#else
	op = mSceneMgr->getSceneNode ([sn cString])->getWorldPosition();
	dp = mSceneMgr->getSceneNode ([dn cString])->getWorldPosition();
#endif

	Ogre::SceneNode *n = mSceneMgr->getRootSceneNode ();

	Ogre::Vector3 dif = dp - op;
	
	double start;
	double end;
	start = [[[link time] description] doubleValue];
	start *= [viewController pointsPerSecond];
	end = [[[link endTime] description] doubleValue];
	end *= [viewController pointsPerSecond];

	Ogre::ManualObject *ste;
	try {
		ste = mSceneMgr->getManualObject(name);
	}catch (Ogre::Exception ex){
		ste = mSceneMgr->createManualObject(name);
	}
	Ogre::ColourValue ogreColor;
	ogreColor = this->getRegisteredColor (
		std::string([[[link entityType] name] cString]),
		[[link name] cString]);
	this->createMaterial(std::string([[link name] cString]),
		ogreColor);

	ste->clear();
	ste->begin(std::string([[link name] cString]),
		Ogre::RenderOperation::OT_LINE_STRIP);
	ste->position (op.x, start, op.z);
	ste->position (dp.x, end, dp.z);
	ste->end();
	ste->setQueryFlags (LINK_MASK);

	NSString *idescenenode = [NSString stringWithFormat: @"%@-sn", ide];
	Ogre::SceneNode *dsn;
	try{
		dsn = mSceneMgr->getSceneNode ([idescenenode cString]);
	}catch (Ogre::Exception ex){
		dsn = n->createChildSceneNode([idescenenode cString]);
		dsn->attachObject (ste);
	}
}

void DrawManager::drawLinks (PajeEntityType *et, id container)
{
	NSEnumerator *en4;
	en4 = [viewController enumeratorOfCompleteEntitiesTyped: et
			inContainer: container
			fromTime:[viewController startTime]
			toTime:[viewController endTime]
			minDuration: 1/[viewController pointsPerSecond]];
	id ent;
	while ((ent = [en4 nextObject]) != nil) {
		this->drawOneLink (ent);
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

void DrawManager::updateLinksPositions ()
{
	this->createTimestampedObjects();
}
