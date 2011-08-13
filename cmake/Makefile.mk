# $Id: d26683d079d4281363f2aa6c5bbdbe83e607c387 $

DEST = $(PREFIX)/share/cmake/GeographicLib

INSTALL=install -b

all:
	@:
install:
	test -d $(DEST) || mkdir -p $(DEST)
	$(INSTALL) -m 644 FindGeographicLib.cmake $(DEST)
list:
	@echo FindGeographicLib.cmake \
	geographiclib-config.cmake.in geographiclib-config-version.cmake.in
clean:
	@:

.PHONY: all install list clean