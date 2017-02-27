CC := gcc
CFLAGS := -ansi -pedantic -Wall -fPIC -O3
CFLAGS += -std=c11
CFLAGS += -g

AR := ar
ARFLAGS := -r

SOURCEDIR := src
BUILDDIR := obj
INCLUDEDIR := include
DOCDIR := doc

SOURCE_SUFFIXES := c

SOURCES := $(foreach suffix,$(SOURCE_SUFFIXES),$(wildcard $(SOURCEDIR)/*.$(suffix)))
OBJECTS := $(foreach suffix, $(SOURCE_SUFFIXES), $(addprefix $(BUILDDIR)/,$(notdir $(subst .$(suffix),.o,$(SOURCES)))))
SHARED := libtourtre.so
STATIC := libtourtre.a

.PHONY: all clean doc libs examples

all : examples

libs: $(SHARED) $(STATIC)

$(SHARED) : $(OBJECTS)
	$(AR) $(ARFLAGS) $@ $^
	
$(STATIC) : $(OBJECTS)
	$(CC) -shared -o $@ $^

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.c
	mkdir -p $(dir $@)	
	$(CC) $(CFLAGS) $(LDFLAGS) -I$(INCLUDEDIR) -I$(dir $<) -c $< -o $@

examples: libs
	cd examples/simple && "$(MAKE)" all

doxyfile.inc: Makefile
	@echo INPUT                  = $(INCLUDEDIR) > doxyfile.inc
	@echo OUTPUT_DIRECTORY         =  $(DOCDIR) >> doxyfile.inc

doc: doxyfile.inc $(SOURCES)
	doxygen Doxyfile

clean :
	-rm -rf $(SHARED) $(STATIC) $(OBJECTS) $(DOCDIR)/html doxyfile.inc
	-cd examples/simple && "$(MAKE)" clean
