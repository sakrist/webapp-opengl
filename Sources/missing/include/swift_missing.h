#ifndef SWIFT_MISSING_H
#define SWIFT_MISSING_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

uint64_t swift_float64ToString(char *Buffer, size_t BufferLength,
    double Value, bool Debug);
#endif