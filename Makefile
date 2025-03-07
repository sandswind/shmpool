#
#

PROJ=		sms
LIBPWD=     $(shell pwd)

CFLAGS+=	-std=gnu99 -Wall -Wextra
CFLAGS+=	-D_GNU_SOURCE -D_DEFAULT_SOURCE
#CFLAGS+=	-I../include
CFLAGS+=	-I../include -Wno-unused-parameter

NODEBUG=	$(L4NODEBUG)

ifeq ($(NODEBUG),0)
CFLAGS+=	-g -ggdb3 -DDEBUG -fno-omit-frame-pointer
else
CFLAGS+=	-O2
endif


APPNAME=	test
APPOBJS=	test.o
LIBNAME=	lib$(PROJ)
OBJS=		sms_shmm.o sms_bucket.o
LIBDIR=		$(LIBPWD)/../lib
LIBS = $(LIBDIR)/libsms.a $(LIBDIR)/libcmn.a  -pthread
$(LIBNAME).la:	LDFLAGS+=	-rpath $(LIBDIR) -version-info 1:0:0

all: lib install

obj: $(OBJS)

lib: $(LIBNAME).la

%.lo: %.c
	libtool --mode=compile --tag CC $(CC) $(CFLAGS) -c $<

$(LIBNAME).la: $(shell echo $(OBJS) | sed 's/\.o/\.lo/g')
	libtool --mode=link --tag CC $(CC) $(LDFLAGS) -o $@ $(notdir $^)

$(APPNAME): $(APPOBJS)
	libtool --mode=link --tag CC $(CC) $(LDFLAGS) $(LIBS) -g -o $(APPNAME) $(notdir $^)

install/%.la: %.la
	libtool --mode=install install -c $(notdir .libs/$@) $(LIBDIR)/$(notdir $@)

install: $(addprefix install/,$(LIBNAME).la)
	libtool --mode=finish $(LIBDIR)

clean:
	libtool --mode=clean rm
	rm -rf .libs *.o *.lo *.la

.PHONY: all obj lib install
