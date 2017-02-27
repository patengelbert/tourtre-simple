CC = gcc
CCPP = g++

#preprocessor defines
DEFINES = -DUSE_ZLIB

OPTFLAGS = -O2

#CFLAGS = -ansi -pedantic -Wall -Werror -fPIC 
#CFLAGS = -ansi -pedantic -Wall -fPIC 
CFLAGS = -ansi $(OPTFLAGS)

CPPFLAGS = $(OPTFLAGS) -I./include $(DEFINES)

LINKFLAGS = -lz

all : simple

objs =  src/tourtre.o     \
	src/ctArc.o       \
	src/ctBranch.o    \
	src/ctComponent.o \
	src/ctNode.o      \
	src/ctQueue.o     \
	src/ctNodeMap.o	  \
	examples/simple/obj/Data.o \
	examples/simple/obj/Mesh.o \
	examples/simple/obj/main.o 

simple : $(objs)
	$(CCPP)  $(CPPFLAGS) -o simple $^ $(LINKFLAGS)

src/tourtre.o : src/tourtre.c include/tourtre.h src/ctMisc.h include/ctArc.h include/ctNode.h src/ctComponent.h include/ctNode.h src/ctQueue.h src/ctAlloc.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

src/ctArc.o : src/ctArc.c include/tourtre.h src/ctMisc.h include/ctArc.h 
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

src/ctBranch.o : src/ctBranch.c include/tourtre.h src/ctMisc.h include/ctBranch.h 
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

src/ctComponent.o : src/ctComponent.c include/tourtre.h src/ctMisc.h src/ctComponent.h 
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

src/ctNode.o : src/ctNode.c include/tourtre.h src/ctMisc.h include/ctNode.h 
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

src/ctQueue.o : src/ctQueue.c include/tourtre.h src/ctMisc.h src/ctQueue.h 
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

src/ctNodeMap.o : src/ctNodeMap.c src/ctNodeMap.h include/ctNode.h src/ctQueue.h src/sglib.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

examples/simple/obj/Data.o: examples/simple/src/Data.cpp examples/simple/src/Data.h examples/simple/src/Global.h 
	$(CCPP) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

examples/simple/obj/Mesh.o: examples/simple/src/Mesh.cpp examples/simple/src/Data.h examples/simple/src/Global.h examples/simple/src/Mesh.h 
	$(CCPP) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

examples/simple/obj/main.o: examples/simple/src/main.cpp examples/simple/src/Data.h examples/simple/src/Global.h examples/simple/src/Mesh.h 
	$(CCPP) $(CPPFLAGS) $(CFLAGS) -c $< -o $@




clean :
	-rm -rf src/*.o examples/simple/obj/*.o doc/html

