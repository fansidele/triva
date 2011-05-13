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

@implementation TrivaController (Components)
- (id)createComponentWithName:(NSString *)componentName
                 ofClassNamed:(NSString *)className
               withDictionary:(NSMutableDictionary *) comps
{
    Class componentClass;
    id component;

    componentClass = NSClassFromString(className);
    if (componentClass == Nil) {
        NSBundle *bundle;
        bundle = [[NSApp delegate] bundleWithName:className];
        componentClass = NSClassFromString(className);
        if (componentClass == nil){
          componentClass = [bundle principalClass];
        }
    }
    component = [componentClass componentWithController: (id)self];
    if (component != nil) {
        [comps setObject:component forKey:componentName];
    }
    return component;
}


- (void)connectComponent:(id)c1 toComponent:(id)c2
{
    [c1 setOutputComponent:c2];
    [c2 setInputComponent:c1];
}


- (id)componentWithName:(NSString *)name
         fromDictionary:(NSMutableDictionary *) comps
{
    id component;

    component = [comps objectForKey:name];
    if (component == nil) {
        NSString *className;
        if ([[NSScanner scannerWithString:name]
                scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
                           intoString:&className]) {
            component = [self createComponentWithName:name
                                         ofClassNamed:className
                                       withDictionary: comps];
        }
    }
    return component;
}


- (void)connectComponentNamed:(NSString *)n1
             toComponentNamed:(NSString *)n2
               fromDictionary:(NSMutableDictionary *) comps
{
    id c1;
    id c2;

    c1 = [self componentWithName:n1 fromDictionary: comps];
    c2 = [self componentWithName:n2 fromDictionary: comps];
    [self connectComponent:c1 toComponent:c2];
}


- (void)addComponentSequence:(NSArray *)componentSequence
              withDictionary:(NSMutableDictionary *) comps
{
    int index;
    int count;

    count = [componentSequence count];
    for (index = 1; index < count; index++) {
        NSString *componentName1;
        NSString *componentName2;
        componentName1 = [componentSequence objectAtIndex:index-1];
        componentName2 = [componentSequence objectAtIndex:index];
        [self connectComponentNamed:componentName1
                   toComponentNamed:componentName2
                     fromDictionary:comps];
    }
}


- (void)addComponentSequences:(NSArray *)componentSequences
               withDictionary:(NSMutableDictionary *) comps
{
    int index;
    int count;

    count = [componentSequences count];
    for (index = 0; index < count; index++) {
        NSArray *componentSequence;
        componentSequence = [componentSequences objectAtIndex:index];
        [self addComponentSequence:componentSequence
                    withDictionary:comps];
    }
}
@end
