#include "TrivaController.h"

extern wxString NSSTRINGtoWXSTRING (NSString *ns);
//Ogre::MovableObject *selectedObject = NULL;

void TrivaController::selectContainer (Ogre::MovableObject *objectToSelect)
{
	return;

	Ogre::Root *mRoot;
	Ogre::SceneManager *mSceneMgr;

	mRoot = Ogre::Root::getSingletonPtr();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");

	/* search for container */
	Ogre::Entity *containerEntity = mSceneMgr->getEntity (objectToSelect->getParentSceneNode()->getParentSceneNode()->getName());
	Ogre::Any any = containerEntity->getUserAny();
	std::string str;
	str = Ogre::any_cast<std::string>(containerEntity->getUserAny());

	NSString *containerName = [[[NSString stringWithFormat: @"%s", str.c_str()] componentsSeparatedByString: @"-#-#-"] objectAtIndex: 0];
	NSString *entityTypeName = [[[NSString stringWithFormat: @"%s", str.c_str()] componentsSeparatedByString: @"-#-#-"] objectAtIndex: 1];

	PajeEntityType *entityType = [view entityTypeWithName: entityTypeName];
	PajeContainer *container = [view containerWithName: containerName
						type: entityType];
	NSLog (@"entityType=%@ container=%@", entityType, container);
	objectToSelect->getParentSceneNode()->showBoundingBox(true);
	containersSelected.push_back (objectToSelect);

	NSMutableSet *containers;
	containers = [[view selectedContainers] mutableCopy];
	[containers addObject: container];
	[view setSelectedContainers:containers];
	[containers release];

	if (containersSelected.size() >= 2){
		mergeButton->Enable(true);
	}
}

void TrivaController::selectState (Ogre::MovableObject
				*objectToSelect, Ogre::Vector3 hitAt, float distanceFactor, float rayOfAction, float animTime)
{
	Ogre::SceneNode *scnode;
	scnode = objectToSelect->getParentSceneNode();
	std::vector<Ogre::SceneNode*> *vectSceneNodes;
	vectSceneNodes = new std::vector<Ogre::SceneNode*>;

	DrawManager *varDrawManager = [view drawManager];
	Position *varApplicationGraphPosition = [view getApplicationGraphPosition];

	varDrawManager->fillVectorSceneNodes(varApplicationGraphPosition, vectSceneNodes);

	std::string nameSelectedObj;
	nameSelectedObj = objectToSelect->getName();
	nameSelectedObj.erase(0,22);
	if (nameSelectedObj[0] == '-')
	{
           nameSelectedObj.erase(0,1);
	}

	Ogre::SceneNode *selectedScNode;
	for(int i=0; i < vectSceneNodes->size(); i++)
	{
		if  ( vectSceneNodes->at(i)->getName() == nameSelectedObj)	
		   {
			selectedScNode = vectSceneNodes->at(i);
			break;	
		   }
	}
 
//	float fatorDeDistanciamento = 1.5, varRaioDeAcao = 400.0;

	std::vector<Ogre::SceneNode*> vectSceneNodes2;

        for(int i=0; i < vectSceneNodes->size(); i++)
        {
		vectSceneNodes2.push_back(vectSceneNodes->at(i));
        }

	std::vector<Ogre::Vector3> vectNewPositions;
//	vectNewPositions = varDrawManager->calcNewPositions(vectSceneNodes2, selectedScNode, fatorDeDistanciamento, varRaioDeAcao);
        vectNewPositions = varDrawManager->calcNewPositions(vectSceneNodes2, selectedScNode, distanceFactor, rayOfAction);

	std::vector<Ogre::Vector3> *vectNewPositionsPt = new std::vector<Ogre::Vector3>;
	Ogre::Vector3  position;

	for(int i=0; i < vectNewPositions.size(); i++)
        {
		position = vectNewPositions.at(i);
                vectNewPositionsPt->push_back(position);

        }

	varDrawManager->moveSceneNodesToNewPositions(vectSceneNodes, vectNewPositionsPt, animTime); 
 
	delete vectNewPositionsPt;
#if 0

	Ogre::Root *mRoot;
	Ogre::SceneManager *mSceneMgr;

	mRoot = Ogre::Root::getSingletonPtr();
	mSceneMgr = mRoot->getSceneManager("VisuSceneManager");

	/* search for container */
	Ogre::Entity *containerEntity = mSceneMgr->getEntity (objectToSelect->getParentSceneNode()->getParentSceneNode()->getName());
	Ogre::Any any = containerEntity->getUserAny();
	std::string str;
	str = Ogre::any_cast<std::string>(containerEntity->getUserAny());

	NSString *containerName = [[[NSString stringWithFormat: @"%s", str.c_str()] componentsSeparatedByString: @"-#-#-"] objectAtIndex: 0];
	NSString *entityTypeName = [[[NSString stringWithFormat: @"%s", str.c_str()] componentsSeparatedByString: @"-#-#-"] objectAtIndex: 1];

	PajeEntityType *entityType = [view entityTypeWithName: entityTypeName];
	PajeContainer *container = [view containerWithName: containerName
						type: entityType];

	/* search for time of selected object */
	Ogre::Vector3 pos = objectToSelect->getParentSceneNode()->getPosition();
	double time;
	time = pos.y / [view pointsPerSecond];
//	time = hitAt.y;

	/* search for objectEntityType */
	NSString *objectEntityTypeName = [[[NSString stringWithFormat: @"%s", objectToSelect->getName().c_str()] componentsSeparatedByString: @"-#-#-"] objectAtIndex: 2];
	PajeEntityType *objectEntityType = [view entityTypeWithName: objectEntityTypeName];

	/* obtaining objects */
	NSEnumerator *en = [view enumeratorOfEntitiesTyped: objectEntityType
		inContainer: container
		fromTime: [NSDate dateWithTimeIntervalSinceReferenceDate:time]
		toTime: [NSDate dateWithTimeIntervalSinceReferenceDate: time]
		minDuration: 0];
	PajeEntity *fet = [en nextObject];

	if (fet != nil){
		NSString *info = [NSString stringWithFormat: 
					@"%@ - %@ (%@:%@) %f",
					[container name],
					[fet name],
					[fet startTime],
					[fet endTime],
					[fet duration]];
		statusBar->SetStatusText (NSSTRINGtoWXSTRING(info));
		objectToSelect->getParentSceneNode()->showBoundingBox(true);
		selectedObject = objectToSelect;

		DrawManager *m = [view drawManager];
		Ogre::ColourValue og = m->getMaterialColor (std::string([[fet name] cString]));
		wxColour c = this->convertOgreColor (og);
		colorButton->SetBackgroundColour (c);
		colorButton->SetLabel (NSSTRINGtoWXSTRING([fet name]));
		colorButton->Enable();
		selectedEntity = fet;
	}
		//return;
#endif
}

void TrivaController::selectLink (Ogre::MovableObject
*objectToSelect, Ogre::Vector3 hitAt)
{
	return;

        Ogre::Root *mRoot;
        Ogre::SceneManager *mSceneMgr;

        mRoot = Ogre::Root::getSingletonPtr();
        mSceneMgr = mRoot->getSceneManager("VisuSceneManager");

        /* search for container */
        std::string str = objectToSelect->getName();
        NSString *containerName = [[[NSString stringWithFormat: @"%s", str.c_str()] componentsSeparatedByString: @"-#-#-"] objectAtIndex: 1];
        NSString *entityTypeName = [[[NSString stringWithFormat: @"%s", str.c_str()] componentsSeparatedByString: @"-#-#-"] objectAtIndex: 3];
        PajeEntityType *entityType = [view entityTypeWithName: entityTypeName];
        PajeContainer *container = [view containerWithName: containerName
                                                type: entityType];

        /* search for time of selected object */
	double time = (double)hitAt.y/yScale;

        /* search for objectEntityType */
        NSString *objectEntityTypeName = [[[NSString stringWithFormat: @"%s", objectToSelect->getName().c_str()] componentsSeparatedByString: @"-#-#-"] objectAtIndex: 2];
        PajeEntityType *objectEntityType = [view entityTypeWithName: objectEntityTypeName];

        /* obtaining objects */
        NSEnumerator *en = [view enumeratorOfEntitiesTyped: objectEntityType
                inContainer: container
                fromTime: [NSDate dateWithTimeIntervalSinceReferenceDate:time]
                toTime: [NSDate dateWithTimeIntervalSinceReferenceDate: time]
                minDuration: 0];
        PajeEntity *fet = [en nextObject];

	if (fet != nil){
		NSString *info = [NSString stringWithFormat: 
					@"%@ - %@ (%@:%@) %f",
					[container name],
					[fet name],
					[fet startTime],
					[fet endTime],
					[fet duration]];
		statusBar->SetStatusText (NSSTRINGtoWXSTRING(info));
		objectToSelect->getParentSceneNode()->showBoundingBox(true);
		selectedObject = objectToSelect;

		DrawManager *m = [view drawManager];
		Ogre::ColourValue og = m->getMaterialColor (std::string([[fet name] cString]));
		wxColour c = this->convertOgreColor (og);
		colorButton->SetBackgroundColour (c);
		colorButton->SetLabel (NSSTRINGtoWXSTRING([fet name]));
		colorButton->Enable();
		selectedEntity = fet;
	}
}

void TrivaController::unselectSelected ()
{
	if (selectedObject != NULL){
		selectedObject->getParentSceneNode()->showBoundingBox(false);
		selectedObject = NULL;
		statusBar->SetStatusText (wxString());
		colorButton->SetBackgroundColour (wxSystemSettings::GetColour( wxSYS_COLOUR_MENU ));
		colorButton->SetLabel(wxT("Color"));
		colorButton->Disable();
		selectedEntity = nil;
	}

	if (!containersSelected.empty()){
		std::vector<Ogre::MovableObject*>::iterator it;
		for (it=containersSelected.begin(); it!=containersSelected.end(); it++){
			(*it)->getParentSceneNode()->showBoundingBox(false);
		}
		containersSelected.clear();

		NSMutableSet *containers = [[NSMutableSet alloc] init];
		[view setSelectedContainers: containers];
		[containers release];

		mergeButton->Enable(false);
	}
}

void TrivaController::selectObjectIdentifier (Ogre::MovableObject
*objectToSelect, Ogre::Vector3 hitAt)
{
	if (objectToSelect == NULL){
		this->unselectSelected ();
		return;
	}

	if (objectToSelect->getQueryFlags() == CONTAINER_MASK){
		this->selectContainer (objectToSelect);
	}else if (objectToSelect->getQueryFlags() == STATE_MASK){
		this->unselectSelected ();
		this->selectState (objectToSelect, hitAt, 1.5, 400.0, 1.0);
	}else if (objectToSelect->getQueryFlags() == LINK_MASK){
		this->unselectSelected ();
		this->selectLink (objectToSelect, hitAt);
	}
}

wxColour TrivaController::convertOgreColor (Ogre::ColourValue og)
{
	wxColour c;
	unsigned char r, g, b, a;
	r = (unsigned char)(og.r * 255);
	g = (unsigned char)(og.g * 255);
	b = (unsigned char)(og.b * 255);
	a = (unsigned char)(og.a * 255);
	c.Set (r, g, b, a);
	return c;
}

Ogre::ColourValue TrivaController::convertWxColor (wxColor c)
{
	unsigned char r, g, b, a;
	r = c.Red();
	g = c.Green();
	b = c.Blue();
	a = c.Alpha();
	return Ogre::ColourValue((float)r/255, (float)g/255, (float)b/255, 0.5);
}
