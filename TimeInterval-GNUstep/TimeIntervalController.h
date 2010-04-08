/* All Rights reserved */

#include <AppKit/AppKit.h>

@interface TimeIntervalController : NSObject
{
  id traceEndTimeLabel;
  id sliceView;
  id traceStartTimeLabel;
  id forwardLabel;
  id frequencyLabel;
  id playButton;
}
- (void) apply: (id)sender;
- (void) play: (id)sender;
- (void) sliderChanged: (id)sender;
@end
