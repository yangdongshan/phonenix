#ifndef __TYPEDEF_H
#define __TYPEDEF_H

#include <stdint.h>
#include <stddef.h>

typedef unsigned char       bool;

/*
typedef unsigned char       uint8_t;
typedef signed char         int8_t;
typedef unsigned short      uint16_t;
typedef signed short        int16_t;
typedef unsigned int        uint32_t;
typedef signed int          int32_t;
typedef unsigned long long  uint64_t;
typedef signed long long    int64_t;
typedef unsigned long       size_t;

typedef signed long         ssize_t;
*/

typedef unsigned long       addr_t;

typedef unsigned long long  tick_t;

typedef unsigned long irqstate_t;

#define true (1)
#define false (0)

#ifndef NULL
#define NULL ((void*)0)
#endif

#endif // __TYPEDEF_H

