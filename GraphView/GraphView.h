#ifndef __GraphView_H
#define __GraphView_H

#include <Foundation/Foundation.h>
#include <Triva/TrivaFilter.h>
#include <AppKit/AppKit.h>
#include "DrawView.h"

@interface GraphView : TrivaFilter
{
  IBOutlet DrawView *view;
}
@end

#endif
