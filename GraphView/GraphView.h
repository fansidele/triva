#ifndef __GraphView_H
#define __GraphView_H

#include <Foundation/Foundation.h>
#include <Triva/TrivaFilter.h>
#include <AppKit/AppKit.h>

@interface GraphView : TrivaFilter
{
  IBOutlet id view;
}
@end

#endif
