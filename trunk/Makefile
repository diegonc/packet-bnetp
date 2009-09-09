MKDIR=mkdir
RM=rm
ZIP=zip

PKGNAME=packet-bnetp
DISTNAME=packet-bnetp-src
VERSION=$(shell date +%Y%m%d)

DIST = \
	src/constants.lua \
	src/cpackets.lua \
	src/packet-bnetp0.lua \
	src/spackets.lua \
	tools/preprocess.pl \
	Makefile

PKG = \
	src/packet-bnetp.lua

SOURCES = \
	src/constants.lua \
	src/cpackets.lua \
	src/packet-bnetp0.lua \
	src/spackets.lua

src/packet-bnetp.lua: $(SOURCES)
	tools/preprocess.pl -i src/packet-bnetp0.lua -o src/packet-bnetp.lua

.PHONY: pkg upload clean

$(PKGNAME)-$(VERSION).zip: $(PKG)
	$(MKDIR) $(PKGNAME)-$(VERSION) && (\
		( cp $(PKG) $(PKGNAME)-$(VERSION) && \
		  $(ZIP) -9 -r $(PKGNAME)-$(VERSION).zip $(PKGNAME)-$(VERSION) ); \
		$(RM) -r $(PKGNAME)-$(VERSION) )

pkg: $(PKGNAME)-$(VERSION).zip
upload: pkg
	tools/googlecode_upload.py \
		-p packet-bnetp \
		-s "packet-bnetp plugin" \
		$(PKGNAME)-$(VERSION).zip

clean:
	$(RM) src/packet-bnetp.lua
