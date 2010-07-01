/*
    This file is part of Triva.

    Triva is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Triva is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Triva.  If not, see <http://www.gnu.org/licenses/>.
*/
#include "MALayout.h"

@implementation MARect
- (float) width { return width; }
- (float) height { return height; }
- (float) x { return x; }
- (float) y { return y; }
- (void) setWidth: (float) w { width = w; }
- (void) setHeight: (float) h { height = h; }
- (void) setX: (float) xis { x = xis;}
- (void) setY: (float) ipslon { y = ipslon;}
- (NSString *) description
{
        return [NSString stringWithFormat: @"%f,%f - size %f,%f",
                        x, y, width, height];
}
@end

@implementation MALayout
- (id) init
{
  self = [super init];
//  smallestMemoryAddress = 0;
//  highestMemoryAddress = 0;
  return self;
}

- (void) dealloc
{
  [cpuThreadContainer release];
  [memoryContainer release];
  [super dealloc];
}

- (void) setMemoryContainer: (PajeContainer *) mem
{
  [memoryContainer release];
  memoryContainer = mem; // not retained
  [memoryContainer retain];
}

- (void) setCPUandThreadContainer: (NSDictionary *) cputhread
{
  [cpuThreadContainer release];
  cpuThreadContainer = cputhread;
  [cpuThreadContainer retain];
}

- (void) defineLayoutWithWidth: (int) width andHeight: (int) height
{
  [memoryLayout release];
  [cpuThreadLayout release];

  memoryLayout = [[NSMutableDictionary alloc] init];
  cpuThreadLayout = [[NSMutableDictionary alloc] init];

  /* define memoryLayout */
  NSEnumerator *en1 = [memoryWindow objectEnumerator];
  id data;
  double max = 0;
  while ((data = [en1 nextObject])){
    double dif = [[data objectForKey: @"dif"] doubleValue];
    int count = [[data objectForKey: @"count"] intValue];
    if (dif == 0){
      dif = 1;
    }
    max += count/dif;
  }
  //NSLog (@"max = %f",max);
  int memCount = [memoryWindow count], mc = 0;
  int y = 0;
  en1 = [memoryWindow objectEnumerator];
  while ((data = [en1 nextObject])){
    MARect *memoryRect = [[MARect alloc] init];
    [memoryRect setX: width*.9];
    [memoryRect setWidth: width*.1];

    double dif = [[data objectForKey: @"dif"] doubleValue];
    if (dif == 0){
      dif = 1;
    }
    int count = [[data objectForKey: @"count"] intValue];
    int h = count/dif/max*height;
    //NSLog (@"dif=%f count=%d h=%d", dif, count, h);
    if (!h) { h = 1; }

    [memoryRect setY: y];
    [memoryRect setHeight: h];

    [data setObject: memoryRect forKey: @"rect"];

    [memoryLayout setObject: memoryRect
        forKey: [NSString stringWithFormat: @"%d", mc]];
    [memoryRect release];
    y += h;
    mc++;
  }

  /* define cpuThreadLayout */
  int cpuN = [[cpuThreadContainer allKeys] count];
  NSEnumerator *en = [cpuThreadContainer keyEnumerator];
  id cpu;
  int step = height/cpuN, i = 0;
  while ((cpu = [en nextObject])){
    MARect *cpuRect = [[MARect alloc] init];
    [cpuRect setX: 0];
    [cpuRect setY: i*step];
    [cpuRect setWidth: width*.1];
    [cpuRect setHeight: step];

    [cpuThreadLayout setObject: cpuRect forKey: [cpu name]];
    [cpuRect release];

    NSEnumerator *en2;
    en2 = [[cpuThreadContainer objectForKey: cpu] objectEnumerator];
    int threadN = [[cpuThreadContainer objectForKey: cpu] count];
    id thread;
    int stepthread = step/threadN, j = 0;
    while ((thread = [en2 nextObject])){

      MARect *threadRect = [[MARect alloc] init];
      [threadRect setX: 0];
      [threadRect setY: i*step + j*stepthread];
      [threadRect setWidth: width*.1];
      [threadRect setHeight: stepthread];
    
      [cpuThreadLayout setObject: threadRect
              forKey: [thread name]];
      [threadRect release];
      j++;
    }
    i++;
  }
}

- (NSDictionary *) memoryLayout
{
  return memoryLayout;
}

- (NSDictionary *) cpuThreadLayout
{
  return cpuThreadLayout;
}

- (NSDictionary *) layout
{
  NSMutableDictionary *ret;
  ret = [NSMutableDictionary dictionaryWithDictionary: memoryLayout];
  [ret addEntriesFromDictionary: cpuThreadLayout];
  return ret;
}

/*
- (void) setSmallestMemoryAddress: (double) s
{
  smallestMemoryAddress = s;
}

- (void) setHighestMemoryAddress: (double) s
{
  highestMemoryAddress = s;
}

- (double) smallestMemoryAddress
{
  return smallestMemoryAddress;
}

- (double) highestMemoryAddress
{
  return highestMemoryAddress;
}
*/
- (void) setMemoryWindow: (NSArray *) mem
{
  [memoryWindow release];
  memoryWindow = mem;
  [memoryWindow retain];
}

- (NSArray *) memoryWindow
{
  return memoryWindow;
}

- (NSDictionary *) findMemoryWindowForValue: (double) val
{
  NSEnumerator *en = [memoryWindow objectEnumerator];
  id data;
  while ((data = [en nextObject])){
    double start = [[data objectForKey: @"start"] doubleValue];
    double end = [[data objectForKey: @"end"] doubleValue];
    if (val > start && val < end){
      return data;
    }
  }
  return nil;
}
@end
