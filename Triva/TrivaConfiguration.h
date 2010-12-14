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
#ifndef __TrivaConfiguration_h
#define __TrivaConfiguration_h
#include <Foundation/Foundation.h>

typedef enum { TrivaGraphView,
               TrivaSquarifiedTreemap,
               TrivaMerge,
               TrivaComparison,
               TrivaLinkView,
               TrivaStat,
               TrivaCheck,
               TrivaHierarchy,
               TrivaList,
               TrivaInstances } TrivaVisualizationComponent;

typedef enum { TrivaConfigurationHelp,
               TrivaConfigurationOK } TrivaConfigurationState;

@interface TrivaConfiguration : NSObject
{
  NSMutableDictionary *conf;
  NSMutableArray *input;

  TrivaConfigurationState state;
}
- (id) initWithArguments: (const char**)argv
                 andSize: (int) argc
       andDefaultOptions: (NSDictionary *) options;
- (TrivaVisualizationComponent) visualizationComponent;
- (TrivaConfigurationState) configurationState;
- (void) setOption: (NSString*) option withValue: (NSString*) value;
- (void) addInputFile: (NSString *) filename;
- (NSArray *) inputFiles;
- (NSDictionary *) configuredOptions;
- (NSDictionary *) configuredOptionsForClass: (Class) componentClass;
- (BOOL) serverMode;
- (int) serverPort;
@end

#endif
