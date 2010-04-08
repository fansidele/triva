#include "TypeFilterWindow.h"
#include <General/PajeType.h>

wxString NSSTRINGtoWXSTRING (NSString *ns)
{
        if (ns == nil){
                return wxString();
        }
        return wxString::FromAscii ([ns cString]);
}

NSString *WXSTRINGtoNSSTRING (wxString wsa)
{
        char sa[100];
        snprintf (sa, 100, "%S", wsa.c_str());
        return [NSString stringWithFormat:@"%s", sa];
}

std::string WXSTRINGtoSTDSTRING (wxString wsa)
{
        char sa[100];
        snprintf (sa, 100, "%S", wsa.c_str());
        return std::string(sa);
}

TypeFilterWindow::TypeFilterWindow( wxWindow* parent )
:
TypeFilterWindowAuto( parent )
{

}

void TypeFilterWindow::HierarchyChanged (PajeEntityType *t, wxTreeItemId root)
{
	NSString *label;
	wxTreeItemId item;

	//define label
	if ([filter isContainerEntityType: t]){
		label = [NSString stringWithFormat:@"%@ (Container)", [t name]];
	}else if ([t isKindOfClass: [PajeStateType class]]){
		label = [NSString stringWithFormat:@"%@ (State)", [t name]];
	}else if ([t isKindOfClass: [PajeLinkType class]]){
		label = [NSString stringWithFormat:@"%@ (Link)", [t name]];
	}else if ([t isKindOfClass: [PajeVariableType class]]){
		label = [NSString stringWithFormat:@"%@ (Variable)", [t name]];
	}else if ([t isKindOfClass: [PajeEventType class]]){
		label = [NSString stringWithFormat:@"%@ (Event)", [t name]];
	}
	if (!root){
		item = typeHierarchyCrtl->AddRoot (NSSTRINGtoWXSTRING(label));
	}else{
		item = typeHierarchyCrtl->AppendItem (root,
			NSSTRINGtoWXSTRING(label));
	}

	//if container, recurse on children
	if ([filter isContainerEntityType: t]){
		NSEnumerator *en;
		en = [[[filter inputComponent]containedTypesForContainerType: t]
				objectEnumerator];
		PajeEntityType *et;
		while ((et = [en nextObject]) != nil) {
			this->HierarchyChanged (et, item);
		}
	}
}

void TypeFilterWindow::HierarchyChanged ()
{
	//delete everything
	typeHierarchyCrtl->DeleteAllItems();

	//add root
	PajeEntityType *rootType = [[[filter inputComponent] rootInstance] entityType];
	this->HierarchyChanged (rootType, NULL);

	//expand
	typeHierarchyCrtl->ExpandAll();
}

void TypeFilterWindow::selectionChanged( wxTreeEvent& event )
{
	wxTreeItemId item;
	NSString *typeName;
	PajeEntityType *type;

	//clear checkListBox
	checkListBox->Clear();

	item = event.GetItem();
	typeName = WXSTRINGtoNSSTRING (typeHierarchyCrtl->GetItemText (item));
	typeName = [[typeName componentsSeparatedByString: @" "]
		objectAtIndex: 0];
	type = [[filter inputComponent] entityTypeWithName: typeName];

	//set current selected type
	currentSelectedType = type;

	//setting texts and verifying if their are hidden
	mainCheckBox->SetLabel (typeHierarchyCrtl->GetItemText (item));
	mainCheckBox->Enable();
	if ([filter isContainerEntityType: type]){
		NSEnumerator *en = [[filter inputComponent]
					enumeratorOfContainersTyped: type
					inContainer: [filter rootInstance]];
		PajeContainer *c;
		while ((c = [en nextObject])){
			//add container name
			checkListBox->Append(NSSTRINGtoWXSTRING([c name]));

			//verify if container is hidden
			if (![filter isHiddenContainer: c forEntityType: type]){
				checkListBox->Check (checkListBox->GetCount()-1,
					true);
			}else{
				checkListBox->Check (checkListBox->GetCount()-1,
					false);
			}
		}
	}else{
		//if not container, add the possible values for each type
		NSEnumerator *en;
		en = [[filter allValuesForEntityType: type] objectEnumerator];
		NSString *val;
		while ((val = [en nextObject]) != nil){
			//add know value
			checkListBox->Append(NSSTRINGtoWXSTRING(val));

			//verify if the value for current ET is not hidden
			if (![filter isHiddenValue: val forEntityType: type]){
				checkListBox->Check (checkListBox->GetCount()-1,
					true);
			}else{
				checkListBox->Check (checkListBox->GetCount()-1,
					false);
			}
		}
	}

	//verify if the entityType is not hidden
	if (![filter isHiddenEntityType: type]){
		mainCheckBox->SetValue(true);
		checkListBox->Enable();
	}else{
		mainCheckBox->SetValue(false);
		checkListBox->Disable();
	}
}

void TypeFilterWindow::mainCheckBoxClicked( wxCommandEvent& event )
{
	if (mainCheckBox->IsChecked()){
		checkListBox->Enable();
		[filter showEntityType: currentSelectedType];
	}else{
		checkListBox->Disable();
		[filter hideEntityType: currentSelectedType];
	}
}

void TypeFilterWindow::checkListBoxClicked( wxCommandEvent& event )
{
	if ([filter isContainerEntityType: currentSelectedType]){
		//treat as containers
		PajeContainer *container;
		NSString *containerName;

		containerName = WXSTRINGtoNSSTRING(checkListBox->GetString
                        (event.GetInt()));
		container = [[filter inputComponent]
				containerWithName: containerName
					type: currentSelectedType];
		if (checkListBox->IsChecked (event.GetInt())){
			[filter showContainer: container];
		}else{
			[filter hideContainer: container];
		}
	}else{
		//treat as values for entity types
		NSString *value = WXSTRINGtoNSSTRING(checkListBox->GetString
			(event.GetInt()));
		if (checkListBox->IsChecked (event.GetInt())){
			[filter showValue: value
			    forEntityType: currentSelectedType];
		}else{
			[filter hideValue: value
			    forEntityType: currentSelectedType];
		}
	}
}
