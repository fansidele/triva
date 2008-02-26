#include "OgreConfigure.h"

@implementation OgreConfigure
- (BOOL) setupResources
{
        NSString *resourcescfg = [[NSBundle mainBundle] pathForResource:
@"resources" ofType: @"cfg"];


        //Load resource paths from config file
        Ogre::ConfigFile cf;
        cf.load ([resourcescfg cString]);

        //Go through all settings in the file
        Ogre::ConfigFile::SectionIterator itSection = cf.getSectionIterator();
        Ogre::String sSection, sType, sArch;
        while( itSection.hasMoreElements() ) {
                sSection = itSection.peekNextKey();
                Ogre::ConfigFile::SettingsMultiMap *mapSettings = itSection.getNext();
                Ogre::ConfigFile::SettingsMultiMap::iterator itSetting = mapSettings->begin();
                while( itSetting != mapSettings->end() ) {
                        sType = itSetting->first;
                        sArch = itSetting->second;
                        Ogre::ResourceGroupManager::getSingleton().addResourceLocation(sArch, sType, sSection);
                        ++itSetting;
                }
        }
        return true;
}

- (id) init
{
	self = [super init];
	NSString *resourcescfg = [[NSBundle mainBundle] pathForResource: @"resources" ofType: @"cfg"];


	Ogre::Root *mRoot;
	mRoot = new Ogre::Root("plugins.cfg", "ogre.cfg", "Ogre.log");
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *currentPath = [fm currentDirectoryPath];
	NSArray *ar = [resourcescfg pathComponents];
	NSMutableArray *ar2 = [NSMutableArray arrayWithArray: ar];
	[ar2 removeLastObject];
	NSString *mediaPath = [NSString pathWithComponents: ar2];

	[fm changeCurrentDirectoryPath: mediaPath];
	[self setupResources];
	[fm changeCurrentDirectoryPath: currentPath];

	mRoot->setRenderSystem (mRoot->getRenderSystemByName ("OpenGL Rendering Subsystem"));
	mRoot->initialise(false);
	return self;
}

@end
