#include <Foundation/Foundation.h>
#include <General/PajeFilter.h>
#include "ProtoView.h"

@interface PajeOgreFilter : PajeFilter
{
	ProtoView *viewController;
}
- (void) setViewController: (ProtoView *) c;
@end
