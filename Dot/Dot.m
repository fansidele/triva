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
#include "Dot.h"

@implementation Dot
- (id)initWithController:(PajeTraceController *)c
{
  self = [super initWithController: c];
  if (self != nil){
  }
  return self;
}


- (void)printInstance:(id)instance level:(int)level
{

    NSLog(@"i%*.*s%@", level, level, "", [self descriptionForEntity:instance]);
    PajeEntityType *et;
    NSEnumerator *en;
    en = [[self containedTypesForContainerType:[self entityTypeForEntity:instance]] objectEnumerator];
    while ((et = [en nextObject]) != nil) {
        NSLog(@"t%*.*s%@", level+1, level+1, "", [self descriptionForEntityType:et]);
        if ([self isContainerEntityType:et]) {
            NSEnumerator *en2;
            PajeContainer *sub;
            en2 = [self enumeratorOfContainersTyped:et inContainer:instance];
            while ((sub = [en2 nextObject]) != nil) {
                [self printInstance:sub level:level+2];
            }
        } else {
            NSEnumerator *en3;
            PajeEntity *ent;
            en3 = [self enumeratorOfEntitiesTyped:et
                                      inContainer:instance
                                         fromTime:[self selectionStartTime]
                                           toTime:[self selectionEndTime]
                                      minDuration:0.0];
            while ((ent = [en3 nextObject]) != nil) {
                NSLog(@"e%*.*s%@", level+2, level+2, "", [self descriptionForEntity:ent]);
            }
        }
    }
}


- (void) dumpTraceInTextualFormat
{
  [self printInstance:[self rootInstance] level:0];
}

- (NSString *) dumpDotTraceFormatWithInstance: (id) instance
{
  NSMutableString *ret = [NSMutableString string];
  NSEnumerator *en = [[self containedTypesForContainerType:[self entityTypeForEntity:instance]] objectEnumerator];
  id et;
  while ((et = [en nextObject]) != nil) {
          if ([self isContainerEntityType:et]) {
      NSColor *color = [et color];
      double red, green, blue, alpha;
      NS_DURING
      [color getRed: &red green: &green blue: &blue alpha: &alpha];
      NS_HANDLER
        color = [NSColor blueColor];
        [color getRed: &red green: &green blue: &blue alpha: &alpha];
      NS_ENDHANDLER
      [ret appendString: [NSString stringWithFormat: @"\"%s\" [ /* fontsize=8,*/ label=\"%s\", style=filled, fillcolor=\"#%02x%02x%02x\" ] ;\n",
        [[instance description] cString], [[[[instance description] componentsSeparatedByString:@"-"] objectAtIndex: 0] cString], (int)(red*255), (int)(green*255), (int)(blue*255)]];
      NSEnumerator *en2;
      PajeContainer *sub;
      en2 = [self enumeratorOfContainersTyped:et inContainer:instance];
      while ((sub = [en2 nextObject]) != nil) {
        [ret appendString: [NSString stringWithFormat: @"\"%s\" -> \"%s\";\n", [[instance description] cString],
          [[sub description] cString]]];
        [ret appendString: [self dumpDotTraceFormatWithInstance: sub]];
      }
    }else{
//      if (![[[[instance description] componentsSeparatedByString:@"-"] objectAtIndex: 0] isEqualToString: @"surf"])continue;
      NSEnumerator *en3;
      PajeEntity *ent;
      en3 = [self enumeratorOfEntitiesTyped:et
                                      inContainer:instance
                                         fromTime:[self selectionStartTime]
                                           toTime:[self selectionEndTime]
                                      minDuration:0.0];
      id previous = [instance name];
      int flag = 1;
      while ((ent = [en3 nextObject]) != nil) {
        if (flag){
          [ret appendString: [NSString stringWithFormat: @"\"%s\" -> \"%p\";\n", [previous cString], ent]];
          flag = 0;
        }else{
          [ret appendString: [NSString stringWithFormat: @"\"%p\" -> \"%p\";\n", previous, ent]];//[[previous description] cString], [[ent description] cString]]];
        }
        if ([ent valueOfFieldNamed: @"PowerUsed"] != nil){
//          [ret appendString: [NSString stringWithFormat: @"\"%p\" [ label=\"%s(%s-%s)-%.2f\" ];\n",
//          ent, [[ent name] cString], [[[ent startTime] description] cString], [[[ent endTime] description] cString],
//          [[ent valueOfFieldNamed: @"PowerUsed"] floatValue]]];
          [ret appendString: [NSString stringWithFormat: @"\"%p\" [ label=\"%.2f\" ];\n",
          ent, [[ent valueOfFieldNamed: @"PowerUsed"] floatValue]]];
        }else if ([ent valueOfFieldNamed: @"BandwidthUsed"] != nil){
//          [ret appendString: [NSString stringWithFormat: @"\"%p\" [ label=\"%s(%s-%s)-%.2f\" ];\n",
//          ent, [[ent name] cString], [[[ent startTime] description] cString], [[[ent endTime] description] cString],
//          [[ent valueOfFieldNamed: @"BandwidthUsed"] floatValue]]];
          [ret appendString: [NSString stringWithFormat: @"\"%p\" [ label=\"%.2f\" ];\n",
          ent, [[ent valueOfFieldNamed: @"BandwidthUsed"] floatValue]]];
        }
        previous = ent;
      }
    }
  }
  return ret;
}

- (NSString *) dumpDotTraceFormat
{
  NSMutableString *ret = [NSMutableString string];
  [ret appendString: @"strict digraph TrivaDot {\n"];
  [ret appendString: [self dumpDotTraceFormatWithInstance: [self rootInstance]]];
  [ret appendString: @"}\n"];
  return ret;
}

/*
 * for type hierarchy in dot format
 */
- (NSString *) dotTypeHierarchy: (id) type
{
  NSMutableString *ret = [NSMutableString string];
  NSEnumerator *en = [[self containedTypesForContainerType: type] objectEnumerator];
  id et;
  [ret appendString:
    [NSString stringWithFormat:@"\"%p\"[label=\"%@\",shape=\"rectangle\"];\n",
      type, [type description]]];
  while ((et = [en nextObject]) != nil) {
          if ([self isContainerEntityType: et]) {
      [ret appendString: [self dotTypeHierarchy: et]];
    }else{
      NSString *shape = @"circle"; //default shape
      NSString *fillcolor = @"white"; //default color
      if ([et isKindOfClass: [PajeStateType class]]){
        shape = @"diamond";
        fillcolor = @"lightblue";
      }else if ([et isKindOfClass: [PajeLinkType class]]){
        shape = @"egg";
        fillcolor = @"green";
      }else if ([et isKindOfClass: [PajeVariableType class]]){
        shape = @"trapezium";
        fillcolor = @"yellow";
      }else if ([et isKindOfClass: [PajeEventType class]]){
        shape = @"triangle";
        fillcolor = @"red";
      }
      [ret appendString:
        [NSString stringWithFormat:@"\"%p\"[label=\"%@\", shape=\"%@\", style=filled, fillcolor=\"%@\"];\n", et,
          [et description], @"rectangle", fillcolor]];
    }
    [ret appendString:
      [NSString stringWithFormat: @"\"%p\"->\"%p\";\n",
        type, et]];
  }
  return ret;

}

- (NSString *) dotTypeHierarchy
{
  NSMutableString *ret = [NSMutableString string];
  [ret appendString: @"strict digraph DotTypeHierarchy {\n"];
  [ret appendString: [self dotTypeHierarchy: [[self rootInstance] entityType]]];
  [ret appendString: @"}\n"];
  return ret;
}

/*
 * arrival of a new time window 
 */
- (void) timeSelectionChanged
{
  //[self dumpTraceInTextualFormat];
  NSString *filename = [NSString stringWithFormat: @"type-%@.dot",
     [[[self traceDescription] componentsSeparatedByString: @"/"] lastObject]];
  [[self dotTypeHierarchy] writeToFile: filename atomically: NO];
  NSLog (@"Type hierarchy written in filename %@", filename);
  exit(1);
}
@end
