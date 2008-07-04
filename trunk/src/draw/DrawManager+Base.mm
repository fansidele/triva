#include "DrawManager.h"
#include "TrivaTreemapSquarified.h"

extern wxString NSSTRINGtoWXSTRING (NSString *ns);

void DrawManager::treemapRecursiveDraw (TrivaTreemap *root, Ogre::SceneNode *node)
{
//        NSLog (@"%.0f name:%@ area (%.1f x %.1f) x=%.1f y=%.1f",
//		[root depth],
//                [root name], [root width], [root height], [root x], [root y]);

	if (root == nil || node == NULL){
		return;
	}

	if ([root value] <= 0){
		//no value, just return
		return;
	}

	std::string orname = std::string ([[root name] cString]);
	Ogre::SceneNode *n1 = node->createChildSceneNode(orname);
	n1->setPosition ([root x], 0, [root y]);
	Ogre::Entity *e;
	try {
		e = mSceneMgr->getEntity ([[root name] cString]);
	}catch (Ogre::Exception ex){
		e = mSceneMgr->createEntity ([[root name] cString],
				Ogre::SceneManager::PT_CUBE);
	}
	std::string materialname = "Triva/Treemap/";
	materialname.append ([[NSString stringWithFormat: @"%.0f", [root depth]] cString]);	

	e->setMaterialName (materialname);

	Ogre::SceneNode *n2 = n1->createChildSceneNode();
	n2->attachObject (e);
	n2->setInheritScale (false);
	n2->setScale (([root width])/100, .01, ([root height])/100);
	n2->setPosition (0, 0, 0);

//	MovableText *text;
//	text = new MovableText (name, name);
//	text->setColor (Ogre::ColourValue::Blue);
//	text->setCharacterHeight (15);
//	Ogre::SceneNode *textnode = node->createChildSceneNode();
//	textnode->setInheritScale (false);
//	textnode->setPosition ([root x], [root depth], [root y]);
//	textnode->attachObject(text);

        if ([root type] == nil){
                return;
        }
	NSArray *children = [root children];
        if (children != nil){
                unsigned int i;
                for (i = 0; i < [children count]; i++){
                        this->treemapRecursiveDraw ((TrivaTreemap *)[children objectAtIndex: i], n1);
                }
        }
}

void DrawManager::squarifiedTreemapDraw (TrivaTreemapSquarified *root)
{
	if (!currentVisuNode){
		this->resetCurrentVisualization();
	}
	if (baseSceneNode){
		baseSceneNode->removeAndDestroyAllChildren();
		mSceneMgr->destroySceneNode (baseSceneNode->getName());
		baseSceneNode = NULL;
	}
	baseSceneNode = currentVisuNode->createChildSceneNode();
	this->treemapRecursiveDraw (root, baseSceneNode);
}

void DrawManager::initializeBaseCategory ()
{
	baseSceneNode = NULL;
}

void DrawManager::applicationGraphRecursiveDraw (id entity,
			Position *position,
			Ogre::SceneNode *node)
{
	std::string orname = std::string ([[entity name] cString]);
	std::string name = std::string(orname);
	name.append ("-#-#-");
	name.append ([[[entity entityType] name] cString]);

	/* creating or re-using the container scene node */
	Ogre::SceneNode *n;
	try {
		n = node->createChildSceneNode(orname);
	} catch (Ogre::Exception ex){
		n = mSceneMgr->getSceneNode (orname);
	}

	/* creating or re-using the visual representation of the container */
	Ogre::Entity *e;
	try {
		e = mSceneMgr->getEntity(orname);
	}catch (Ogre::Exception ex){
		e = mSceneMgr->createEntity (orname, 
				Ogre::SceneManager::PT_CUBE);
	}
	e->setUserAny (Ogre::Any (name));
	e->setMaterialName ("VisuApp/Base");
	e->setQueryFlags(CONTAINER_MASK);

	/* creating or re-using the visual scene node of the container */
	std::string visualSceneNodeName = std::string (orname);
	visualSceneNodeName.append("visualRepresentation");
	Ogre::SceneNode *entn;
	try {
		entn = n->createChildSceneNode(visualSceneNodeName);
		entn->attachObject (e);
		entn->setScale (.3,.01,.3);
		entn->setInheritScale (false);
	}catch (Ogre::Exception ex){
		entn = mSceneMgr->getSceneNode (visualSceneNodeName);
	}

	/* creating or re-using the text scene node of the container */
	std::string textSceneNodeName = std::string (orname);
	textSceneNodeName.append("textRepresentation");
	Ogre::SceneNode *entnt;
	try {
		entnt = n->createChildSceneNode (textSceneNodeName);
		MovableText *text;
		NSString *textid;
		textid = [NSString stringWithFormat: @"%@-t", [entity name]];
		text = new MovableText ([textid cString], [textid cString]);
		text->setColor (Ogre::ColourValue::Blue);
		text->setCharacterHeight (15);
		entnt->setInheritScale (false);
		entnt->attachObject (text);
	}catch(Ogre::Exception ex){
		entnt = mSceneMgr->getSceneNode (textSceneNodeName);
	}

	/* finding its position */
	int x = [position positionXForNode: [entity name]];
	int y = [position positionYForNode: [entity name]];

	Ogre::Vector3 newPos;
	newPos = Ogre::Vector3 (Ogre::Real(x*2), 0, Ogre::Real(y*2));
	n->setPosition (newPos);

	NSEnumerator *en = [[viewController containedTypesForContainerType:[viewController entityTypeForEntity:entity]] objectEnumerator];
	PajeEntityType *et;
	while ((et = [en nextObject]) != nil) {
		if ([viewController isContainerEntityType:et]) {
			NSEnumerator *en2;
			PajeContainer *sub;
			en2 = [viewController enumeratorOfContainersTyped:et inContainer:entity];
			while ((sub = [en2 nextObject]) != nil) {
				this->applicationGraphRecursiveDraw((id)sub, 
					position, n);
			}
		}
	}
}

void DrawManager::applicationGraphDraw (Position *position)
{
	id instance = [viewController rootInstance];
	if (!currentVisuNode){
		this->resetCurrentVisualization();
	}
//	if (baseSceneNode){
//		baseSceneNode->removeAndDestroyAllChildren();
//		mSceneMgr->destroySceneNode (baseSceneNode->getName());
//		baseSceneNode = NULL;
//	}
//	baseSceneNode = currentVisuNode->createChildSceneNode();
	this->applicationGraphRecursiveDraw (instance, position, currentVisuNode);
}
