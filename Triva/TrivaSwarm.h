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
#ifndef __TrivaSwarm_h_
#define __TrivaSwarm_h_
#include <Foundation/Foundation.h>
#include <Triva/TrivaComposition.h>

@interface TrivaSwarm : TrivaComposition
{
  NSRect bb; //the bounding box
  NSMutableArray *objects; //array of strings with the existing objects
  NSMutableDictionary *objectsColors; //dict of string->colors
  TrivaGraphNode *node;
}
@end

#endif