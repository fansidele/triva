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
#include "Tupi.h"
#include "TupiFunctions.h"

@implementation Tupi
- (id) init
{
  self = [super init];
  connectedNodes = [[NSMutableSet alloc] init];
  highlight = NO;
  name = nil;
  type = nil;
  tupiType = TUPI_UNDEF;
  bb = NSZeroRect;
  compositions = [[NSMutableDictionary alloc] init];
  transformAngle = 0;
  transformPoint = NSMakePoint(0,0);
  return self;
}

- (id) initWithConfiguration: (NSDictionary*) dict
{
  self = [self init];
  NSString *nodetype = [dict objectForKey: @"type"];
  if (nodetype && [nodetype isEqualToString: @"edge"]){
    tupiType = TUPI_EDGE;
  }else{
    tupiType = TUPI_NODE;
  }
  return self;
}

- (void) dealloc
{
  [connectedNodes release];
  [compositions release];
  [super dealloc];
}

- (void) setName: (NSString *) n
{
  if (name){
    [name release];
  }
  name = n;
  [name retain];
}

- (void) setType: (NSString *) n
{
  if (type){
    [type release];
  }
  type = n;
  [type retain];
}

- (void) setTupiType: (TupiType) n
{
  tupiType = n;
}

- (void) setHighlight: (BOOL) high
{
  highlight = high;
  //update compositions
  NSEnumerator *en = [compositions objectEnumerator];
  id comp;
  while ((comp = [en nextObject])){
    [comp setHighlight: high];
  }
}

- (void) setBoundingBox: (NSRect) b
{
  bb = b;

  //update bounding boxes of compositions
  NSEnumerator *en = [compositions objectEnumerator];
  id comp;
  while ((comp = [en nextObject])){
    [comp layoutWithRect: bb];
  }
}

- (void) connectToNode: (Tupi*) n
{
  [connectedNodes addObject: n];
}

- (BOOL) pointInside: (NSPoint) p
{
  NSBezierPath *path = [NSBezierPath bezierPath];
  [path appendBezierPathWithRect: bb];
  NSAffineTransform *transform = [self transform];
  [path transformUsingAffineTransform: transform];
  BOOL ret = [path containsPoint: p];
  if (ret) {
    //update compositions
    NSEnumerator *en = [compositions objectEnumerator];
    id comp;
    while ((comp = [en nextObject])){
      [comp pointInside: p];
    }
  }
  return ret;
}

- (NSString *) name
{
  return name;
}

- (NSString *) type
{
  return type;
}

- (TupiType) tupiType
{
  return tupiType;
}

- (NSRect) boundingBox
{
  return bb;
}

- (NSSet*) connectedNodes
{
  return connectedNodes;
}

- (NSAffineTransform*) transform
{
  NSAffineTransform *transform = [NSAffineTransform transform];
  [transform translateXBy: transformPoint.x yBy: transformPoint.y];
  [transform rotateByDegrees: transformAngle];
  return transform;
}

- (NSPoint) centerPoint
{
  return NSMakePoint (bb.origin.x + bb.size.width/2,
                      bb.origin.y + bb.size.height/2);
}

- (NSString *) description
{
  return name;
}

- (NSUInteger)hash
{
  return [name hash];
}

- (BOOL)isEqual:(id)anObject
{
  return [name isEqual: [anObject name]];
}

/*
- (NSPoint) connectionPointTo: (Tupi *) node
{
  NSPoint center = [self centerPoint];
  return center;
  if (drawingType == TRIVA_NODE){
    return center;
  }else{
    NSPoint difNormalized = LMSNormalizePoint (NSSubtractPoints (center, [node centerPoint]));
    NSPoint ret = NSAddPoints (center, LMSMultiplyPoint(difNormalized, .3));
    return ret;
  }
}
*/

- (void) drawLayout
{
/*
  NSAffineTransform *transform = [NSAffineTransform transform];
  if (drawingType == TRIVA_EDGE){
    int n = [connectedNodes count];
    if (n == 2){ //normal link
      Tupi *node1 = [[connectedNodes allObjects] objectAtIndex: 0];
      Tupi *node2 = [[connectedNodes allObjects] objectAtIndex: 1];
      NSPoint srcPoint = [node1 centerPoint];//To: self];
      NSPoint dstPoint = [node2 centerPoint];//To: self];
      double distance = LMSDistanceBetweenPoints (srcPoint, dstPoint);
    }
  }

  if (drawingType == TRIVA_EDGE){
    NSEnumerator *en = [connectedNodes objectEnumerator];
    Tupi *connectedNode;
    while ((connectedNode = [en nextObject])){
      [[NSColor grayColor] set];
      NSBezierPath *path = [NSBezierPath bezierPath];
      NSPoint center = [self centerPoint];
      NSPoint hisCenter = [connectedNode centerPoint];


        NSPoint oNorm = LMSNormalizePoint (NSSubtractPoints(center, hisCenter));
        NSPoint oNormPerp = NSMakePoint (-oNorm.y, oNorm.x);

        double distance = LMSDistanceBetweenPoints (center, hisCenter);
        NSPoint middle = NSSubtractPoints (hisCenter, LMSMultiplyPoint(oNorm,1));

      
      [path moveToPoint: center];
      [path lineToPoint: middle];//[connectedNode connectionPointTo: self]];
      [path stroke];
    }
  }

*/

  Tupi *connected;
  NSEnumerator *en1 = [connectedNodes objectEnumerator];
  while ((connected = [en1 nextObject])){
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint: [self centerPoint]];
    [path lineToPoint: [connected centerPoint]];
    [path stroke];
  }

  NSAffineTransform *transform;
  transform = [self transform];
  [transform concat];

  //draw my components
  NSEnumerator *en = [compositions objectEnumerator];
  id comp;
  while ((comp = [en nextObject])){
    [comp drawLayout];
  }
  
  //draw myself
  NSBezierPath *border = [NSBezierPath bezierPathWithRect: bb];
  if (highlight){
    NSString *str = [NSString stringWithFormat: @"%@ - %f", name, size];
    [str drawAtPoint: NSMakePoint (bb.origin.x,
                                   bb.origin.y+bb.size.height)
       withAttributes: nil];
  }
  [[NSColor grayColor] set];
  [border stroke];

  [transform invert];
  [transform concat];
}

- (void) layoutWith: (NSDictionary*)conf values: (NSDictionary*)values minValues: (NSDictionary *) min maxValues: (NSDictionary*) max colors: (NSDictionary*) colors
{
  NSString *sizeconf = [conf objectForKey: @"size"];
  double screensize;
  if ([self expressionHasVariables: sizeconf]){
    double minVal = [self evaluateWithValues: min withExpr: sizeconf];
    double maxVal = [self evaluateWithValues: max withExpr: sizeconf];
    size = [self evaluateWithValues: values withExpr: sizeconf];
    if ((maxVal - minVal) != 0) {
      screensize = MAX_SIZE * (size) / (maxVal - minVal);
    }else{
      screensize = MAX_SIZE * (size) / (maxVal);
    }
  }else{
    screensize = [sizeconf doubleValue];
  }
  bb.size.width = screensize;
  bb.size.height = screensize;

  //compositions
  NSMutableArray *ar = [NSMutableArray arrayWithArray: [conf allKeys]];
  NSEnumerator *en = [ar objectEnumerator];
  NSString *compositionName;
  while ((compositionName = [en nextObject])){
    NSDictionary *compconf = [conf objectForKey: compositionName];
    if (![compconf isKindOfClass: [NSDictionary class]]) continue;
    if (![compconf count]) continue;
    
    //check if composition already exist
    TupiComposition *comp = [compositions objectForKey: compositionName];
    if (!comp){
      comp = [TupiComposition compositionWithConfiguration: compconf
                                                  withName: compositionName
                                                withValues: values
                                                withColors: colors
                                                  withNode: self];
      [compositions setObject: comp forKey: compositionName];
    }
    [comp layoutWithRect: bb];
    [comp layoutWithValues: values];
  }
}


- (BOOL) expressionHasVariables: (NSString*) expr
{
  BOOL ret;
  char **expr_names;
  int count;
  void *f = evaluator_create ((char*)[expr cString]);
  evaluator_get_variables (f, &expr_names, &count);
  if (count == 0){
    ret = NO;
  }else{
    ret = YES;
  }
  evaluator_destroy (f);
  return ret;
}

- (double) evaluateWithValues: (NSDictionary *) values
    withExpr: (NSString *) expr
{
  char **expr_names;
  double *expr_values, ret;
  int count, i;
  void *f = evaluator_create ((char*)[expr cString]);
  evaluator_get_variables (f, &expr_names, &count);
  if (count == 0){
    //no variables detected, return doubleValue
    return [expr doubleValue];
  }else{
    //ok, we have some variables to be defined
    expr_values = (double*)malloc (count * sizeof(double));
    for (i = 0; i < count; i++){
      NSString *var = [NSString stringWithFormat: @"%s", expr_names[i]];
      NSString *val = [values objectForKey: var];
      if (val){
        expr_values[i] = [val doubleValue];
      }else{
        static BOOL appeared = NO;
        if (!appeared){
          NSLog (@"%s:%d Expression (%@) has variables that are "
            "not present in the aggregated tree (%@). Considering "
            "that their values is zero. This message appears only once.",
            __FUNCTION__, __LINE__, expr, values);
          appeared = YES;
        }
        expr_values[i] = 0;

      }
    }
    ret = evaluator_evaluate (f, count, expr_names, expr_values);
    evaluator_destroy (f);
    free(expr_values);
  }
  return ret;
}
@end
