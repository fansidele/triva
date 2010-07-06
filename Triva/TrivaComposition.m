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
#include "TrivaComposition.h"
#include "NSPointFunctions.h"
#include <float.h>
#include <limits.h>

@implementation TrivaComposition
- (id) init
{
  self = [super init];
  if (self){
    needSpace = YES; //by default everybody needs space inside node to be drawn
  }
  return self;
}

+ (id) compositionWithConfiguration: (NSDictionary*) conf
                          forObject: (TrivaGraphNode*) obj
                         withValues: (NSDictionary*) timeSliceValues
                        andProvider: (TrivaFilter*) prov
{
  if (![conf isKindOfClass: [NSDictionary class]]) {
    NSLog (@"%s:%d: configuration %@ is not a dictionary",
                        __FUNCTION__, __LINE__, conf);
    return nil;
  }

  if (![conf count]) {
    NSLog (@"%s:%d: configuration %@ is empty",
                        __FUNCTION__, __LINE__, conf);
    return nil;
  }

  NSString *type = [conf objectForKey: @"type"];
  if (!type){
    NSLog (@"%s:%d: configuration %@ has no type",
                        __FUNCTION__, __LINE__, conf);
    return nil;
  }

  if ([type isEqualToString: @"separation"]){
    return [[TrivaSeparation alloc] initWithConfiguration: conf
                                                forObject: obj
                                               withValues: timeSliceValues
                                              andProvider: prov];
  }else if ([type isEqualToString: @"gradient"]){
    return [[TrivaGradient alloc] initWithConfiguration: conf
                                              forObject: obj
                                             withValues: timeSliceValues
                                            andProvider: prov];
  }else if ([type isEqualToString: @"convergence"]){
    return [[TrivaConvergence alloc] initWithConfiguration: conf
                                                 forObject: obj
                                                withValues: timeSliceValues
                                               andProvider: prov];
  }else if ([type isEqualToString: @"color"]){
    return [[TrivaColor alloc] initWithConfiguration: conf
                                           forObject: obj
                                          withValues: timeSliceValues
                                         andProvider: prov];
  }else if ([type isEqualToString: @"swarm"]){
    return [[TrivaSwarm alloc] initWithConfiguration: conf
                                           forObject: obj
                                          withValues: timeSliceValues
                                         andProvider: prov];
  }else if ([type isEqualToString: @"plot"]){
    return [[TrivaPlot alloc] initWithConfiguration: conf
                                           forObject: obj
                                          withValues: timeSliceValues
                                         andProvider: prov];
  }else{
    NSLog (@"%s:%d: type '%@' of configuration %@ is unknown",
                        __FUNCTION__, __LINE__, type, conf);
    return nil;
  }
}

- (id) initWithConfiguration: (NSDictionary*) conf
                   forObject: (TrivaGraphNode*)obj
                  withValues: (NSDictionary*) timeSliceValues
                 andProvider: (TrivaFilter*) prov
{
  return nil;
}

- (BOOL) needSpace
{
  return needSpace;
}
@end

@implementation TrivaSeparation
- (id) initWithConfiguration: (NSDictionary*) conf
                   forObject: (TrivaGraphNode*)obj
                  withValues: (NSDictionary*) timeSliceValues
                 andProvider: (TrivaFilter*) prov
{
  self = [self initWithFilter: prov];

/*
  //TODO: what 'scale' local or global means for separation?
  //get scale for this composition
  TrivaScale scale;
  NSString *scaleconf = [conf objectForKey: @"scale"];
  if ([scaleconf isEqualToString: @"global"]){
    scale = Global;
  }else if ([scaleconf isEqualToString: @"local"]){
    scale = Local;
  }else{
    scale = Global;
  }
*/

  //saving node
  node = obj;

  //we need the size
  NSString *sizeconf = [conf objectForKey: @"size"];
  double size = 0;
  if (!sizeconf) {
    //no size specified
    NSLog (@"%s:%d: no 'size' configuration for composition %@",
                        __FUNCTION__, __LINE__, conf);
    return nil;
  }
  size = [prov evaluateWithValues: timeSliceValues withExpr: sizeconf];
  if (size < 0){
    //size could not be defined
    NSLog (@"%s:%d: the value of 'size' for composition %@ is negative or "
      "could not be defined",
                        __FUNCTION__, __LINE__, conf);
    return nil;
  }

  //get values
  NSEnumerator *en2 = [[conf objectForKey: @"values"] objectEnumerator];
  id var;
  double sum = 0;
  while ((var = [en2 nextObject])){
    double val = [prov evaluateWithValues: timeSliceValues withExpr: var];
    if (val > 0){
      [values setObject: [NSNumber numberWithDouble: val/size]
          forKey: var];
    }
    sum += val;
  }
  if (sum > 1){
    overflow = sum - 1;
  }else{
    overflow = 0;
  }
  if ([values count] == 0){
    needSpace = NO;
  }
  return self;
}

- (id) init
{
  self = [super init];
  bb = NSZeroRect;
  overflow = 0;
  values = [[NSMutableDictionary alloc] init];
  return self;
}

- (id) initWithFilter: (id) f
{
  self = [self init];
  [self setFilter: f];
  return self;
}

- (void) setFilter: (id) f
{
  filter = f;
}

- (void) dealloc
{
  [values release];
  [super dealloc];
}

- (NSDictionary*) values
{
  return values;
}

- (double) overflow
{
  return overflow;
}

- (void) refreshWithinRect: (NSRect) rect
{
  bb = rect;
}

- (BOOL) draw
{
  NSEnumerator *en = [values keyEnumerator];
  NSString *type;
  double accum_y = 0;

  NSMutableString *str = [NSMutableString string];

  while ((type = [en nextObject])){
    double value = [[values objectForKey: type] doubleValue];

    [[filter colorForEntityType:
      [filter entityTypeWithName: type]] set];

    NSRect vr;
    vr.size.width = bb.size.width;
    vr.size.height = bb.size.height * value;
    vr.origin.x = bb.origin.x;
    vr.origin.y = bb.origin.y + accum_y;

    NSRectFill(vr);
    [NSBezierPath strokeRect: vr];

    [str appendString: [NSString stringWithFormat: @"%@ = %g\n", type,
                             value*100]]; //value is always between 0 and 1 here
    accum_y += vr.size.height;
  }

  if ([node highlighted]){
    NSMutableDictionary *attr = [[NSMutableDictionary alloc] init];
    [attr setValue:[NSFont userFontOfSize: 10] forKey: NSFontAttributeName];
    [str drawAtPoint: NSAddPoints ([node bb].origin,
                                   NSMakePoint([node bb].size.width,
                                               [node bb].size.height))
      withAttributes: attr];
    [attr release];
  }

  return YES;
}

- (NSRect) bb
{
  return bb;
}
@end

@implementation TrivaGradient
- (id) initWithConfiguration: (NSDictionary*) conf
                   forObject: (TrivaGraphNode*)obj
                  withValues: (NSDictionary*) timeSliceValues
                 andProvider: (TrivaFilter*) prov
{
  self = [super initWithFilter: prov];

  //get scale for this composition
  TrivaScale scale;
  NSString *scaleconf = [conf objectForKey: @"scale"];
  if ([scaleconf isEqualToString: @"global"]){
    scale = Global;
  }else if ([scaleconf isEqualToString: @"local"]){
    scale = Local;
  }else{
    scale = Global;
  }

  //get values
  NSEnumerator *en2 = [[conf objectForKey: @"values"] objectEnumerator];
  id var;
  while ((var = [en2 nextObject])){
    double val = [prov evaluateWithValues: timeSliceValues withExpr: var];
    double mi, ma;
    [prov defineMax: &ma
                         andMin: &mi
                      withScale: scale
                   fromVariable: var
                       ofObject: [obj name]
                       withType: [(TrivaGraphNode*)obj type]];
    [self setGradientType: var withValue: val withMax: ma withMin: mi];
  }
  return self;
}

- (id) init
{
  self = [super init];
  min = [[NSMutableDictionary alloc] init];
  max = [[NSMutableDictionary alloc] init];
  return self;
}

- (void) dealloc
{
  [min release];
  [max release];
  [super dealloc];
}

- (void) setGradientType: (NSString *) type withValue: (double) val
                withMax: (double) ma withMin: (double) mi
{
  [values setObject: [NSNumber numberWithDouble: val]
       forKey: type];
  [min setObject: [NSNumber numberWithDouble: mi]
    forKey: type];
  [max setObject: [NSNumber numberWithDouble: ma]
    forKey: type];
}

- (NSDictionary *) min
{
  return min;
}

- (NSDictionary *) max
{
  return max;
}

- (void) refreshWithinRect: (NSRect) rect
{
  //calculate bb based on number of gradients
  //knowing that each gradient is a small square
  bb = rect;
}

- (BOOL) draw
{
  int count = [values count];
  NSEnumerator *en = [values keyEnumerator];
  NSString *type;
  double accum_y = 0;
  while ((type = [en nextObject])){
    double value = [[values objectForKey: type] doubleValue];
    double mi = [[min objectForKey: type] doubleValue];
    double ma = [[max objectForKey: type] doubleValue];
    double saturation = (value - mi) / (ma - mi);

    NSColor *color;
    color = [filter colorForEntityType:
        [filter entityTypeWithName: type]];
    color = [filter getColor: color withSaturation: saturation];
    [color set];

    NSRect vr;
    vr.size.width = bb.size.width;
    vr.size.height = bb.size.height * 1/count;
    vr.origin.x = bb.origin.x;
    vr.origin.y = bb.origin.y + accum_y;

    NSRectFill(vr);
    [NSBezierPath strokeRect: vr];

    [[NSColor blackColor] set];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint: NSMakePoint (vr.origin.x,
                                                vr.origin.y + vr.size.height * (1 - saturation))];
    [path lineToPoint: NSMakePoint (vr.origin.x + vr.size.width,
                                                vr.origin.y + vr.size.height * (1 - saturation))];
    [path stroke];

    accum_y += vr.size.height;
  }
  return YES;
}
@end

@implementation TrivaBar
  //not implemented yet
@end

@implementation TrivaConvergence
- (void) defineMax: (double*)ma andMin: (double*)mi fromVariable: (NSString*)var
    ofObject: (NSString*)name withType: (NSString*)type
{
  //define max and min taking into account that this is a convergence composition
  NSDate *start = [filter selectionStartTime]; //from the beggining of the time window
  NSDate *end = [filter endTime]; //to the end

  //prepare
  PajeEntityType *varType = [filter entityTypeWithName: var];
  PajeEntityType *containerType = [filter entityTypeWithName: type];
  PajeContainer *container = [filter containerWithName: name type: containerType];
  *ma = 0;
  *mi = FLT_MAX;
  //do it
  NSEnumerator *en = [filter enumeratorOfEntitiesTyped: varType
                                                 inContainer: container
                                                    fromTime: start
                                                      toTime: end
                                                 minDuration: 0];
  id ent;
  while ((ent = [en nextObject])){
    double val = [[ent value] doubleValue];
    if (val > *ma) *ma = val;
    if (val < *mi) *mi = val;
  }
}

- (id) initWithConfiguration: (NSDictionary*) conf
                   forObject: (TrivaGraphNode*)obj
                  withValues: (NSDictionary*) timeSliceValues
                 andProvider: (TrivaFilter*) prov
{
  self = [super initWithFilter: prov];

  //get values
  NSEnumerator *en2 = [[conf objectForKey: @"values"] objectEnumerator];
  id var;
  while ((var = [en2 nextObject])){
    double val = [prov evaluateWithValues: timeSliceValues withExpr: var];
    double mi, ma;
    [self defineMax: &ma
                         andMin: &mi
                   fromVariable: var
                       ofObject: [obj name]
                       withType: [(TrivaGraphNode*)obj type]];
    [self setGradientType: var withValue: val withMax: ma withMin: mi];
  }
  if ([values count] == 0){
    needSpace = NO;
  }
  return self;
}
@end

@implementation TrivaColor
- (id) initWithConfiguration: (NSDictionary*) conf
                   forObject: (TrivaGraphNode*)obj
                  withValues: (NSDictionary*) timeSliceValues
                 andProvider: (TrivaFilter*) prov
{
  self = [super initWithFilter: prov];

  //get values
  NSEnumerator *en2 = [[conf objectForKey: @"values"] objectEnumerator];
  id var;
  while ((var = [en2 nextObject])){
    double val = [prov evaluateWithValues: timeSliceValues withExpr: var];
    if (val){
      [values setObject: [NSNumber numberWithDouble: 1]
          forKey: var];
    }
  }
  if ([values count] == 0){
    needSpace = NO;
  }
  return self;
}
@end

@implementation TrivaSwarm
- (id) initWithConfiguration: (NSDictionary*) conf
              forObject: (TrivaGraphNode*) obj
              withValues: (NSDictionary*) timeSliceValues
              andProvider: (TrivaFilter*) prov
{
  self = [self init];

  //swarm objects are drawn around the hive
  needSpace = NO;

  //allocate array for objects
  objects = [[NSMutableArray alloc] init];
  objectsColors = [[NSMutableDictionary alloc] init];

  //saving node
  node = obj;

  //we need the filter
  NSString *filter = [conf objectForKey: @"filter"];
  if (!filter) {
    //no filter specified
    NSLog (@"%s:%d: no 'filter' configuration for composition %@",
                        __FUNCTION__, __LINE__, conf);
    return nil;
  }
  //we need the color
  NSSet *colors = [NSSet setWithArray: [conf objectForKey: @"color"]];
  if (!colors) {
    //no color specified
    NSLog (@"%s:%d: no 'color' configuration for composition %@",
                        __FUNCTION__, __LINE__, conf);
    return nil;
  }

  //getting the timeslice-node for my object
  TimeSliceTree *t = (TimeSliceTree*)[[prov timeSliceTree] searchChildByName: [obj name]];

  //check among its children if they were present in the swarm (filter variable indicates presence)
  NSEnumerator *en = [[t children] objectEnumerator];
  TimeSliceTree *child;
  while ((child = [en nextObject])){
    //if value is != 0, child is present in the swarm
    //checking if it should be present
    if ([[[child timeSliceValues] objectForKey: filter] doubleValue]){
      [objects addObject: [child name]];

      //finding color
      NSEnumerator *values = [[child timeSliceValues] keyEnumerator];
      id category;
      while ((category = [values nextObject])){
        if ([[[child timeSliceValues] objectForKey: category] doubleValue]>0 &&
                                          [colors containsObject: category]){
            [objectsColors setObject: [[child timeSliceColors]
                                          objectForKey: category]
                              forKey: [child name]];
        }
      }
    }
  }
  return self;
}

- (void) refreshWithinRect: (NSRect) rect
{
  bb = rect;
}

- (BOOL) draw
{
  int count = [objects count];
  if (!count) return NO;
  int i;
  double step = 20;//count;
  double s = 0;
  for (i = 0; i < count; i++){
    [[objectsColors objectForKey: [objects objectAtIndex: i]] set];
    NSBezierPath *path = [NSBezierPath bezierPath];
    //position of the dot
    [path appendBezierPathWithArcWithCenter:
                          NSMakePoint(bb.origin.x+bb.size.width/2,
                                      bb.origin.y+bb.size.height/2)
                                     radius: bb.size.width/2+bb.size.width*.3
                                 startAngle: s endAngle: s];
    //drawing the dot
    [path appendBezierPathWithArcWithCenter: [path currentPoint]
                                     radius: 3
                                 startAngle: 0
                                   endAngle: 360];
    [path fill];

    if ([node highlighted]){
      [[objects objectAtIndex: i] drawAtPoint: [path currentPoint]
                               withAttributes: nil];
    }
    s += step;
  }
  return YES;
}

- (void) dealloc
{
  [objects release];
  [objectsColors release];
  [super dealloc];
}
@end

#define PLOT_WIDTH 42
#define PLOT_HEIGHT 30

@implementation TrivaPlot
- (id) initWithConfiguration: (NSDictionary*) conf
              forObject: (TrivaGraphNode*) obj
              withValues: (NSDictionary*) timeSliceValues
              andProvider: (TrivaFilter*) prov
{
  self = [super init];
  provider = prov;

  //saving node
  node = obj;

  //plot is not drawn inside the visual object
  needSpace = NO;

  //get only the first value (notice the "break" inside the while)
  NSEnumerator *en2 = [[conf objectForKey: @"values"] objectEnumerator];
  id var;
  while ((var = [en2 nextObject])){
    break;
  }
  if (!var){
    return nil;
  }

  //consider only the time slice
  NSDate *start = [provider selectionStartTime];
  NSDate *end = [provider selectionEndTime];

  tmin = [start timeIntervalSinceReferenceDate];
  tmax = [end timeIntervalSinceReferenceDate];
  sliceSize = tmax - tmin;

  //transform to paje terminology
  PajeEntityType *varType = [provider entityTypeWithName: var];
  PajeEntityType *containerType = [provider entityTypeWithName: [obj type]];
  PajeContainer *container = [provider containerWithName: [obj name]
                                                type: containerType];

  //get max min value for the type
  vmax = [provider maxValueForEntityType: varType];
  vmin = [provider minValueForEntityType: varType];
  valueSize = vmax - vmin;

  //get the data
  NSEnumerator *en = [provider enumeratorOfEntitiesTyped: varType
                                           inContainer: container
                                              fromTime: start
                                                toTime: end
                                           minDuration: 0];
  objects = [en allObjects];
  [objects retain];
/*
  NSLog (@"%@ (%@) - %d", var, [obj name], [[en allObjects] count]);
  return self;
  id ent;
  while ((ent = [en nextObject])){
    double val = [[ent value] doubleValue];
    NSLog (@"%@ -> %f", var, val);
  }
*/
  return self;
}

- (void) refreshWithinRect: (NSRect) rect
{
  bb = NSMakeRect (rect.origin.x + rect.size.width + 1,
                   rect.origin.y,
                   PLOT_WIDTH,
                   PLOT_HEIGHT);
}

- (BOOL) draw
{
  //update tmin, tmax
  NSDate *start = [provider selectionStartTime];
  NSDate *end = [provider selectionEndTime];
  tmin = [start timeIntervalSinceReferenceDate];
  tmax = [end timeIntervalSinceReferenceDate];

  if (1||[node highlighted]){
    //draw a rectangle
    [[NSColor blackColor] set];
    [NSBezierPath strokeRect: bb];

    [[NSColor grayColor] set];
    //draw the points in the inverse sense (paje gives us the objects that way
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint: NSMakePoint (PLOT_WIDTH,0)];
    id ent;
    NSEnumerator *en = [objects objectEnumerator];
    double lastts = 0;
    while ((ent = [en nextObject])){
      double ts = [[ent startTime] timeIntervalSinceReferenceDate];
      if (ts < tmin) ts = tmin;
      ts = (ts - tmin) / sliceSize * PLOT_WIDTH;
      double te = [[ent endTime] timeIntervalSinceReferenceDate];
      if (te > tmax) te = tmax;
      te = (te - tmin) / sliceSize * PLOT_WIDTH;

      if (te == ts) continue;
      double value = [[ent value] doubleValue] / valueSize * PLOT_HEIGHT;
      [path lineToPoint: NSMakePoint (te, value)];
      [path lineToPoint: NSMakePoint (ts, value)];
      lastts = ts;
    }
    [path lineToPoint: NSMakePoint (lastts,0)];
    [path lineToPoint: NSMakePoint (PLOT_WIDTH,0)];

    NSAffineTransform *t = [NSAffineTransform transform];
    [t translateXBy: bb.origin.x yBy: bb.origin.y];
    [t concat];
    [path stroke];
    [t invert];
    [t concat];
  }
  return YES;
}

- (void) dealloc
{
  [objects release];
  [super dealloc];
}
@end
