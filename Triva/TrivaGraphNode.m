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
#include "TrivaGraphNode.h"
#include <float.h>
#include <limits.h>

@implementation TrivaComposition
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

		accum_y += vr.size.height;
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
	return self;
}
@end

@implementation TrivaGraphNode
- (id) init
{
	self = [super init];
	bb = NSZeroRect;
	compositions = [[NSMutableArray alloc] init];
	return self;
}

- (void) setType: (NSString *) n
{
	if (type){
		[type release];
	}
	type = n;
	[type retain];
}

- (NSString *) type
{
	return type;
}

- (void) setBoundingBox: (NSRect) b
{
	bb = b;
}

- (NSRect) bb
{
	return bb;
}

- (NSRect) screenbb
{
	return screenbb;
}

- (void) setDrawable: (BOOL) v
{
	drawable = v;
}

- (BOOL) drawable
{
	return drawable;
}

- (void) dealloc
{
	[compositions release];
	[super dealloc];
}

- (void) refresh
{
	int count = [compositions count];
	NSEnumerator *en = [compositions objectEnumerator];
	id comp;
	double accum_x = 0;
	while ((comp = [en nextObject])){
		NSRect rect = NSMakeRect (screenbb.origin.x + accum_x,
					screenbb.origin.y,
					screenbb.size.width/count,
					screenbb.size.height);
		[comp refreshWithinRect: rect];
		accum_x += screenbb.size.width/count;
	}
}

- (BOOL) draw
{
	//draw my components
	NSEnumerator *en = [compositions objectEnumerator];
	id comp;
	while ((comp = [en nextObject])){
		[comp draw];
	}

	//draw myself
	[[NSColor lightGrayColor] set];
	[NSBezierPath strokeRect: screenbb];

	//draw my name
	[name drawAtPoint: NSMakePoint (screenbb.origin.x + screenbb.size.width/2,
					screenbb.origin.y + screenbb.size.height/2)
		 withAttributes: nil];
  return YES;
}

- (void) addComposition: (TrivaComposition*)comp
{
	[compositions addObject: comp];
}

- (void) removeCompositions
{
	[compositions removeAllObjects];
}

- (void) convertFrom: (NSRect) this to: (NSRect) screen
{
	screenbb = NSMakeRect (
		(bb.origin.x-this.origin.x) / this.size.width * screen.size.width,
		(bb.origin.y-this.origin.y) / this.size.height * screen.size.height,
		bb.size.width / this.size.width * screen.size.width,
		bb.size.height / this.size.width * screen.size.width);
}
@end
