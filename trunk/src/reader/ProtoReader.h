#ifndef __PROTOREADER_H
#define __PROTOREADER_H
#include <Foundation/Foundation.h>
#include <GenericEvent/GEvent.h> /* for the GEvent protocol */
#include <DIMVisual/Protocols.h> /* for the FileReader protocol */
#include <DIMVisual/IntegratorLib.h>
#include "general/ProtoComponent.h"
#include "general/BundleCenter.h"

/*!
 * ProtoReader: A more elaborate class description.
 */
@interface ProtoReader  : ProtoComponent
{
	/*! pointer to the integrator of DIMVisual */
	IntegratorLib *integrator;
	/*! boolean to say if it has more data or no */
	BOOL moreData; 
}
/*!
 * The argc,argv parameters are passed in order to initialized the 
 * integrator of DIMVisual
 */
- (id) initWithArgc: (int) argc andArgv: (char **) argv;
@end

#endif
