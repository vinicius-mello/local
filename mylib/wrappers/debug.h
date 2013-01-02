#ifndef WRAPPER_DEBUG_H
#define WRAPPER_DEBUG_H
#ifndef DEBUG
#define DEBUG 0
#endif
#include <stdio.h>

#define debug_print(fmt, ...) \
    do { if (DEBUG) fprintf(stderr, fmt, __VA_ARGS__); } while (0)
#endif
