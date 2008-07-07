#include "DrawManager.h"
#include "draw/position/Position.h"
#include "draw/layout/Layout.h"

void DrawManager::resetCurrentVisualization ()
{
	Ogre::SceneNode *root = mSceneMgr->getRootSceneNode();
	try {
		currentVisuNode = root->createChildSceneNode("CurrentVisu");
	}catch(Ogre::Exception ex){
		//already exists, what to do?
		currentVisuNode = mSceneMgr->getSceneNode ("CurrentVisu");

		//remove everything
		currentVisuNode->removeAndDestroyAllChildren();
	}
}

Ogre::SceneNode *DrawManager::drawOneContainer (id cont, Ogre::SceneNode *node,
		float x, float y)
{
        std::string orname = std::string ([[cont name] cString]);
        std::string name = std::string(orname);
        name.append ("-#-#-");
        name.append ([[[cont entityType] name] cString]);

	/* creating or re-using the container scene node */
        Ogre::SceneNode *n;
        try {
                n = node->createChildSceneNode (orname);
        	n->setPosition (x, 0, y);
        }catch (Ogre::Exception ex){
                n = mSceneMgr->getSceneNode (orname);
                n->setPosition(x, 0, y);
                return n;
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
	try{	
                entnt = n->createChildSceneNode (textSceneNodeName);
                MovableText *text;
                NSString *textid;
                textid = [NSString stringWithFormat: @"%@-t", [cont name]];
                text = new MovableText ([textid cString], [textid cString]);
                text->setColor (Ogre::ColourValue::Blue);
                text->setCharacterHeight (15);
                entnt->setInheritScale (false);
                entnt->attachObject (text);
        }catch(Ogre::Exception ex){
                entnt = mSceneMgr->getSceneNode (textSceneNodeName);
        }
	return n;
}
