# 4k intro Makefile
# Windows, OS X and Linux

CHECK_OS = $(shell uname)
ifeq ($(CHECK_OS),)
	PLATFORM = WIN32
endif
ifeq ($(CHECK_OS),Linux)
	PLATFORM = LINUX
endif
ifeq ($(CHECK_OS),Darwin)
	PLATFORM = OS_X
endif

#debuggie thingie
DEBUG = TRUE
#to use SDL under Windows or OS X
USESDL = TRUE

#compiler we're using
CC = gcc
CXX = g++

#sourcefiles in use
OBJ = main.o
# play.o synth.o

TARGET = kartoonikum-by-exhouseandnecrostudios
LDFLAGS =
INCLUDES = -Iinclude
CFLAGS=

#-fno-strict-aliasing
CXXFLAGS =
CCFLAGS =
#-msse -ftree-vectorize your friends
#CFLAGS = -Os -fno-exceptions -fno-rtti $(INCLUDES)
RELEASES = 

ifeq ($(DEBUG),TRUE)
	CFLAGS += -D__DEBUG -ggdb -Wall
	#CFLAGS += -D__DEBUG -Wall
	CXXFLAGS += -pedantic -Wextra
endif

#Linux Makefile setup
ifeq ($(PLATFORM), LINUX)
	CFLAGS += -DSDL
	ifeq ($(DEBUG),TRUE)
		CFLAGS += -ggdb -DDEBUG -fno-strict-aliasing -DX86_ASM -std=c99 -ffast-math -flto $(shell pkgconf --cflags sdl) $(INCLUDES)
		LDFLAGS += $(shell pkgconf --libs sdl gl glu x11) -lm
	else
		CFLAGS += -Os -fmodulo-sched -fno-toplevel-reorder -fno-inline -fno-defer-pop -fno-keep-static-consts -fmerge-all-constants -fstrength-reduce -ffast-math -fomit-frame-pointer \
			-fno-builtin -D__X11__ -DSDL $(shell pkg-config gl --libs) $(shell pkg-config glu --libs)  $(shell sdl-config --cflags) -DX86_ASM -std=c99 -flto $(INCLUDES)
		CFLAGS += $(ADDFLAGS)
		LDFLAGS += -nostdlib -nostartfiles -ldl -L/usr/lib/ $(shell pkg-config x11 --libs)
endif
INCLUDES += -Iinclude/GL -Iinclude/SDL



endif

#Mac OS X Makefile setup
ifeq ($(PLATFORM), OS_X)
	CFLAGS += -Os -fno-strict-aliasing -DX86_ASM -std=c99  $(INCLUDES)

	ifeq ($(DEBUG),TRUE)
		CFLAGS += `sdl-config --cflags`
		LDFLAGS += `sdl-config --libs` -lpng -lz -lSDL_mixer
	else
		OBJ += SDLMain.o
		CFLAGS += -isysroot /Developer/SDKs/MacOSX10.4u.sdk
		LDFLAGS += -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk -arch ppc -arch i386 -framework SDL -framework Cocoa -framework OpenGL
	endif

	CFLAGS += -DOS_X -DSDL -I/System/Library/Frameworks/AGL.framework/Headers
	#for PowerPC - Intel crosscompilation use -arch switch
	#lipo tool can merge the binaries easily
	#CC = gcc-3.3
	#CXX = g++-3.3
	ENDIAN = $(shell uname -m)

endif

#Windows Makefile setup
ifeq ($(PLATFORM), WIN32)
	INCLUDES += -Iinclude/GL
	ifeq ($(USESDL), TRUE)
		CFLAGS += -Os -fno-strict-aliasing -DX86_ASM -std=c99  $(shell sdl-config --cflags) $(INCLUDES)
		INCLUDES += -Iinclude/SDL
		CFLAGS += -DSDL
		LDFLAGS += -lmingw32 -liberty -lglu32 -lopengl32 -lgdi32 -lm
		#ifeq ($(DEBUG),FALSE)
		CFLAGS += -Dmain=SDL_main
		LDFLAGS += -mwindows -lSDLmain
		#endif
		LDFLAGS += -lSDL
	else
		#CFLAGS += -Os -fno-strict-aliasing -DX86_ASM -std=c99 -march=i686 $(shell sdl-config --cflags) $(INCLUDES)
		#CFLAGS += -DWIN32 -Os -std=c99 $(INCLUDES)

		#CFLAGS += -DWIN32 -ffast-math -fexpensive-optimizations -fno-peephole -fno-defer-pop -Os -std=c99 $(INCLUDES)

		CFLAGS += -DWIN32 -Os -ffast-math -fexpensive-optimizations -fno-peephole -fno-defer-pop \
			-fno-keep-static-consts -fmerge-all-constants -fstrength-reduce -fno-builtin \
			-fno-strict-aliasing -DX86_ASM -std=c99 $(INCLUDES)


		LDFLAGS += -s -lmingw32 -lopengl32 -lglu32 -lgdi32 -lkernel32 -luser32 -lm -lwinmm -mwindows -mno-cygwin -nostdlib -lmsvcrt
	endif

	TARGET = main.exe
endif

.PHONY: all all-before all-after clean clean-custom
all: all-before $(TARGET) all-after
#define some system utilities
RM_F = rm -f
CP = cp -R
MKDIR = mkdir
#variables d'instalation
INSTALL := install
INSTALL_DIR     := $(INSTALL) -p -d -o root -g root  -m  755
INSTALL_PROGRAM := $(INSTALL) -p    -o root -g root  -m  755
INSTALL_LIBS    := $(INSTALL) -p    -o root -g root  -m  755
INSTALL_DATA    := $(INSTALL) -p    -o root -g root  -m  644
INSTALL_DATAR   := cp -r
INSTALL_SCRIPT  := $(INSTALL) -p    -o root -g root  -m  755

prefix          := /usr
exec_prefix     := $(prefix)
bindir          := $(prefix)/bin
datarootdir     := $(prefix)/share
datadir         := $(prefix)/share/kartoonikum-by-exhouseandnecrostudios

clean:
	 -$(RM_F) $(OBJ) $(TARGET)

%.o: %.m $(HEADERS)
	$(CC) $(CFLAGS) $(CCFLAGS) -c $<

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) $(CCFLAGS) -c $<

$(TARGET): $(OBJ)
	$(CC) -o $@ $(OBJ) -flto $(LDFLAGS)

install: $(TARGET)
	$(INSTALL_DIR) $(DESTDIR)$(bindir)
	-@$(RM_F) $(DESTDIR)$(bindir)/$(TARGET)
	$(INSTALL_PROGRAM) $(TARGET) $(DESTDIR)$(bindir)
