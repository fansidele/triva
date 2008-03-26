#include "TrivaController.h"

extern wxString NSSTRINGtoWXSTRING (NSString *ns);
Ogre::MovableObject *selectedObject = NULL;

void TrivaController::selectObjectIdentifier (Ogre::MovableObject
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
//	std::cout << str << std::endl;

	NSString *containerName = [[[NSString stringWithFormat: @"%s", str.c_str()] componentsSeparatedByString: @"-#-#-"] objectAtIndex: 0];
	NSString *entityTypeName = [[[NSString stringWithFormat: @"%s", str.c_str()] componentsSeparatedByString: @"-#-#-"] objectAtIndex: 1];

	PajeEntityType *entityType = [view entityTypeWithName: entityTypeName];
	PajeContainer *container = [view containerWithName: containerName
						type: entityType];
//	NSLog (@"entityType=%@ - container=%@", entityType, container);

	/* search for time of selected object */
	Ogre::Vector3 pos = objectToSelect->getParentSceneNode()->getPosition();
	double time;
	time = pos.y;
//	time = hitAt.y;
//	NSLog (@"hitAt.y=%f pos.y=%f", hitAt.y, pos.y);

	/* search for objectEntityType */
	NSString *objectEntityTypeName = [[[NSString stringWithFormat: @"%s", objectToSelect->getName().c_str()] componentsSeparatedByString: @"-#-#-"] objectAtIndex: 0];
	PajeEntityType *objectEntityType = [view entityTypeWithName: objectEntityTypeName];
//	NSLog (@"objectEntityTypeName=%@ - objectEntityType=%@ allEntitiesTypes=%@",objectEntityTypeName,objectEntityType,[view allEntityTypes]);

	/* obtaining objects */
	NSEnumerator *en = [view enumeratorOfEntitiesTyped: objectEntityType
		inContainer: container
		fromTime: [NSDate dateWithTimeIntervalSinceReferenceDate:time]
		toTime: [NSDate dateWithTimeIntervalSinceReferenceDate: time]
		minDuration: 0];
	PajeEntity *fet = [en nextObject];
	PajeEntity *et = fet;
//	NSLog (@"%@", et);
	while ((et = [en nextObject]) != nil){
//		NSLog (@"%@", et);
	}

	if (fet != nil){
		NSString *info = [NSString stringWithFormat: 
					@"%@ - %@ (%@:%@) %f",
					[container name],
					[fet name],
					[fet startTime],
					[fet endTime],
					[fet duration]];
		statusBar->SetStatusText (NSSTRINGtoWXSTRING(info));
		if (selectedObject != NULL){
			selectedObject->getParentSceneNode()->showBoundingBox(false);
		}
		selectedObject = objectToSelect;
		selectedObject->getParentSceneNode()->showBoundingBox(true);

//		colorWindow->setMaterialToBeChanged (NSSTRINGtoWXSTRING([fet name]));

		DrawManager *m = [view drawManager];
		Ogre::ColourValue og = m->getMaterialColor (std::string([[fet name] cString]));
		wxColour c = this->convertOgreColor (og);
		colorButton->SetBackgroundColour (c);
		colorButton->SetLabel (NSSTRINGtoWXSTRING([fet name]));
		colorButton->Enable();
		selectedEntity = fet;
	}
		
		

/*
	if (view){
		NSString *identifier;
		identifier = [NSString stringWithFormat: @"%s", name.c_str()];
		[view selectObjectIdentifier: identifier];
		XState *s = (XState *)[view objectWithIdentifier: identifier];
		NSMutableString *info = [NSMutableString string];
		[info appendString: [NSString stringWithFormat: @"%@ - %@,%@",
[s type], [s start], [s end]]];
		statusBar->SetStatusText (NSSTRINGtoWXSTRING(info));
	}
*/
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
	return Ogre::ColourValue((float)r/255, (float)g/255, (float)b/255, 0.5);//a/255);
}

void TrivaController::unselectObjectIdentifier (std::string name)
{
	statusBar->SetStatusText (wxString());
	if (selectedObject){
		selectedObject->getParentSceneNode()->showBoundingBox(false);
	}
	colorButton->SetBackgroundColour (wxSystemSettings::GetColour( wxSYS_COLOUR_MENU ));
	colorButton->SetLabel(wxT("Color"));
	colorButton->Disable();
	selectedEntity = nil;
/*
	if (view){
		[view unselectObjectIdentifier: [NSString stringWithFormat: @"%s",
name.c_str()]];
	}
*/
}
