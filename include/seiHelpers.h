#ifndef SEIHELPERS_H
#define SEIHELPERS_H

#include <string.h>
#include <stdio.h>

#define ANSI_COLOR_BOLD_RED "\x1b[1;31m"
#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_YELLOW  "\x1b[33m"
#define ANSI_COLOR_BLUE    "\x1b[34m"
#define ANSI_COLOR_MAGENTA "\x1b[35m"
#define ANSI_COLOR_CYAN    "\x1b[36m"
#define ANSI_COLOR_RESET   "\x1b[0m"

#define LOG_FATAL   (0)
#define LOG_ERROR   (1)
#define LOG_WARNING (2)
#define LOG_INFO    (3)
#define LOG_DEBUG   (4)

// Always print filename before debug message
#define __FILENAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)

#ifndef NDEBUG

#define LOG_COLOR(level) (level == LOG_FATAL ? ANSI_COLOR_BOLD_RED : \
                          level == LOG_ERROR ? ANSI_COLOR_RED : \
                          level == LOG_WARNING ? ANSI_COLOR_YELLOW : \
                          level == LOG_INFO ? ANSI_COLOR_CYAN : \
                          level == LOG_DEBUG ? ANSI_COLOR_GREEN : \
                          ANSI_COLOR_RESET)

#define LOG(level, fmt, ...)                                                                                                   \
    do                                                                                                                         \
    {                                                                                                                          \
        if (level <= logLevel) {                                                                                                \
            fprintf(logStream, "%s[%s:%d] : %s -> " fmt ANSI_COLOR_RESET "\n", LOG_COLOR(level), __FILENAME__, __LINE__, __func__, ##__VA_ARGS__); \
        }                                                                                                                        \
    } while (0);
#else
#define LOG(level, fmt, ...) (void)0;
#endif

#ifdef __cplusplus
extern "C" {
#endif

extern unsigned logLevel;
extern FILE *logStream;

#ifdef __cplusplus
}
#endif

#endif /* SEIHELPERS_H */
