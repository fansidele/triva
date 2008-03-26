/*
   Copyright (c) 2005 Lucas Mello Schnorr <schnorr@gmail.com>
   
   This file is part of DIMVisual.
   
   DIMVisual is free software; you can redistribute it and/or modify it under
   the terms of the GNU Lesser General Public License as published by the
   Free Software Foundation; either version 2 of the License, or (at your
   option) any later version.
   
   DIMVisual is distributed in the hope that it will be useful, but WITHOUT ANY
   WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
   for more details.
   
   You should have received a copy of the GNU Lesser General Public License
   along with DIMVisual; if not, write to the Free Software Foundation, Inc.,
   59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
*/
#include "BundleCenter.h"

@implementation BundleCenter
/*
 *
 */
- (NSDictionary *) configurationForBundleWithName: (NSString *) name
{
	NSBundle *bundle = [bundlesLoaded objectForKey: name];
	id ds = [[bundle principalClass] alloc];

	return [ds configuration];
}

/*
 * tryToLoadBundle
 */
- (BOOL) tryToLoadBundle: (NSBundle *) bundle
{
	if ([bundle load]){
		Class x = [bundle principalClass];
		if (x == nil){
			return NO;
		}
		if ([x conformsToProtocol: @protocol(DataSource)] == NO){
			return NO;	
		}	
		return YES;
	}else{
		return NO;
	}
}

/*
 * defaultLocations
 */
- (void) defaultLocations
{
	int i;

	NSMutableArray *paths = (NSMutableArray *)NSStandardLibraryPaths();
	for (i = 0; i < [paths count]; i++){
		NSString *dir;
		BOOL is_Dir;	

		dir = [paths objectAtIndex: i];
		dir = [dir stringByAppendingPathComponent: @"Bundles"];
		dir = [dir stringByAppendingPathComponent: @"DIMVisual"];
		if ([[NSFileManager defaultManager] 
			fileExistsAtPath: dir isDirectory: &is_Dir]){
			[bundlePaths addObject: dir];
		}
	}
}

/*
 * addBundleDirectory
 */
- (void) addBundleDirectory: (NSString *) newPath
{
	[bundlePaths addObject: newPath];
}

/*
 * listBundlesAvailable
 */
- (NSArray *) listBundlesAvailable
{
	int i,j;
	NSMutableArray *ret = [[NSMutableArray alloc] init];

	for (i = 0; i < [bundlePaths count]; i++){

		NSArray *subpaths = [[NSFileManager defaultManager]
				subpathsAtPath: [bundlePaths objectAtIndex: i]];
		for (j = 0; j < [subpaths count]; j++){
			NSString *pna, *s1, *s2;
			pna = [subpaths objectAtIndex: j];
			NSArray *ar1 = [pna componentsSeparatedByString:@"."];
			if ([[ar1 lastObject] isEqual: @"bundle"]){
				s1 = [bundlePaths objectAtIndex: i];
				s2 =[s1 stringByAppendingPathComponent: pna];
				NSBundle *bundle;
				bundle = [NSBundle bundleWithPath: s2];
				if ([self tryToLoadBundle: bundle]){
					[bundlesLoaded setObject: bundle
							forKey: pna];
					[ret addObject: pna];
				}
			}
		}
	}
	[ret autorelease];
	return ret;
}

/*
 *
 */
- (NSString *) pathWithBundleName: (NSString *) name
{
	int i;
	NSString *ret = nil;
	NSString *pathOfProgramExecution;
		
	pathOfProgramExecution = [[NSFileManager defaultManager] currentDirectoryPath];
	for (i = 0; i < [bundlePaths count]; i++){
		NSString *thispath = [bundlePaths objectAtIndex: i];
		ret = [thispath stringByAppendingPathComponent: name];
		if ([[NSFileManager defaultManager] changeCurrentDirectoryPath: ret]==YES){
			break;
		}
	}
	[[NSFileManager defaultManager] changeCurrentDirectoryPath: pathOfProgramExecution];
	if (ret != nil){
		return ret;
	}else{
		return nil;
	}
}

/*
 *
 */
- (BOOL) loadBundleWithName: (NSString *) name
{
	NSString *path = [self pathWithBundleName: name];	

	if (path == nil){
		return NO;
	}

	NSBundle *bundle = [NSBundle bundleWithPath: path];
	if ([self tryToLoadBundle: bundle]){
		[bundlesLoaded setObject: bundle forKey: name];
		return YES;
	}else {
		return NO;
	}
}

/*
 * init
 */
- (id) init
{
	self = [super init];
	bundlePaths = [[NSMutableArray alloc] init];
	bundlesLoaded = [[NSMutableDictionary alloc] init];
	[self defaultLocations];
	return self;
}

/*
 * dealloc
 */
- (void) dealloc
{
	[bundlePaths release];
	[bundlesLoaded release];
	[super dealloc];
}

/*
 *
 */
- (NSDictionary *) configureBundle: (NSString *) name withThis: (NSDictionary *) conf
{
	int i;

	NSDictionary *tofill = [self configurationForBundleWithName: name];
	NSString *bundleid = [tofill objectForKey: @"id"];
	NSMutableDictionary *parameters = [tofill objectForKey: @"parameters"];
	NSArray *allKeys = [parameters allKeys];
	NSMutableArray *allPossibleConfiguration = [[NSMutableArray alloc]init];
	
	for (i = 0; i < [allKeys count]; i++){
		NSString *oc = [allKeys objectAtIndex: i];
		[allPossibleConfiguration addObject: [NSString stringWithFormat: @"-%@-%@", bundleid, oc]];
	}

	for (i = 0; i < [allPossibleConfiguration count]; i++){

		NSArray *x = [conf objectForKey: [allPossibleConfiguration objectAtIndex: i]];
		if (x != nil){
			[parameters setObject: x forKey: [allKeys objectAtIndex: i]];
		}else{
			[parameters setObject: [NSArray array] forKey: [allKeys objectAtIndex: i]];
		}
	}
	return tofill;
} 

/*
 *
 */
- (NSString *) principalClassOfBundleNamed: (NSString *) name
{
	Class x = [[bundlesLoaded objectForKey: name] principalClass];
	NSString *ret = NSStringFromClass (x);
	return ret;
}

/*
 *
 */
- (NSDictionary *) configureBundlesWithThis: (NSDictionary *) conf
{
	int i;

	if ([bundlesLoaded count] == 0){
		return nil;
	}

	NSArray *list = [NSArray arrayWithArray: [bundlesLoaded allKeys]];

	NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
	for (i = 0; i < [list count]; i++){
		[ret setObject: [self configureBundle: [list objectAtIndex: i] withThis: conf] forKey: [self principalClassOfBundleNamed: [list objectAtIndex: i]]];
	}
	[ret autorelease];
	return ret;
}
@end
