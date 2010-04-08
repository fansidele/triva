#include "SimGrid.h"
#include "SimGridDraw.h"

#define ROUTER_SIZE 0.1
#define MIN_HOST_SIZE 0.3
#define MIN_LINK_SIZE 0.01

SimGridDraw *draw = NULL;

@implementation SimGrid
- (id)initWithController:(PajeTraceController *)c
{
	self = [super initWithController: c];
	if (self != nil){
	}
	SimGridWindow *window = new SimGridWindow ((wxWindow*)NULL);
	window->Show();
	draw = window->getDraw();
	draw->setController ((id)self);

	platformCreated = NO;
	return self;
}

- (BOOL) checkForSimGridHierarchy: (id) type level: (int) level
{
	return YES;
	id et;
	NSEnumerator *en;
	BOOL simulation, route, host;
	en = [[self containedTypesForContainerType: type] objectEnumerator];
	while ((et = [en nextObject]) != nil){
		if (level == 0){
			if ([[et name] isEqualToString: @"Simulation"]){
				simulation = [self checkForSimGridHierarchy: et
							level: level+1];
			}else if ([[et name] isEqualToString: @"Route"]){
				route = YES;
			}
		}else if (level == 1){
			if ([[et name] isEqualToString: @"host"]){
				host = YES;
			}
		}
	}
	if (level == 0){
		return simulation && route;
	}else if(level == 1){
		return host;
	}else{
		return YES;
	}
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
                                         fromTime:[self startTime]
                                           toTime:[self endTime]
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

- (void) createPlatformGraph
{
	static int flag = 1;
	if (flag){
		gvc = gvContext();
		flag = 0;
	}
	//close before starting a new one
	if (platformGraph) agclose (platformGraph);

	platformGraph = agopen ((char *)"platformGraph", AGRAPHSTRICT);
	agnodeattr (platformGraph, (char*)"label", (char*)"");

	NSEnumerator *en;
	id host, link;
	id platformType = [self entityTypeWithName: @"platform"];
	id hostType = [self entityTypeWithName: @"host"];
	id linkType = [self entityTypeWithName: @"link"];
	id platformContainer = [self containerWithName: @"simgrid-platform" type: platformType];

	/* find min and max power */
	double maxPower = 0, minPower = FLT_MAX;
	en = [self enumeratorOfContainersTyped: hostType inContainer: platformContainer];
	while ((host = [en nextObject])){
		double power = [[host valueOfFieldNamed: @"Power"] doubleValue];
		if (power == 0) continue; //ignore router power
		if (power > maxPower) maxPower = power;
		if (power < minPower) minPower = power;
	}

	/* create graphviz nodes based on hosts, define size */
	en = [self enumeratorOfContainersTyped: hostType inContainer: platformContainer];
	while ((host = [en nextObject])){
		Agnode_t *n = agnode (platformGraph, (char *)[[host name] cString]);
		agsafeset (n, (char*)"shape", (char*)"rectangle",(char*)"rectangle");
		double power = [[host valueOfFieldNamed: @"Power"] doubleValue];
		//how to calculate its size based on power variable
		char sizestr[100];
		if (power == 0){ //define router size
			double size = ROUTER_SIZE;
			snprintf (sizestr, 100, "%g", size);
		}else{
			double size = MIN_HOST_SIZE + (power - minPower)/(maxPower - minPower);
			snprintf (sizestr, 100, "%g", size);
		}
		agsafeset (n, (char*)"width", sizestr, (char*)"1");
		agsafeset (n, (char*)"height", sizestr, (char*)"1");
	}

	/* find min and max bw */
	double maxBw = 0, minBw = FLT_MAX;
	en = [self enumeratorOfContainersTyped: linkType inContainer: platformContainer];
	while ((link = [en nextObject])){
		if ([[link name] isEqualToString: @"loopback"]) continue; //ignore loopback
		double bw = [[link valueOfFieldNamed: @"Bandwidth"] doubleValue];
		if (bw < minBw) minBw = bw;
		if (bw > maxBw) maxBw = bw;
	}

	/* create graphviz edges based on links, define size */
	en = [self enumeratorOfContainersTyped: linkType inContainer: platformContainer];
	while ((link = [en nextObject])){
		if ([[link name] isEqualToString: @"loopback"]) continue; //ignore loopback
		const char *src = [[link valueOfFieldNamed: @"SrcHost"] cString];
		const char *dst = [[link valueOfFieldNamed: @"DstHost"] cString];
		Agnode_t *s = agfindnode (platformGraph, (char*)src);
		Agnode_t *d = agfindnode (platformGraph, (char*)dst);
                Agedge_t *e = agedge (platformGraph, s, d);
		double bw = [[link valueOfFieldNamed: @"Bandwidth"] doubleValue];
		double size = MIN_LINK_SIZE + (bw - minBw)/(maxBw - minBw);
		char ns[100], nss[100];
		snprintf (ns, 100, "setlinewidth(%d)", (int)(5+10*size)); //just for calculating node separation
		snprintf (nss, 100, "%f", size);
		agsafeset (e, (char*)"style", (char*)ns, (char*)"setlinewidth(10)");
		agsafeset (e, (char*)"bandwidth", (char*)nss, (char*)nss);
	}
	gvLayout (gvc, platformGraph, (char*)"neato");
//	gvRenderFilename (gvc, platformGraph, (char*)"png", (char*)"out.png");
	platformCreated = YES;
	draw->definePlatform();
}

- (NSArray *) getHosts
{
	id platformType = [self entityTypeWithName: @"platform"];
	id hostType = [self entityTypeWithName: @"host"];
	id platformContainer = [self containerWithName: @"simgrid-platform" type: platformType];

	return [[self enumeratorOfContainersTyped: hostType inContainer: platformContainer] allObjects];
}

- (NSArray *) getLinks
{
	id platformType = [self entityTypeWithName: @"platform"];
	id linkType = [self entityTypeWithName: @"link"];
	id platformContainer = [self containerWithName: @"simgrid-platform" type: platformType];

	//removing loopback
	NSMutableArray *ret = [NSMutableArray array];
	NSEnumerator *en = [self enumeratorOfContainersTyped: linkType inContainer: platformContainer];
	id cont;
	while ((cont = [en nextObject])){
		if (![[cont name] isEqualToString: @"loopback"]){
			[ret addObject: cont];
		}
	}
	return ret;
}

- (NSPoint) getPositionForHost: (id) host
{
	if (![host isKindOfClass: [NSString class]]){
		host = [host name];
	}	
	Agnode_t *node = agfindnode (platformGraph, (char*)[host cString]);
	NSPoint ret;
	ret.x = ND_coord_i(node).x;
	ret.y = ND_coord_i(node).y;
	return ret;
}

/*
- (NSPoint) getInteractivePositionForHost: (id) host
{
	if (![host isKindOfClass: [NSString class]]){
		host = [host name];
	}	
	NSPoint ret;
	Agnode_t *node = agfindnode (platformGraph, (char*)[host cString]);
	char *x = agget (node, (char*)"xtriva");
	char *y = agget (node, (char*)"ytriva");
	if (x && y){
		ret.x = atof (x);
		ret.y = atof (y);
	}else{
		ret = [self getPositionForHost: host];
	}
	return ret;
}
*/

- (void) setPositionForHost: (id) host toPoint: (NSPoint) p
{
	if (![host isKindOfClass: [NSString class]]){
		host = [host name];
	}	
	Agnode_t *node = agfindnode (platformGraph, (char*)[host cString]);
	/* these coordinates are integer */
	ND_coord_i(node).x = p.x;
	ND_coord_i(node).y = p.y;
}

/*
- (void) setInteractivePositionForHost: (id) host toPoint: (NSPoint) p
{
	NSLog (@"setting %@ for %f,%f", host, p.x, p.y);
	Agnode_t *node = agnode (platformGraph, (char *)[[host name] cString]);

	char xstr[100], ystr[100];
	snprintf (xstr, 100, "%f", p.x);
	snprintf (ystr, 100, "%f", p.y);
	agsafeset (node, (char*)"xtriva", xstr, xstr);
	agsafeset (node, (char*)"ytriva", ystr, ystr);
}
*/

- (NSRect) getSizeForHost: (id) host
{
	if (![host isKindOfClass: [NSString class]]){
		host = [host name];
	}	
	Agnode_t *node = agfindnode (platformGraph, (char*)[host cString]);
	NSRect ret;
	ret.origin.x = ret.origin.y = 0;
	ret.size.width = atof(agget (node, (char*)"width")) * 96;  //96 should be somewhere
	ret.size.height = atof(agget (node, (char*)"height")) * 96;
	return ret;
}

- (float) getSizeForLink: (id) link
{
	char *ss = (char*)[[link valueOfFieldNamed: @"SrcHost"] cString];
	char *ds = (char*)[[link valueOfFieldNamed: @"DstHost"] cString];
	Agnode_t *s = agfindnode (platformGraph, ss);
	Agnode_t *d = agfindnode (platformGraph, ds);
	Agedge_t *e = agfindedge (platformGraph, s, d);
	if (e){
		return atof (agget (e, (char*)"bandwidth"));
	}else{
		return 0;
	}
}

- (NSRect) getBoundingBox
{
	NSRect ret;
	ret.origin.x = ret.origin.y = 0;
	ret.size.width = GD_bb(platformGraph).UR.x;
	ret.size.height = GD_bb(platformGraph).UR.y;
	return ret;
}

/* power & bandwidth utilization */
- (NSDictionary *) getUtilization: (NSString *) field
		     forContainer: (id) container
			withMaxValue: (NSString *) maxField
{
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	NSEnumerator *en, *en2;
	id type;
 	en = [[self containedTypesForContainerType: [container entityType]] objectEnumerator];
	double containerFieldValue = [[container valueOfFieldNamed: maxField] doubleValue];
	double accum_time = 0;
	NSMutableSet *intervals = [NSMutableSet set];
	while ((type = [en nextObject])){
		id what;
		en2 = [self enumeratorOfEntitiesTyped: type
                                                inContainer: container
                                                fromTime: [self selectionStartTime]
                                                toTime: [self selectionEndTime]
                                                minDuration: 0];
		double type_val = 0;
		while ((what = [en2 nextObject])){
			double start = [[[what startTime] description] doubleValue];
			double end = [[[what endTime] description] doubleValue];
			double value = [[what valueOfFieldNamed: field] doubleValue];
			if ((end-start)!=0){
				type_val += (value * (end-start));
			}
			NSString *interval = [NSString stringWithFormat: @"%f-%f", start, end];
			if (![intervals containsObject: interval]){
				accum_time += end-start;
				[intervals addObject: interval];
			}
		}
		if (type_val){
			[ret setObject: [NSString stringWithFormat: @"%f", type_val]
				forKey: type];
		}
	}
	en = [[self containedTypesForContainerType: [container entityType]] objectEnumerator];
	while ((type = [en nextObject])){
		if ([ret objectForKey: type]){
			double val = [[ret objectForKey: type] doubleValue];
			val = val/(containerFieldValue*accum_time);
			[ret setObject: [NSString stringWithFormat: @"%f", val]
				forKey: type];
		}
	}
	return ret;
}

/* power utilization */
- (NSDictionary *) getPowerUtilizationOfHost: (id) host
{
	NSDictionary *ret;
	ret = [self getUtilization: @"PowerUsed"
		      forContainer: host
		      withMaxValue: @"Power"];
	return ret;
}

/* bandwidth utilization */
- (NSDictionary *) getBandwidthUtilizationOfLink: (id) link
{
	NSDictionary *ret;
	ret = [self getUtilization: @"BandwidthUsed"
		      forContainer: link
		      withMaxValue: @"Bandwidth"];
	return ret;
}

- (void) timeSelectionChanged
{
	NSLog (@"%@ -> %@", [self selectionStartTime], [self selectionEndTime]);
	draw->Refresh();
	draw->Update();
}

- (void) hierarchyChanged
{
	[self createPlatformGraph];
	draw->Update();
}
@end
