/*
    This file is part of Triva.

    Triva is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Triva is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Triva.  If not, see <http://www.gnu.org/licenses/>.
*/
#include "TypeFilter.h"
#include <regex.h>

@implementation TypeFilter (GUI)
- (void) configureGUI
{
  //configuring window
  [window initializeWithDelegate: self];

  //configuring right-side, with the type hierarchy
  outlineview = [scrollview documentView];
  [outlineview setDataSource: self];
  [outlineview setDelegate: self];
  [outlineview setAllowsColumnResizing: YES];
  [outlineview sizeToFit];
  [scrollview setDocumentView: outlineview];

  NSTableColumn *column;
  column = [[outlineview tableColumns] objectAtIndex: 1];
  NSButtonCell *bCell = [[NSButtonCell alloc] init];
  [bCell setButtonType: NSSwitchButton];
  [bCell setTitle: @""];
  [column setDataCell: bCell];

  //configuring left-side, with the list of entities
  entities = [[NSTableView alloc] init];
  [instances setDocumentView: entities];

  //adding first column
  column = [[NSTableColumn alloc] initWithIdentifier: @"Entity"];
  [[column headerCell] setStringValue: @"Entity"];
  [entities addTableColumn: column];
  [column release];

  //adding second column
  column = [[NSTableColumn alloc] initWithIdentifier: @"Selected"];
  [[column headerCell] setStringValue: @"Selected"];
  bCell = [[NSButtonCell alloc] init];
  [bCell setButtonType: NSSwitchButton];
  [bCell setTitle: @""];
  [column setDataCell: bCell];
  [entities addTableColumn: column];
  [column release];

  [entities setDataSource: self];
  [entities setDelegate: self];
  [entities setAllowsColumnResizing: YES];
  [entities setAllowsMultipleSelection: YES];
  [entities sizeToFit];

  //configuration expression text field
  [expression setDelegate: self];
  regex = (regex_t*)malloc(sizeof(regex_t));

  selectedType = nil;
  
}

- (void) regularExpression: (id) sender
{
  //we have a valid regular expression and user press enter
  if (selectedType != nil){
    NSEnumerator *en;
    if ([super isContainerEntityType: selectedType]){
      en = [super enumeratorOfContainersTyped: selectedType
                                inContainer: [super rootInstance]];
    }else{
      en = [[self unfilteredObjectsForEntityType: selectedType]
                            objectEnumerator];
    }
    id obj;

    NSMutableSet *setToYES = [[NSMutableSet alloc] init];
    NSMutableSet *setToNO = [[NSMutableSet alloc] init];

    while ((obj = [en nextObject])){
      if ([super isContainerEntityType: selectedType]){
        NSString *name = [obj name];
        if (![[expression stringValue] isEqualToString: @""]){
          if (!regexec (regex, [name cString], 0, NULL, 0)){
            BOOL current = [self isHiddenContainer: obj
                                     forEntityType: selectedType];
            if (!current){
              [setToNO addObject: obj];
            }else{
              [setToYES addObject: obj];
            }
          }
        }
      }else{
        NSString *value = obj;
        if (![[expression stringValue] isEqualToString: @""]){
          if (!regexec (regex, [value cString], 0, NULL, 0)){
            BOOL current = [self isHiddenValue: value
                                 forEntityType: selectedType];
            if (!current){
              [setToNO addObject: obj];
            }else{
              [setToYES addObject: obj];
            }
          }
        }
      }
    }

    if ([super isContainerEntityType: selectedType]){
      [self filterContainers: setToYES show: YES];
      [self filterContainers: setToNO show: NO];
    }else{
      [self filterValues: setToYES
           forEntityType: selectedType
                    show: YES];
      [self filterValues: setToNO
           forEntityType: selectedType
                    show: NO];
    }

    [setToYES release];
    [setToNO release];
  }
  [entities reloadData];
  [expression becomeFirstResponder];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
  //deselect all
  [entities deselectAll: self];

  [expression setBackgroundColor: [NSColor whiteColor]];

  //create regular expression based on user's input 
  NSString *expr = [expression stringValue];
  if ([expr isEqualToString: @""]){
    return;
  }
  if (regcomp (regex, [expr cString], REG_EXTENDED)){
    [expression setBackgroundColor: [NSColor redColor]];
    [expression setNeedsDisplay: YES];
    return;
  }

  [entities reloadData]; 
}

/* NSTableViewDataSource Protocol */
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
  if (selectedType != nil){

    if ([super isContainerEntityType: selectedType]){
      NSEnumerator *en = [super enumeratorOfContainersTyped: selectedType
                                inContainer: [super rootInstance]];
      int count = [[en allObjects] count];
      return count;
    }else{
      NSEnumerator *en;
      en = [[self unfilteredObjectsForEntityType: selectedType]
                            objectEnumerator];
      return [[en allObjects] count];
    }
     
  }else{
    return 0;
  }
}

- (id)            tableView:(NSTableView *)aTableView
  objectValueForTableColumn:(NSTableColumn *)column
                        row:(int)index
{
  if (selectedType != nil){

    //if description column
    if ([[[column headerCell] stringValue] isEqualToString: @"Entity"]){
      if ([super isContainerEntityType: selectedType]){
        NSEnumerator *en = [super enumeratorOfContainersTyped: selectedType
                                  inContainer: [super rootInstance]];
        NSArray *array = [en allObjects];
        NSString *name = [[array objectAtIndex: index] name];
        if (![[expression stringValue] isEqualToString: @""]){
          if (!regexec (regex, [name cString], 0, NULL, 0)){
            NSIndexSet *set = [NSIndexSet indexSetWithIndex: index];
            [entities selectRowIndexes: set byExtendingSelection: YES];
          }
        }
        return name;
      }else{
        NSEnumerator *en = [[self unfilteredObjectsForEntityType: selectedType]
                                        objectEnumerator];
        NSArray *array = [en allObjects];
        NSString *value = [array objectAtIndex: index];
        if (![[expression stringValue] isEqualToString: @""]){
          if (!regexec (regex, [value cString], 0, NULL, 0)){
            NSIndexSet *set = [NSIndexSet indexSetWithIndex: index];
            [entities selectRowIndexes: set byExtendingSelection: YES];
          }
        }
        return value;
      }
    }else{
    //else selected column
      if ([super isContainerEntityType: selectedType]){
        NSEnumerator *en = [super enumeratorOfContainersTyped: selectedType
                                  inContainer: [super rootInstance]];
        NSArray *array = [en allObjects];
        if ([self isHiddenContainer: [array objectAtIndex: index]
                      forEntityType: selectedType]){
          return [NSNumber numberWithInt: NSOffState];
        }else{
          return [NSNumber numberWithInt: NSOnState];
        }
      }else{
        NSEnumerator *en;
        en = [[self unfilteredObjectsForEntityType: selectedType] objectEnumerator];
        NSArray *array = [en allObjects];

        if ([self isHiddenValue: [array objectAtIndex: index]
                  forEntityType: selectedType]){
          return [NSNumber numberWithInt: NSOffState];
        }else{
          return [NSNumber numberWithInt: NSOnState];
        }
      }
    }
  }else{
    return 0;
  }
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
              row:(int) index
{
  if ([super isContainerEntityType: selectedType]){
    NSEnumerator *en = [super enumeratorOfContainersTyped: selectedType
                              inContainer: [super rootInstance]];
    NSArray *array = [en allObjects];
    id obj = [array objectAtIndex: index];
    BOOL show = [anObject boolValue];
    [self filterContainer: obj show: show];
  }else{
    NSEnumerator *en;
    en = [[self unfilteredObjectsForEntityType: selectedType] objectEnumerator];

    [self filterValue: [[en allObjects] objectAtIndex: index]
          forEntityType: selectedType
          show: [anObject boolValue]];
  }
}


/* NSOutlinewViewDataSource Protocol ... */
- (id)outlineView:(NSOutlineView *)outlineView
            child:(int)index
           ofItem:(id)item
{
  if (item == nil){
    item = [[super rootInstance] entityType];
  }
  return [[super containedTypesForContainerType: item] objectAtIndex: index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  if (item == nil){
    return YES;
  }else{
    return [super isContainerEntityType: item];
  }
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  if (item == nil){
    item = [[super rootInstance] entityType];
  }
  return [[super containedTypesForContainerType: item] count];
}

- (id)              outlineView:(NSOutlineView *)outlineView
      objectValueForTableColumn:(NSTableColumn *)tableColumn
                         byItem:(id)item
{
  if ([[[tableColumn headerCell] stringValue] compare:@"Type"] == NSOrderedSame){
    return [item description];
  }else if ([[[tableColumn headerCell] stringValue] compare:@"Selected"] == NSOrderedSame){
    if ([self isHiddenEntityType: item]){
      return [NSNumber numberWithInt: NSOffState];
    }else{
      return [NSNumber numberWithInt: NSOnState];
    }
  }
  return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView
     setObjectValue:(id)object
     forTableColumn:(NSTableColumn *)tableColumn
             byItem:(id)item
{
  if ([object boolValue] == NO){
    [self filterEntityType: item show: NO];
  }else{
    [self filterEntityType: item show: YES];
  }
}

/* NSOutlineViewDelegate methods ... */
/*
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectTableColumn:(NSTableColumn *)tableColumn
{
  NSLog (@"AA %s %@", __FUNCTION__, tableColumn);
  return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item
{
  NSLog (@"AA %s %@", __FUNCTION__, item);
  return NO;
}
*/

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
  if ([outlineView tag] == 0){
    selectedType = item;
    [entities reloadData];
    [entities sizeToFit];
    return YES;
  }else{
    return NO;
  }
}

/*
- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
  NSLog (@"AA %s %@ %@", __FUNCTION__, tableColumn, item);
  return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
  NSLog (@"AA %s ## %@ ## %@ %@", __FUNCTION__, cell, tableColumn, item);
  if ([[[tableColumn headerCell] stringValue] compare:@"Selected"] == NSOrderedSame){
    [cell setState: NSOnState];
    [outlineview setNeedsDisplay: YES];
  }
}
*/
@end
