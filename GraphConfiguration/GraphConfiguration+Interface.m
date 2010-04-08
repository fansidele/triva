/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "GraphConfiguration.h"

@implementation GraphConfiguration (Interface)
- (void) initInterface
{
	configurations = [[NSMutableDictionary alloc] init];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	id exist = [defaults objectForKey: @"GraphConfigurationItems"];
	if (exist){
		[configurations addEntriesFromDictionary: exist];
	}

	// gui configuration
	NSString *lastSelected;
	lastSelected = [defaults objectForKey: @"GraphConfigurationSelected"];
	if (lastSelected){
		[self refreshPopupAndSelect: lastSelected];
	}
	[conf setDelegate: self];
}

- (void) updateDefaults
{
	NSUserDefaults *defaults;
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: configurations
		     forKey: @"GraphConfigurationItems"];

	NSString *selected = [popup titleOfSelectedItem];
	if (selected){
		[defaults setObject: selected
		     forKey: @"GraphConfigurationSelected"];
	}
	[defaults synchronize];
}

- (void) refreshPopupAndSelect: (NSString*)toselect
{
	[popup removeAllItems];
	[popup addItemsWithTitles: [configurations allKeys]];
	int select = 0;
	if ([configurations objectForKey: toselect]){
		select = [popup indexOfItemWithTitle: toselect];
	}
	[popup selectItemAtIndex: select];
	[self change: self];
}

- (void) apply: (id)sender
{
	NSString *current = [popup titleOfSelectedItem];
	NSDictionary *dict = [[configurations objectForKey: current]
					propertyList];

	if ([ok state] == NSOnState){
		NS_DURING
		[self setConfiguration: dict];
		NS_HANDLER
			NSLog (@"%@", localException);
		NS_ENDHANDLER
	}
}

- (void) newWithTitle: (NSString*)t andConf: (NSString*) c
{
	[popup addItemWithTitle: t];
	[popup selectItemWithTitle: t];
	[title setStringValue: t];
	[conf setString: c];
	[ok setState: NSOnState];
	[configurations setObject: c
	   forKey: t];
	[self updateDefaults];
}

- (void) new: (id)sender
{
	static int counter = 0;
	NSString *nTitle=[NSString stringWithFormat:@"*(unnamed-%d)",counter++];
	while ([configurations objectForKey: nTitle]){
		nTitle = [NSString stringWithFormat:@"*(unnamed-%d)",counter++];
	}
	NSString *basic = @"{\n\
  root = ;\n\
\n\
  node-container = ();\n\
  node-size = ;\n\
  node-color = ;\n\
  node-gradient = ();\n\
  node-separation = ();\n\
  node-bar = ();\n\
\n\
  edge-container = (  );\n\
  edge-src = ;\n\
  edge-dst = ;\n\
  edge-size = ;\n\
  edge-gradient = ();\n\
\n\
  graphviz-algorithm = neato;\n\
}";
	[self newWithTitle: nTitle andConf: basic];
}

- (void) change: (id)sender
{
	NSString *selected = [popup titleOfSelectedItem];
	NSString *str = [configurations objectForKey: selected];
	[title setStringValue: selected];
	[conf setString: str];
	[ok setState: NSOnState];
	[self updateDefaults];
}

- (void) textDidChange: (id) sender
{
	NS_DURING
		NSString *str = [NSString stringWithString:
					[[conf textStorage] string]];
		id dict = [str propertyList];
		if (dict){
			[configurations setObject: str
				   forKey: [popup titleOfSelectedItem]];
			[ok setState: NSOnState];
			[self updateDefaults];
		}
	NS_HANDLER
		[ok setState: NSOffState];
		NSLog (@"%@", localException);
	NS_ENDHANDLER
}

- (void) updateTitle: (id) sender
{
	if (![title stringValue]){
		return;
	}

	NSString *current = [popup titleOfSelectedItem];
	NSDictionary *dict = [configurations objectForKey: current];
	[dict retain];
	[configurations removeObjectForKey: current];
	[configurations setObject: dict forKey: [title stringValue]];
	[dict release];

	[self refreshPopupAndSelect: [title stringValue]];
	[self updateDefaults];
}

- (void) del: (id) sender
{
	[configurations removeObjectForKey: [popup titleOfSelectedItem]];
	[self refreshPopupAndSelect: nil];
	[self updateDefaults];
}

- (void) copy: (id) sender
{
	NSString *current = [popup titleOfSelectedItem];
	NSDictionary *dict = [configurations objectForKey: current];

	NSString *new = [NSString stringWithFormat: @"%@-copy", current];
	[self newWithTitle: new andConf: [dict description]];
}
@end
