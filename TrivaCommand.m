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
#include "TrivaCommand.h"
#include <argp.h>

const char *triva_program_version = "triva v2.0";
const char *triva_address = "http://triva.gforge.inria.fr";
static char doc[] = "Trace Analysis through Visualization";
static char args_doc[] = "TRACEFILE";

static struct argp_option options[] = {
  {0, 0, 0, 0, "You need to use one of the following options:"},
  {"treemap", 't', 0, OPTION_ARG_OPTIONAL, "Squarified Treemap Window"},
  {"graph",   'g', 0, OPTION_ARG_OPTIONAL, "Graph Window"},
  {"dot",     'd', 0, OPTION_ARG_OPTIONAL, "Export the Type Hierarchy"},
  { 0 }
};

static int has_vis_activated (struct arguments *arg)
{
  return arg->treemap || arg->graph || arg->dot;
}

/* Parse a single option. */
static int parse_options (int key, char *arg, struct argp_state *state)
{
  /* Get the input argument from argp_parse, which we
     know is a pointer to our arguments structure. */
  struct arguments *arguments = state->input;

  switch (key)
    {
    case 't':
      if (has_vis_activated (arguments)) argp_usage(state);
      arguments->treemap = 1;
      break;
    case 'g':
      if (has_vis_activated (arguments)) argp_usage(state);
      arguments->graph = 1;
      break;
    case 'd':
      if (has_vis_activated (arguments)) argp_usage(state);
      arguments->dot = 1;
      break;

    case ARGP_KEY_ARG:
      if (state->arg_num > 1)
        /* Too many arguments. */
        argp_usage (state);

      arguments->input[state->arg_num] = arg;

      break;

    case ARGP_KEY_END:
      if (state->arg_num < 1)
        /* Not enough arguments. */
        argp_usage (state);
      break;

    default:
      return ARGP_ERR_UNKNOWN;
    }
  return 0;
}

static struct argp argp = { options, parse_options, args_doc, doc };

int parse (int argc, char **argv, struct arguments *arg)
{
  int ret = argp_parse (&argp, argc, argv, 0, 0, arg);
  return ret;
}
