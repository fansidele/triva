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
#include <Foundation/Foundation.h>
#import <DIMVisual/IntegratorLib.h>
#import <GenericEvent/GEvent.h>
#include <PajeGeneral/PajeFilter.h>

@interface HCMReader : PajeFilter 
{
  NSMutableArray *buffer; /* of NSData* */
  NSConditionLock *bufferLock; /* lock for buffer */
  IntegratorLib *integrator;
  PajeHeaderCenter *headerCenter;
  NSFileHandle *outFile;
  NSArray *aggregatorNames;/* of (NSString *)  */
  NSString *clientId;
}
- (BOOL) sendToPaje: (NSData *) data;
- (void) waitForDataFromHCM: (id) object;
- (BOOL)applyConfiguration: (NSDictionary *) conf;
@end
