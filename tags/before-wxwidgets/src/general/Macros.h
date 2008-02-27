#ifndef _MACROS_H
#define _MACROS_H

#define Assign(variable, value)            \
    do {                                         \
        id newvalue = (value);                   \
        if (variable != newvalue) {              \
            if (variable) [variable release];    \
            variable = newvalue;                 \
            if (variable) [variable retain];     \
        }                                        \
    } while (0)

#endif
