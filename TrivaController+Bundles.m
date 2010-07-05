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
#include "TrivaController.h"
#include "config.h"

@implementation TrivaController (Bundles)
- (NSBundle *)loadTrivaBundleNamed:(NSString*)name
{
  NSString *bundleNameDev;
  NSString *bundleName;
  NSMutableArray *bundlePaths;
  NSEnumerator *pathEnumerator;
  NSString *path;
  NSString *bundlePath;
  NSBundle *bundle;

  bundleName = [@"Bundles" stringByAppendingPathComponent:@PROJECT_NAME];
  bundleName = [bundleName stringByAppendingPathComponent:name];
  bundleName = [bundleName stringByAppendingPathExtension:@"bundle"];

  bundleNameDev = [@"" stringByAppendingPathComponent: name];
  bundleNameDev = [bundleNameDev stringByAppendingPathComponent:name];
  bundleNameDev = [bundleNameDev stringByAppendingPathExtension:@"bundle"];

  /* try dev */
  NSFileManager *manager = [NSFileManager defaultManager];
  bundlePath = [manager currentDirectoryPath];
  bundlePath = [bundlePath stringByAppendingPathComponent:bundleNameDev];
  bundle = [NSBundle bundleWithPath:bundlePath];
  if ([bundle load]) {
      [bundles setObject:bundle forKey:name];
      NSLog (@"Warning, using DEV bundle(%@) at %@", name, bundlePath);
      return bundle;
  }

  bundlePaths = [NSMutableArray arrayWithArray:
  [[NSUserDefaults standardUserDefaults]
                                     arrayForKey:@"BundlePaths"]];
  if (!bundlePaths || [bundlePaths count] == 0) {
      bundlePaths = [NSMutableArray arrayWithArray:
                         NSSearchPathForDirectoriesInDomains(
                                        NSAllLibrariesDirectory,
                                        NSAllDomainsMask, YES)];
  }

  pathEnumerator = [bundlePaths objectEnumerator];
  while ((path = [pathEnumerator nextObject]) != nil) {
      bundlePath = [path stringByAppendingPathComponent:bundleName];
      bundle = [NSBundle bundleWithPath:bundlePath];
      if ([bundle load]) {
          [bundles setObject:bundle forKey:name];
          return bundle;
      }
  }
  [NSException raise:@"TrivaException" format:@"Bundle '%@' not found", name];
  return nil;
}

- (NSBundle *)bundleWithName:(NSString *)name
{
  NSBundle *bundle;

  bundle = [bundles objectForKey:name];
  if (bundle == nil) {
    if ([self loadBundleNamed:name] == nil){
      [self loadTrivaBundleNamed:name];
    }
    bundle = [bundles objectForKey:name];
  }
  return bundle;
}

- (NSBundle *)loadBundleNamed:(NSString*)name
{
  NSString *bundleName;
  NSArray *bundlePaths;
  NSEnumerator *pathEnumerator;
  NSString *path;
  NSString *bundlePath;
  NSBundle *bundle;

  bundleName = [@"Bundles" stringByAppendingPathComponent:@"Paje"];
  bundleName = [bundleName stringByAppendingPathComponent:name];
  bundleName = [bundleName stringByAppendingPathExtension:@"bundle"];

  bundlePaths = [[NSUserDefaults standardUserDefaults]
                                     arrayForKey:@"BundlePaths"];
  if (!bundlePaths) {
      bundlePaths = NSSearchPathForDirectoriesInDomains(
                                          NSAllLibrariesDirectory,
                                          NSAllDomainsMask, YES);
  }

  pathEnumerator = [bundlePaths objectEnumerator];
  while ((path = [pathEnumerator nextObject]) != nil) {
      bundlePath = [path stringByAppendingPathComponent:bundleName];
      bundle = [NSBundle bundleWithPath:bundlePath];
      if ([bundle load]) {
          [bundles setObject:bundle forKey:name];
          return bundle;
      }
  }
  //[NSException raise:@"PajeException" format:@"Bundle '%@' not found", name];
  return nil;
}
@end
