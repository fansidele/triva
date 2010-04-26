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

@implementation TypeFilter (GUI)
- (void) configureGUI
{

  //configuring right-side, with the type hierarchy
  outlineview = [scrollview documentView];
  [outlineview setDataSource: self];
  [outlineview setDelegate: self];
  [outlineview setAllowsColumnResizing: YES];
  [outlineview sizeToFit];
  [scrollview setDocumentView: outlineview];

  NSTableColumn *column;
  column = [[outlineview tableColumns] objectAtIndex: 1];
  NSButtonCell *bCell = (NSButtonCell*)[column dataCell];
  [bCell setButtonType: NSSwitchButton];
  [bCell setTitle: @""];

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
  [entities sizeToFit];

  selectedType = nil;
}

/* NSTableViewDataSource Protocol */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
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
                        row:(NSInteger)index
{
  if (selectedType != nil){

    //if description column
    if ([[[column headerCell] stringValue] isEqualToString: @"Entity"]){
      if ([super isContainerEntityType: selectedType]){
        NSEnumerator *en = [super enumeratorOfContainersTyped: selectedType
                                  inContainer: [super rootInstance]];
        return [[[en allObjects] objectAtIndex: index] name];
      }else{
        NSEnumerator *en;
        en = [[self unfilteredObjectsForEntityType: selectedType] objectEnumerator];
        return [[en allObjects] objectAtIndex: index];
      }
    }else{
    //else selected column
      if ([super isContainerEntityType: selectedType]){
        NSEnumerator *en = [super enumeratorOfContainersTyped: selectedType
                                  inContainer: [super rootInstance]];
        NSArray *array = [en allObjects];
        if ([self isHiddenContainer: [array objectAtIndex: index]
                      forEntityType: selectedType] == NO){
          return [NSNumber numberWithInt: NSOnState];
        }else{
          return [NSNumber numberWithInt: NSOffState];
        }
      }else{
        NSEnumerator *en;
        en = [[self unfilteredObjectsForEntityType: selectedType] objectEnumerator];
        if ([self isHiddenValue: [[en allObjects] objectAtIndex: index]
              forEntityType: selectedType]){
          return [NSNumber numberWithInt: NSOffState];
        }else{
          return [NSNumber numberWithInt: NSOnState];
          //retur no
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
              row:(NSInteger) index
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
            child:(NSInteger)index
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

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
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
