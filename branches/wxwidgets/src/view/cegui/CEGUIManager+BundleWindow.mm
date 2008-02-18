#include "CEGUIManager.h"

#ifndef TRIVAWXWIDGETS

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

bool CEGUIManager::addStringSubMenu (id val, std::string optionName, CEGUI::PopupMenu* p)
{
	std::string a = [val cString];
	if (a.empty()){
		return false;
	}

	std::string subOptionName = optionName;
	subOptionName.append ("#");
	subOptionName.append(a);

	CEGUI::MenuItem *suboptionitem = (CEGUI::MenuItem *) CEGUI::WindowManager::getSingleton().createWindow("WindowsLook/MenuItem", subOptionName);
	suboptionitem->setText ([val cString]);
	suboptionitem->subscribeEvent(CEGUI::PushButton::EventClicked,CEGUI::Event::Subscriber(&CEGUIManager::bundleMenuOption, this));
	p->addChildWindow (suboptionitem);
	return true;
}

bool CEGUIManager::addArraySubMenu (id val, std::string optionName, CEGUI::PopupMenu* p)
{
	unsigned int i;
	NSArray *ar = (NSArray *)val;
	for (i = 0; i < [ar count]; i++){
		this->addStringSubMenu ([ar objectAtIndex: i], optionName, p);
	}
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

	this->addSubMenu (optionName, optionPopupMenu, val);
	return true;
}

bool CEGUIManager::bundleMenuOption (const CEGUI::EventArgs &e)
{
	const CEGUI::WindowEventArgs& we = static_cast<const
CEGUI::WindowEventArgs&>(e);

	CEGUI::MenuItem *m = (CEGUI::MenuItem*) &we.window;

	NSString *str = [NSString stringWithFormat: @"%s",we.window->getName().c_str()];
	NSArray *ar = [str componentsSeparatedByString: @"#"];
	NSString *bundle = [ar objectAtIndex: 0];
	NSString *option = [ar objectAtIndex: 1];
	NSString *value = [ar lastObject];
	[viewController optionValue:value optionNamed:option ofBundle:bundle];

	return true;
}

bool CEGUIManager::setSubMenu (std::string bundleName, std::string option, id val)
{
	std::string optionName = bundleName;
	optionName.append ("#");
	optionName.append (option);

	std::string optionPopupName = optionName;
	optionPopupName.append ("Popup");


	CEGUI::PopupMenu* optionPopupMenu;
	optionPopupMenu = (CEGUI::PopupMenu*)this->getWindow (optionPopupName);

	if (optionPopupMenu == NULL){
		return false;
	}
	this->addSubMenu (optionName, optionPopupMenu, val);
	return true;
}


bool CEGUIManager::addSubMenu (std::string optionName, CEGUI::PopupMenu* optionPopupMenu, id val)
{
	if ([val isKindOf: [NSSet class]]){
		NSArray *ar = [val allObjects];
		this->addArraySubMenu((id)ar, optionName, optionPopupMenu);
	}else if ([val isKindOf: [NSDictionary class]]){
		this->addDictionarySubMenu (val, optionName, optionPopupMenu);
	}else if ([val isKindOf: [NSString class]]){
		this->addStringSubMenu (val, optionName, optionPopupMenu);
	}else if ([val isKindOf: [NSArray class]]){
		this->addArraySubMenu (val, optionName, optionPopupMenu);
	}
	return true;
}

#endif //TRIVAWXWIDGETS

