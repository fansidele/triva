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

	if ([root depth] == -1){
		//this node must have value = 0, sot it is not drawable
		//just return
		return;
	}

	Ogre::SceneNode *n1 = node->createChildSceneNode();
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
	n2->setScale (([root width]*.9)/100, .01, ([root height]*.9)/100);
	n2->setPosition (0, [root depth], 0);

	std::string orname = std::string ([[root name] cString]);
	std::string name = std::string (orname);
	name.append ("-#-#-");

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
                        this->treemapRecursiveDraw ((TrivaTreemap *)[children
objectAtIndex: i], n1);
                }
        }
}

void DrawManager::squarifiedTreemapDraw (TrivaTreemapSquarified *root)
{
	if (!currentVisuNode){
		this->resetCurrentVisualization();
	}
	this->treemapRecursiveDraw (root, currentVisuNode);
}
