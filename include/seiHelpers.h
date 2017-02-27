#ifndef SEIHELPERS_H
#define SEIHELPERS_H

#include <stdbool.h>
#include <stdio.h>

#ifndef LOG_STREAM
#define LOG_STREAM stderr
#endif

#ifdef NDEBUG
#define LOG_DEBUG false
#else
#define LOG_DEBUG true
#endif

// Always print filename before debug message
#define __FILENAME__ (__builtin_strrchr(__FILE__, '/') ? __builtin_strrchr(__FILE__, '/') + 1 : __FILE__)
#define LOG(fmt, ...) fprintf(LOG_STREAM, "[%s:%d]: %s -> " fmt "\n", __FILENAME__, __LINE__,  __FUNCTION__, ##__VA_ARGS__)
#define DEBUG(fmt, ...) do { if(LOG_DEBUG) LOG(fmt, ##__VA_ARGS__);} while(0);

#endif /* SEIHELPERS_H */
