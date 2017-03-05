PPFLAGS ?= 

EXE := simple

CXX :=
CC := gcc

#compiler flags
COMPILE_FLAGS := -std=c++11 -pedantic -Wall
COMPILE_FLAGS += -g -gdwarf-2

ifeq ($(CC), gcc)
CXX = g++
COMPILE_FLAGS += -pipe -march=native -Ofast
else ifeq ($(CC), icc)
CXX = icpc
COMPILE_FLAGS += -O3 -xhost -no-prec-div
# COMPILE_FLAGS += -parallel -ipo
ifneq (,$(findstring openmp,$(PPFLAGS)))
COMPILE_FLAGS += -qopenmp
endif
else
$(error "unknown compiler $(CC)")
endif

DEFINES := -DNDEBUG -DUSE_ZLIB
DEFINES += ${PPFLAGS}

#lib directories
LIB_DIRS := ../.. 

INCLUDE_DIRS := ../../include

#linker flags
LINK_FLAGS := -lz -ltourtre -static
ifeq ($(CC), gcc)
LINK_FLAGS += -flto
ifneq (,$(findstring openmp,$(PPFLAGS)))
LINK_FLAGS += -fopenmp
endif
else 
# LINK_FLAGS += -ipo
# LINK_FLAGS += -parallel -ipo
# LINK_FLAGS += -prof-gen -prof-use -parallel -ipo
ifneq (,$(findstring openmp,$(PPFLAGS)))
LINK_FLAGS += -qopenmp
endif
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
