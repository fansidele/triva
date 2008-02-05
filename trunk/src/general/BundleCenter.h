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
#ifndef __BUNDLECENTER_H
#define __BUNDLECENTER_H
#include <Foundation/Foundation.h>
#include <DIMVisual/Protocols.h>

@interface BundleCenter : NSObject
{
	NSMutableArray *bundlePaths;
	NSMutableDictionary *bundlesLoaded;
}
- (id) init;
- (void) addBundleDirectory: (NSString *) newPath;
- (NSArray *) listBundlesAvailable;
- (NSDictionary *) configurationForBundleWithName: (NSString *) name;
- (NSDictionary *) configureBundlesWithThis: (NSDictionary *) conf;
- (BOOL) loadBundleWithName: (NSString *) name;
@end

#endif
