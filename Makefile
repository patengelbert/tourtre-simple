CC = gcc
CFLAGS = -ansi -pedantic -Wall -fPIC -O3
CFLAGS += -std=c11
CFLAGS += -g

AR = ar
ARFLAGS = -r

SOURCEDIR := src
BUILDDIR := obj
INCLUDEDIR := include
DOCDIR := doc

SOURCES := $(shell find $(SOURCEDIR) -name '*.c')
OBJECTS := $(addprefix $(BUILDDIR)/,$(notdir $(SOURCES:%.c=%.o)))

SHARED := libtourtre.so
STATIC := libtourtre.a

.PHONY: all clean doc

all : $(SHARED) $(STATIC)

$(SHARED) : $(OBJECTS)
	$(AR) $(ARFLAGS) $@ $^
	
$(STATIC) : $(OBJECTS)
	$(CC) -shared -o $@ $^

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.c
	mkdir -p $(dir $@)	
	$(CC) $(CFLAGS) $(LDFLAGS) -I$(INCLUDEDIR) -I$(dir $<) -c $< -o $@

doxyfile.inc: Makefile
	@echo INPUT                  = $(INCLUDEDIR) > doxyfile.inc
	@echo OUTPUT_DIRECTORY         =  $(DOCDIR) >> doxyfile.inc

doc: doxyfile.inc $(SOURCES)
	doxygen Doxyfile

clean :
	-rm -rf $(SHARED) $(STATIC) $(OBJECTS) $(DOCDIR)/html doxyfile.inc
