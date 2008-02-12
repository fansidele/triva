#include "CEGUIManager.h"

CEGUI::Window *CEGUIManager::getWindow (std::string name)
{
	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	return win->getWindow (name);
}
/*

CEGUI::Window *CEGUIManager::getPaneBundleWindow ()
{
	return this->getWindow("bundleWindowPane");
}

CEGUI::Window *CEGUIManager::getComboBundleWindow ()
{
	return this->getWindow("bundleWindowCombo");
}

CEGUI::Window *CEGUIManager::getBundleWindow ()
{
	return this->getWindow("bundleWindow");
}

bool CEGUIManager::configureBundleWindow ()
{
	this->getBundleWindow()->subscribeEvent(CEGUI::FrameWindow::EventCloseClicked,CEGUI::Event::Subscriber(&CEGUIManager::hideBundleWindow, this));
	this->hideBundleWindow ();
	return true;
}

bool CEGUIManager::showBundleWindow (const CEGUI::EventArgs &e)
{
	return this->showBundleWindow();
}

bool CEGUIManager::showBundleWindow ()
{
	this->getBundleWindow()->setVisible(1);
	return true;
}

bool CEGUIManager::hideBundleWindow (const CEGUI::EventArgs &e)
{
	return this->hideBundleWindow();
}

bool CEGUIManager::hideBundleWindow ()
{
	this->getBundleWindow()->setVisible(0);
	return true;
}
*/

bool CEGUIManager::addMenuNamed (std::string bundleName)
{
	CEGUI::WindowManager *win = CEGUI::WindowManager::getSingletonPtr();
	if (win->isWindowPresent (bundleName)){
		return false;
	}

	CEGUI::Window *menu = this->getWindow ("menu");
	CEGUI::MenuItem *menuitem = (CEGUI::MenuItem *) CEGUI::WindowManager::getSingleton().createWindow("WindowsLook/MenuItem", bundleName);
	menuitem->setText (bundleName);

	std::string popupName = bundleName;
	popupName.append ("Popup");
	CEGUI::PopupMenu* popupMenu = (CEGUI::PopupMenu*)CEGUI::WindowManager::getSingleton().createWindow("WindowsLook/PopupMenu", popupName);
	menu->addChildWindow (menuitem);
	menuitem->addChildWindow (popupMenu);
	return true;
}

bool CEGUIManager::addDictionarySubMenu (id val, std::string optionName, CEGUI::PopupMenu* p)
{

	NSArray *ks = [val allKeys];
	unsigned int i;
	for (i = 0; i < [ks count]; i++){
		NSString *k = [ks objectAtIndex: i];

		if ([k isEqual: @"ID"]){
			continue;
		}

		id kv = [val objectForKey: k];

		std::string kstr = optionName;
		kstr.append("#");
		kstr.append([k cString]);
		std::cout << kstr << std::endl;
	
		
		CEGUI::MenuItem *menuitem = (CEGUI::MenuItem *) CEGUI::WindowManager::getSingleton().createWindow("WindowsLook/MenuItem", kstr);
		p->addChildWindow (menuitem);
		menuitem->setText ([k cString]);

		if ([kv isKindOf: [NSDictionary class]]){
			std::string optionPopupName = kstr;
			optionPopupName.append ("Popup");

			CEGUI::PopupMenu* np = (CEGUI::PopupMenu*) CEGUI::WindowManager::getSingleton().createWindow("WindowsLook/PopupMenu", optionPopupName);
			menuitem->addChildWindow (np);
			this->addDictionarySubMenu (kv, kstr, np);
		}else if ([kv isKindOf: [NSString class]]){
			menuitem->subscribeEvent(CEGUI::PushButton::EventClicked,CEGUI::Event::Subscriber(&CEGUIManager::bundleMenuOption, this));
		}
	}
	return true;
}

bool CEGUIManager::addSubMenu (std::string bundleName, std::string option, id val)
{
	std::string popupName = bundleName;
	popupName.append ("Popup");

	CEGUI::PopupMenu* popupMenu;
	popupMenu = (CEGUI::PopupMenu*)this->getWindow (popupName);

	std::string optionName = bundleName;
	optionName.append ("#");
	optionName.append (option);

	CEGUI::MenuItem *menuitem = (CEGUI::MenuItem *) CEGUI::WindowManager::getSingleton().createWindow("WindowsLook/MenuItem", optionName);
	menuitem->setText (option);
	popupMenu->addChildWindow (menuitem);

	std::string optionPopupName = optionName;
	optionPopupName.append ("Popup");

	CEGUI::PopupMenu* optionPopupMenu = (CEGUI::PopupMenu*) CEGUI::WindowManager::getSingleton().createWindow("WindowsLook/PopupMenu", optionPopupName);
	menuitem->addChildWindow (optionPopupMenu);

	if ([val isKindOf: [NSSet class]]){
		unsigned int i;
		NSArray *ar = [val allObjects];
		for (i = 0; i < [ar count]; i++){
			std::string subOptionName = optionName;
			subOptionName.append ("#");
			subOptionName.append([[ar objectAtIndex: i] cString]);
			

			CEGUI::MenuItem *suboptionitem = (CEGUI::MenuItem *) CEGUI::WindowManager::getSingleton().createWindow("WindowsLook/MenuItem", subOptionName);
			suboptionitem->setText ([[ar objectAtIndex: i] cString]);
			suboptionitem->subscribeEvent(CEGUI::PushButton::EventClicked,CEGUI::Event::Subscriber(&CEGUIManager::bundleMenuOption, this));
			optionPopupMenu->addChildWindow (suboptionitem);
		}
	}else if ([val isKindOf: [NSDictionary class]]){
		this->addDictionarySubMenu (val, optionName, optionPopupMenu);
	}
	return true;
}

bool CEGUIManager::bundleMenuOption (const CEGUI::EventArgs &e)
{
	const CEGUI::WindowEventArgs& we = static_cast<const
CEGUI::WindowEventArgs&>(e);

	CEGUI::MenuItem *m = (CEGUI::MenuItem*) &we.window;

	NSString *str = [NSString stringWithFormat: @"%s",we.window->getName().c_str()];
	NSLog (@"str = %@", str);
	NSArray *ar = [str componentsSeparatedByString: @"#"];
	NSLog (@"ar = %@", ar);
	NSString *bundle = [ar objectAtIndex: 0];
	NSString *option = [ar objectAtIndex: 1];
	NSString *value = [ar lastObject];
	[viewController optionValue:value optionNamed:option ofBundle:bundle];

	return true;
}

