# compiler options
CC=g++ -g
CFLAGS=-fPIC
COMPILER_OPTIONS=-O3
BATCH=


ifeq ($(uname_S),Linux)
	SHARED_LIB_EXT=.so
endif

ifeq ($(uname_S),Darwin)
	SHARED_LIB_EXT=.dylib
endif

# external libs (linking options)
LIBRARIES=$(INCLUDE_ARCHIVES_START) -lpthread -lmiracl -lssl -lcrypto $(INCLUDE_ARCHIVES_END) #-lgmp -lgmpxx 
LIBRARIES_DIR=-L$(builddir)/OpenSSL -L$(builddir)/MiraclCPP -L$(builddir)/CryptoPP

# target names
OT_MAIN=otmain
OT_LIBRARY=otlib

# sources
SOURCES_UTIL=util/*.cpp
OBJECTS_UTIL=util/*.o
SOURCES_OTMAIN=mains/otmain.cpp
OBJECTS_OTMAIN=mains/otmain.o
SOURCES_OT=ot/*.cpp
OBJECTS_OT=ot/*.o
#OBJECTS_MIRACL=util/Miracl/*.o

# includes
MIRACL_PATH=-I$(builddir)/MiraclCPP
OPENSSL_INCLUDES=-I$(builddir)/OpenSSL
INCLUDE=-I.. $(OPENSSL_INCLUDES) $(MIRACL_PATH)

## targets ##
all: ${OT_LIBRARY}

otlib: ${OBJECTS_UTIL} ${OBJECTS_OT}
	${CC} ${SHARED_LIB_OPT} -o libOTExtension${SHARED_LIB_EXT} \
	${OBJECTS_UTIL} ${OBJECTS_OT} ${MIRACL_PATH} ${LIBRARIES} ${LIBRARIES_DIR}

otmain: ${OBJECTS_UTIL}  ${OBJECTS_OT} ${OBJECTS_OTMAIN}
	${CC} -o ot.exe $(INCLUDE) ${CFLAGS} ${OBJECTS_OTMAIN} ${OBJECTS_UTIL} ${OBJECTS_OT} ${LIBRARIES} ${COMPILER_OPTIONS}

${OBJECTS_OTMAIN}: ${SOURCES_OTMAIN}$
	@cd mains; ${CC} -c ${INCLUDE} ${CFLAGS} otmain.cpp 

${OBJECTS_UTIL}: ${SOURCES_UTIL}$  
	@cd util; ${CC} -c ${CFLAGS} ${INCLUDE} ${BATCH} *.cpp

${OBJECTS_OT}: ${SOURCES_OT}$
	@cd ot; ${CC} -c ${CFLAGS} ${INCLUDE} ${BATCH} *.cpp 

install:
	install -d $(libdir)
	install -d $(prefix)/include/OTExtension/ot
	install -d $(prefix)/include/OTExtension/util
	install -m 0644 libOTExtension${SHARED_LIB_EXT} $(libdir)
	install -m 0644 ot/*.h $(prefix)/include/OTExtension/ot
	install -m 0644 util/*.h $(prefix)/include/OTExtension/util

clean:
	rm -rf ot.exe ${OBJECTS_UTIL} ${OBJECTS_OTMAIN} ${OBJECTS_OT}
	rm -f *${SHARED_LIB_EXT}

