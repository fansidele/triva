#include "TimeSliceGraph.h"

@implementation TimeSliceGraph
- (NSString*)description
{
  return [NSString stringWithFormat: @"%@-%@", name, timeSliceValues];
}

- (void) merge: (TimeSliceGraph *) other
{
  id key;
  NSEnumerator *keys = [[other timeSliceValues] keyEnumerator];
  while ((key = [keys nextObject])){
    id val = [timeSliceValues objectForKey: key];
    if (!val){
      val = [[other timeSliceValues] objectForKey: key];
      [timeSliceValues setObject: val forKey: key];
    }else{
      float value = [val doubleValue];
      float newValue = [[[other timeSliceValues] objectForKey: key] doubleValue];
      value += newValue;
      [timeSliceValues setObject:
        [NSString stringWithFormat: @"%f", value]
          forKey: key];
    }
  }
}
@end
