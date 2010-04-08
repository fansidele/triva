#include "NetworkTopology.h"
#include "NetworkTopologyWindow.h"
#include <Ogre.h>

@implementation NetworkTopology
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	/* init ogre */
	if (![self configureOgre]){
		NSLog (@"%@: Ogre cannot be configured.", self);
		return nil;
	}

	/* configure zoom */
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        NSString *v = [d stringForKey:@"pointsPerSecond"];
        double nv;
        if (v != nil){
                nv = [v doubleValue];
        }else{
                nv = 1.0;
        }
	pointsPerSecond = nv;

	/* open window */
	NetworkTopologyWindow *window;
	window = new NetworkTopologyWindow ((wxWindow*)NULL);
	[self initializeResources];
	window->Show();
	window->setController ((id)self);
	window->configureZoom (nv);

	[self resourcesGraphWithFile:
		[c getParameterNumber: 1]
	        andSize: @"100"
	        andSeparationRate: @"1"
	        andGraphvizAlgorithm: @"fdp"];

	/* configure myself */
	drawManager = new DrawManager (self);

	return self;
}

- (BOOL) setupResources
{
	NSBundle *bundle = [NSBundle bundleForClass: [NetworkTopology class]];
        NSString *resourcescfg = [bundle pathForResource: @"resources"
						  ofType: @"cfg"];
	if (resourcescfg == nil){
		return NO;
	}

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
	NSLog (@"%@: %s ok", self, __FUNCTION__);
        return YES;
}

- (BOOL) configureOgre
{
	NSBundle *bundle = [NSBundle bundleForClass: [NetworkTopology class]];
        NSString *resourcescfg = [bundle pathForResource: @"resources"
						  ofType: @"cfg"];
	if (resourcescfg == nil){
		NSLog (@"%@: resources.cfg cannot be found", self);
		return NO;
	}

        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *currentPath = [fm currentDirectoryPath];
        NSArray *ar = [resourcescfg pathComponents];
        NSMutableArray *ar2 = [NSMutableArray arrayWithArray: ar];
        [ar2 removeLastObject];
        NSString *mediaPath = [NSString pathWithComponents: ar2];

        [fm changeCurrentDirectoryPath: mediaPath];


        mRoot = new Ogre::Root("plugins.cfg", "ogre.cfg", "Ogre.log");

        [self setupResources];

        [fm changeCurrentDirectoryPath: currentPath];

        Ogre::RenderSystem *r;
        r = mRoot->getRenderSystemByName ("OpenGL Rendering Subsystem");
        if (!r){
                NSLog (@"%@, %s: OpenGL Rendering Subsystem not found. Do you have a file named plugins.cfg in the execution directory? Is this file correctly configured?", self, __FUNCTION__);
                return NO;
        }
        mRoot->setRenderSystem (r);
        mRoot->initialise(false);

	return YES;
}

- (void) initializeResources
{
	NSBundle *bundle = [NSBundle bundleForClass: [NetworkTopology class]];
        NSString *resourcescfg = [bundle pathForResource: @"resources"
						  ofType: @"cfg"];

        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *currentPath = [fm currentDirectoryPath];
        NSArray *ar = [resourcescfg pathComponents];
        NSMutableArray *ar2 = [NSMutableArray arrayWithArray: ar];
        [ar2 removeLastObject];
        NSString *mediaPath = [NSString pathWithComponents: ar2];

        [fm changeCurrentDirectoryPath: mediaPath];

	Ogre::ResourceGroupManager *resource;
        resource = Ogre::ResourceGroupManager::getSingletonPtr();
        resource->initialiseAllResourceGroups();

        [fm changeCurrentDirectoryPath: currentPath];

}
@end
