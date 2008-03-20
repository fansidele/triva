#include "DrawManager.h"

void DrawManager::createMaterial (std::string materialName, Ogre::ColourValue color)
{
	Ogre::MaterialManager *manager = Ogre::MaterialManager::getSingletonPtr();
	Ogre::MaterialPtr mat;
	mat = manager->getByName (materialName);
	if (mat.isNull()){
		mat = manager->create (materialName, "Triva");
//		Ogre::MaterialPtr bmat = manager->getByName ("VisuApp/RUNNING");
//		mat = bmat->clone (materialName, true, "Triva");

		Ogre::Technique *t = mat->getTechnique(0);

		//pass1
		Ogre::Pass *p = t->getPass(0);
		p->setSceneBlending (Ogre::SBT_TRANSPARENT_ALPHA);
		p->setDepthWriteEnabled (false);
		Ogre::TextureUnitState *tu = p->createTextureUnitState();
		tu->setColourOperationEx(Ogre::LBX_SOURCE1,Ogre::LBS_MANUAL,Ogre::LBS_CURRENT, color, color, 0);
		tu->setAlphaOperation(Ogre::LBX_SOURCE1,Ogre::LBS_MANUAL,Ogre::LBS_CURRENT, 0.5, 0.5, 0.5);

		//pass2 
		Ogre::Pass *p2 = t->createPass();
		p2->setPolygonMode(Ogre::PM_WIREFRAME);
		Ogre::TextureUnitState *tu2 = p2->createTextureUnitState();
		tu2->setColourOperationEx(Ogre::LBX_SOURCE1,Ogre::LBS_MANUAL,Ogre::LBS_CURRENT, color, color, 0);
		mat->load();
		mat->setDiffuse(color);
	}else{
		mat->reload();

	}
}

Ogre::ColourValue DrawManager::getMaterialColor (std::string materialName)
{
	Ogre::MaterialManager *manager =
Ogre::MaterialManager::getSingletonPtr();
	Ogre::MaterialPtr mat;
	mat = manager->getByName (materialName);
	if (!mat.isNull()){
		Ogre::ColourValue og =
mat->getTechnique(0)->getPass(0)->getDiffuse();
		return og;
	}else{
		//should never end here
		return Ogre::ColourValue::White;
	}
}

void DrawManager::setMaterialColor (std::string materialName, Ogre::ColourValue
og)
{
	Ogre::MaterialManager *manager =
Ogre::MaterialManager::getSingletonPtr();
	Ogre::MaterialPtr mat;
	mat = manager->getByName (materialName);
	og.a = 0.5;
	if (!mat.isNull()){
		mat->setDiffuse(og);
		mat->getTechnique(0)->getPass(0)->getTextureUnitState(0)->setColourOperationEx (Ogre::LBX_SOURCE1,Ogre::LBS_MANUAL,Ogre::LBS_CURRENT, og,og,0);
		mat->getTechnique(0)->getPass(0)->getTextureUnitState(0)->setAlphaOperation(Ogre::LBX_SOURCE1,Ogre::LBS_MANUAL,Ogre::LBS_CURRENT, 0.5, 0.5, 0.5);
		mat->getTechnique(0)->getPass(1)->getTextureUnitState(0)->setColourOperationEx (Ogre::LBX_SOURCE1,Ogre::LBS_MANUAL,Ogre::LBS_CURRENT, og, og, 0);
	}
}
