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
#include "TrivaSquare.h"

@implementation TrivaSquare
- (id) initWithConfiguration: (NSDictionary*) conf
                        name: (NSString*) n
                      values: (NSDictionary*) val
                        node: (TrivaGraph*) obj
                      filter: (TrivaFilter*) f
{
  self = [super initWithConfiguration: conf
                                 name: n
                               values: val
                                 node: obj
                               filter: f];

  //get scale
  scaleConf = [configuration objectForKey: @"scale"];
  if (!scaleConf){
    NSLog (@"%s:%d: no 'scale' configuration for composition %@",
                        __FUNCTION__, __LINE__, configuration);
    return nil;
  }

  //get size
  sizeConf = [configuration objectForKey: @"size"];
  if (!sizeConf){
    NSLog (@"%s:%d: no 'size' configuration for composition %@",
                        __FUNCTION__, __LINE__, configuration);
    return nil;
  }

  //verify if we can transform size expression in a value
  if ([node expressionHasVariables: sizeConf]){
    NS_DURING
      [node evaluateWithValues: val withExpr: sizeConf];
    NS_HANDLER
      if ([[localException name] isEqualToString: @"TrivaGraphEvaluation"]){
        return nil;
      }else{
        [localException raise];
      }
    NS_ENDHANDLER
  }
  [self timeSelectionChanged];
  return self;
}

- (void) dealloc
{
  [super dealloc];
}

- (void) timeSelectionChanged
{
  double scale, size;
  scale = [scaleConf doubleValue];
  size = scale * [node evaluateWithValues: [node values] withExpr: sizeConf];
  [self setBoundingBox: NSMakeRect(0, 0, size, size)];
}

- (void) setBoundingBox: (NSRect) rect
{
  bb = rect;
}

- (void) drawLayout
{
  [[NSColor grayColor] set];
  [[NSBezierPath bezierPathWithRect: bb] stroke];
  NSSize s = [name sizeWithAttributes: nil];
}

- (NSRect) bb
{
  return bb;
}

- (NSString *) description
{
  double size = [node evaluateWithValues: [node values] withExpr: sizeConf];
  return [NSString stringWithFormat: @"%@: %@=%f", name, sizeConf, size];
}

- (BOOL) pointInside: (NSPoint)mPoint
{
  return NSPointInRect(mPoint, bb);
}
@end
