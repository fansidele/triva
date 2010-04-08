/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "DrawView.h"

@implementation DrawView
- (BOOL) isFlipped
{
	return YES;
}

- (void) setFilter: (GraphView *)f
{
	filter = f;
}

- (NSColor *) getColor: (NSColor *)c withSaturation: (double) saturation
{
	if (![[c colorSpaceName] isEqualToString:
			@"NSCalibratedRGBColorSpace"]){
		NSLog (@"%s:%d Color provided is not part of the "
				"RGB color space.", __FUNCTION__, __LINE__);
		return nil;
	}
	float h, s, b, a;
	[c getHue: &h saturation: &s brightness: &b alpha: &a];

	NSColor *ret = [NSColor colorWithCalibratedHue: h
		saturation: saturation
		brightness: b
		alpha: a];
	return ret;
}

- (void) drawEdge: (TrivaGraphEdge *) edge
{
	NSColor *color;
	NSString *type;
	NSEnumerator *en;
	NSDictionary *types;

	NSRect tela = [self bounds];

	if (![edge drawable]) return;
	TrivaGraphNode *src = [edge source];
	TrivaGraphNode *dst = [edge destination];
	NSRect src_size = [filter sizeForNode: src];
	NSRect dst_size = [filter sizeForNode: dst];

	NSPoint src_pos = [filter positionForNode: src];
	NSPoint dst_pos = [filter positionForNode: dst];
	NSRect bb = [filter sizeForGraph];
	double bw = [filter sizeForEdge: edge].size.width;

	double x1, y1;
	double x2, y2;
	x1 = ((src_pos.x+(src_size.size.width)/2) / bb.size.width) * tela.size.width;
	y1 = ((src_pos.y+(src_size.size.height)/2) / bb.size.height) * tela.size.height;
	x2 = ((dst_pos.x+(dst_size.size.width)/2) / bb.size.width) * tela.size.width;
	y2 = ((dst_pos.y+(dst_size.size.height)/2) / bb.size.height) * tela.size.height;

	double distance = sqrt ((x2*x2 - 2*x2*x1 + x1*x1) + (y2*y2 - 2*y2*y1 + y1*y1) );
	double k = 10/distance; // remove 10% of the distance (5% on each endpoint)
	double x = x1 + k*x2 - k*x1;
	double y = y1 + k*y2 - k*y1;
	x1 = x;
	y1 = y;
	k = 1 - k;
	x = x1 + k*x2 - k*x1;
	y = y1 + k*y2 - k*y1;
	x2 = x;
	y2 = y;

	NSPoint o1, o2, o3, o4;

	double topx = -y2 + y1;
	double topy = x2 - x1;
	double norma_de_top = sqrt ( (topx*topx) + (topy*topy) );

	double bwe = bw/2; //split the value in 2 to calculate points

	o1.x = topx/norma_de_top*bwe + x2;
	o1.y = topy/norma_de_top*bwe + y2;

	o2.x = topx/norma_de_top*bwe + x1;
	o2.y = topy/norma_de_top*bwe + y1;

	o3.x = -topx/norma_de_top*bwe + x1;
	o3.y = -topy/norma_de_top*bwe + y1;

	o4.x = -topx/norma_de_top*bwe + x2;
	o4.y = -topy/norma_de_top*bwe + y2;

	[[NSColor lightGrayColor] set];
	NSBezierPath *b = [NSBezierPath bezierPath];
	[b moveToPoint: o1];
	[b lineToPoint: o2];
	[b lineToPoint: o3];
	[b lineToPoint: o4];
	[b lineToPoint: o1];
	[b stroke];

	double lucx = o3.x - o2.x;
	double lucy = o3.y - o2.y;
	double norma_de_luc = sqrt ( (lucx*lucx) + (lucy*lucy) );

	if ([edge separation] || [edge color]){
		types = [filter enumeratorOfValuesForEdge: edge];
		en = [types keyEnumerator];
		while ((type = [en nextObject])){
			[[filter colorForEntityType:
				[filter entityTypeWithName: type]] set];
			double value = [[types objectForKey: type] doubleValue];
			double e = bw * value;
			if (e){
				o3.x = lucx/norma_de_luc*e + o1.x;
				o3.y = lucy/norma_de_luc*e + o1.y;
				
				o4.x = lucx/norma_de_luc*e + o2.x;
				o4.y = lucy/norma_de_luc*e + o2.y;

				//desenha
				NSBezierPath *b = [NSBezierPath bezierPath];
				[b moveToPoint: o1];
				[b lineToPoint: o2];
				[b lineToPoint: o4];
				[b lineToPoint: o3];
				[b lineToPoint: o1];
				[b fill];

				o2 = o3;
				o1 = o4;
			}
		}
	}else if ([edge gradient]){
		NSColor *color;

		color = [filter colorForEntityType:
				[filter entityTypeWithName: [edge gradientType]]];
		double saturation = [edge gradientValue] /
			([edge gradientMax] - [edge gradientMin]);
		color = [self getColor: color withSaturation: saturation];
		[color set];

		NSBezierPath *b = [NSBezierPath bezierPath];
		[b moveToPoint: o1];
		[b lineToPoint: o2];
		[b lineToPoint: o3];
		[b lineToPoint: o4];
		[b lineToPoint: o1];
		[b fill];
	}
}

- (void) drawNode: (TrivaGraphNode *) node
{
	NSRect tela = [self bounds];

	NSString *type;
	NSEnumerator *en;
	NSDictionary *types;

	if (![node drawable]) return;
	NSPoint pos = [filter positionForNode: node];
	NSRect size = [filter sizeForNode: node];
	NSRect bb = [filter sizeForGraph];

	types = [filter enumeratorOfValuesForNode: node];
	en = [types keyEnumerator];

	NSRect nodeRect;
	nodeRect.origin.x = (pos.x / bb.size.width) * tela.size.width;
	nodeRect.origin.y = (pos.y / bb.size.height) * tela.size.height;
	nodeRect.size.width = size.size.width;// / bb.size.width ) *
//							tela.size.width;
	nodeRect.size.height = size.size.height;// / bb.size.height ) *
//							tela.size.height;

//	NSLog (@"%@", [node name]);
//	NSLog (@"\t%d %d %d", [node separation], [node color], [node gradient]);
//	NSLog (@"\t%@ %@", types, [node values]);
	if ([node separation] || [node color]){
		double accum_y = 0;
		while ((type = [en nextObject])){
			double value = [[types objectForKey: type] doubleValue];			if (value){

				//color
				[[filter colorForEntityType: 
					[filter entityTypeWithName: type]] set];

				NSRect vr;
				vr.size.width = nodeRect.size.width;
				vr.size.height = nodeRect.size.height * value;
				
				vr.origin.x = nodeRect.origin.x;
				vr.origin.y = nodeRect.origin.y + accum_y;

				NSRectFill(vr);
				[NSBezierPath strokeRect: vr];

//				NSLog (@"%@ (%f,%f) - (%f,%f)", type, vr.origin.x,vr.origin.y,vr.size.width,vr.size.height);
				accum_y += vr.size.height;	
			}
		}
	}else if ([node gradient]){
		
		NSColor *color;

		color = [filter colorForEntityType:
				[filter entityTypeWithName: [node gradientType]]];
		double saturation = [node gradientValue] /
			([node gradientMax] - [node gradientMin]);
		color = [self getColor: color withSaturation: saturation];
		[color set];

		NSRect vr;
		vr.size.width = nodeRect.size.width;
		vr.size.height = nodeRect.size.height;
		
		vr.origin.x = nodeRect.origin.x;
		vr.origin.y = nodeRect.origin.y;
		NSRectFill(vr);
		[NSBezierPath strokeRect: vr];
	}
	//draw node border
	[[NSColor lightGrayColor] set];
	[NSBezierPath strokeRect: nodeRect];
}

- (void)drawRect:(NSRect)frame
{
	NSEnumerator *en;
	TrivaGraphNode *node;
	TrivaGraphEdge *edge;

	NSRect tela = [self bounds];
	[[NSColor whiteColor] set];
	NSRectFill(tela);
	[NSBezierPath strokeRect: tela];
	

	en = [filter enumeratorOfNodes];
	while ((node = [en nextObject])){
		[self drawNode: node];
	}

	en = [filter enumeratorOfEdges];
	while ((edge = [en nextObject])){
		[self drawEdge: edge];
	}
}
@end
