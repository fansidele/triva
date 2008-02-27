#include "ProtoView.h"

@implementation ProtoView (KeyboardReceivers)
- (void) keyboardP
{
}

- (void) keyboardO
{
}

- (void) keyboardB
{
}

- (void) keyboardF
{
}

- (void) keyboardG
{
	[self changePositionAlgorithm];
}

- (void) keyboardV
{
}

- (void) keyboardL
{
	[self switchStatesLabels];
}

- (void) keyboardK
{
	[self switchContainersLabels];
}

- (void) keyboardM
{
}
@end
