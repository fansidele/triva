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
#ifndef __TRIVA_COMMAND_H
#define __TRIVA_COMMAND_H
#include <stdio.h>

#define MAX_INPUT_SIZE 100

struct arguments
{
  char *input[MAX_INPUT_SIZE];
  int input_size;

  int treemap, graph, linkview; //visualization windows
  int comparison;
  int abort; //if parameters are not good
  int hierarchy; //generate type hierarchy
  int check;  //check trace file
  int list; // list entity types
  int instances; //list types and instances
};

int parse (int argc, char **argv, struct arguments *arg);

#endif
