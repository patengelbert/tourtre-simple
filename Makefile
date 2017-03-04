PPFLAGS ?= 

CC := gcc
COMPILE_FLAGS := -std=c11 -O3 -pedantic -Wall -fpic -march=native
COMPILE_FLAGS += -g -gdwarf-2
DEFINES := -DNDEBUG
DEFINES += ${PPFLAGS}

AR := ar
ARFLAGS := -r

SOURCE_DIR := src
BUILD_DIR := obj
INCLUDE_DIRS := include
DOC_DIR := doc

SOURCE_SUFFIXES := c

SOURCES := $(foreach suffix,$(SOURCE_SUFFIXES),$(wildcard $(SOURCE_DIR)/*.$(suffix)))
OBJECTS := $(foreach suffix, $(SOURCE_SUFFIXES), $(addprefix $(BUILD_DIR)/,$(notdir $(subst .$(suffix),.o,$(SOURCES)))))
SHARED := libtourtre.so
STATIC := libtourtre.a

CFLAGS = $(foreach dir, $(INCLUDE_DIRS), $(addprefix -I, $(dir))) $(COMPILE_FLAGS) 
CPPFLAGS = $(DEFINES) $(foreach dir, $(INCLUDE_DIRS), $(addprefix -I, $(dir)))

.PHONY: all clean doc libs examples

all : examples

libs: $(SHARED) $(STATIC)

$(STATIC) : $(OBJECTS)
	$(AR) $(ARFLAGS) $@ $^
	
$(SHARED) : $(OBJECTS)
	$(CC) -shared -o $@ $^

$(BUILD_DIR)/%.o: $(SOURCE_DIR)/%.c
	mkdir -p $(dir $@)	
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

examples: $(STATIC)
	cd examples/simple && "$(MAKE)" all PPFLAGS="$(PPFLAGS)"

doxyfile.inc: Makefile
	@echo INPUT                  = $(INCLUDE_DIRS) > doxyfile.inc
	@echo OUTPUT_DIRECTORY         =  $(DOC_DIR) >> doxyfile.inc

doc: doxyfile.inc $(SOURCES)
	doxygen Doxyfile

clean :
	-rm -rf $(SHARED) $(STATIC) $(OBJECTS) $(DOC_DIR)/html doxyfile.inc
	-cd examples/simple && "$(MAKE)" clean

