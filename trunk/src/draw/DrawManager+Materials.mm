#include "DrawManager.h"

void DrawManager::createMaterial (std::string materialName, Ogre::ColourValue color)
{
	Ogre::MaterialManager *manager = Ogre::MaterialManager::getSingletonPtr();
	Ogre::MaterialPtr mat;
	mat = manager->getByName (materialName);
	if (mat.isNull()){
		std::cout << "material: " << materialName << " nao existe" << std::endl;
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
		std::cout << "cor = " << color << std::endl;
	}else{
//		std::cout << "material: " << materialName << " EXISTE" << std::endl;
		mat->reload();

	}
//	std::cout << mat << std::endl;
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
		std::cout << "cor eh " << og << std::endl;
		return og;
	}else{
		return Ogre::ColourValue::White;
	}
}

void DrawManager::setMaterialColor (std::string materialName, Ogre::ColourValue
og)
{
	std::cout << __FUNCTION__ << " cor = " << og << std::endl;
	Ogre::MaterialManager *manager =
Ogre::MaterialManager::getSingletonPtr();
	Ogre::MaterialPtr mat;
	mat = manager->getByName (materialName);
	if (!mat.isNull()){
		mat->getTechnique(0)->getPass(0)->getTextureUnitState(0)->setColourOperationEx (Ogre::LBX_SOURCE1,Ogre::LBS_MANUAL,Ogre::LBS_CURRENT, og,og,0);
		mat->getTechnique(0)->getPass(0)->getTextureUnitState(0)->setAlphaOperation(Ogre::LBX_SOURCE1,Ogre::LBS_MANUAL,Ogre::LBS_CURRENT, 0.5, 0.5, 0.5);
		mat->getTechnique(0)->getPass(1)->getTextureUnitState(0)->setColourOperationEx (Ogre::LBX_SOURCE1,Ogre::LBS_MANUAL,Ogre::LBS_CURRENT, og, og, 0);
//		mat->reload();
		std::cout << "material " << materialName << " reload" << std::endl;
	}
}
