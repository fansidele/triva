#include "DrawManager.h"

extern wxString NSSTRINGtoWXSTRING (NSString *ns);

void DrawManager::applicationGraphRecursiveDraw (id entity,
			Position *position,
			Ogre::SceneNode *node)
{
	/* finding its position */
	int x = [position positionXForNode: [entity name]];
	int y = [position positionYForNode: [entity name]];

	if ([viewController mustDrawContainer: entity]){
		this->drawOneContainer (entity, node, x, y);
	}

	/* recursive */
	NSEnumerator *en = [[viewController containedTypesForContainerType:[viewController entityTypeForEntity:entity]] objectEnumerator];
	PajeEntityType *et;
	while ((et = [en nextObject]) != nil) {
		if ([viewController isContainerEntityType:et]) {
			NSEnumerator *en2;
			PajeContainer *sub;
			en2 = [viewController enumeratorOfContainersTyped:et inContainer:entity];
			while ((sub = [en2 nextObject]) != nil) {
				this->applicationGraphRecursiveDraw((id)sub, 
					position, node);
			}
		}
	}
}

void DrawManager::applicationGraphDraw (Position *position)
{
	id instance = [viewController rootInstance];
	this->applicationGraphRecursiveDraw (instance, position,
			containerPosition);
}
