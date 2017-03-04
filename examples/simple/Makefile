PPFLAGS ?= 

EXE := simple

CXX := g++

#compiler flags
COMPILE_FLAGS := -std=c++11 -O3 -pedantic -Wall -fpic -march=native
COMPILE_FLAGS += -g -gdwarf-2

DEFINES := -DNDEBUG -DUSE_ZLIB
DEFINES += ${PPFLAGS}

#lib directories
LIB_DIRS := ../.. 

INCLUDE_DIRS := ../../include

#linker flags
LINK_FLAGS := -lz -ltourtre -static -flto

ifneq (,$(findstring openmp,$(PPFLAGS)))
LINK_FLAGS += -fopenmp
endif

#source suffixes to scan for
SOURCE_SUFFIXES := cpp cc

#directory to scan
SOURCE_DIR := src

#temporaries dir (object files, moc files, etc)
OBJ_DIR := obj

CXXFLAGS = $(foreach dir, $(INCLUDE_DIRS), $(addprefix -I, $(dir))) $(COMPILE_FLAGS)
CPPFLAGS = $(DEFINES) $(foreach dir, $(INCLUDE_DIRS), $(addprefix -I, $(dir)))
LDFLAGS = $(foreach dir, $(LIB_DIRS), $(addprefix -L, $(dir))) $(LINK_FLAGS)

#targets
all: $(EXE)

clean: 
	-rm -f obj/*
	-rm -f $(EXE)

remake: clean $(EXE)

OBJ_FILES = $(foreach suffix,$(SOURCE_SUFFIXES),$(addprefix $(OBJ_DIR)/,$(notdir $(subst .$(suffix),.o,$(wildcard $(SOURCE_DIR)/*.$(suffix))))))
DEP_FILES = $(foreach suffix,$(SOURCE_SUFFIXES),$(addprefix $(OBJ_DIR)/,$(notdir $(subst .$(suffix),.d,$(wildcard $(SOURCE_DIR)/*.$(suffix))))))

$(EXE): $(OBJ_FILES) $(DEP_FILES)
	$(CXX) -o $(EXE) $(OBJ_FILES) $(LDFLAGS)

-include $(DEP_FILES)

$(OBJ_DIR)/%.o: $(SOURCE_DIR)/%.cpp
	mkdir -p $(OBJ_DIR)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c -o $@  $<

$(OBJ_DIR)/%.d: $(SOURCE_DIR)/%.cpp
	mkdir -p $(OBJ_DIR)
	$(CXX) $(CPPFLAGS) $< -MM -MT $@ -MT $(subst .d,.o,$@) -MF $(subst .o,.d,$@)
