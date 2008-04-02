#include "TrivaController.h"

extern wxString NSSTRINGtoWXSTRING (NSString *ns);
//Ogre::MovableObject *selectedObject = NULL;

void TrivaController::selectContainer (Ogre::MovableObject
*objectToSelect, Ogre::Vector3 hitAt)
{

}

void TrivaController::selectState (Ogre::MovableObject
*objectToSelect, Ogre::Vector3 hitAt)
{
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
	time = pos.y;
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

		DrawManager *m = [view drawManager];
		Ogre::ColourValue og = m->getMaterialColor (std::string([[fet name] cString]));
		wxColour c = this->convertOgreColor (og);
		colorButton->SetBackgroundColour (c);
		colorButton->SetLabel (NSSTRINGtoWXSTRING([fet name]));
		colorButton->Enable();
		selectedEntity = fet;
	}
}

void TrivaController::selectLink (Ogre::MovableObject
*objectToSelect, Ogre::Vector3 hitAt)
{
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

		DrawManager *m = [view drawManager];
		Ogre::ColourValue og = m->getMaterialColor (std::string([[fet name] cString]));
		wxColour c = this->convertOgreColor (og);
		colorButton->SetBackgroundColour (c);
		colorButton->SetLabel (NSSTRINGtoWXSTRING([fet name]));
		colorButton->Enable();
		selectedEntity = fet;
	}
}

void TrivaController::selectObjectIdentifier (Ogre::MovableObject
*objectToSelect, Ogre::Vector3 hitAt)
{
	if (objectToSelect->getQueryFlags() == CONTAINER_MASK){
		this->selectContainer (objectToSelect, hitAt);
	}else if (objectToSelect->getQueryFlags() == STATE_MASK){
		this->selectState (objectToSelect, hitAt);
	}else if (objectToSelect->getQueryFlags() == LINK_MASK){
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

void TrivaController::unselectObjectIdentifier (std::string name)
{
	statusBar->SetStatusText (wxString());
	colorButton->SetBackgroundColour (wxSystemSettings::GetColour( wxSYS_COLOUR_MENU ));
	colorButton->SetLabel(wxT("Color"));
	colorButton->Disable();
	selectedEntity = nil;
}
