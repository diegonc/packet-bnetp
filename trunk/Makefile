MKDIR?=mkdir
RM?=rm
ZIP?=zip
PERL?=/bin/perl

FILEPP=$(PERL) tools/filepp/filepp
FILEPP_FLAGS= \
	-m lua-comment.pm \
	-m literal.pm

PKGNAME=packet-bnetp
DISTNAME=packet-bnetp-src
VERSION:=$(shell date +%Y%m%d)

DIST = \
	src \
	src/constants.lua \
	src/cpackets.lua \
	src/packet-bnetp0.lua \
	src/spackets.lua \
	tools \
	tools/filepp \
	tools/filepp/filepp \
	tools/filepp/modules \
	tools/filepp/modules/bigdef.pm \
	tools/filepp/modules/bigfunc.pm \
	tools/filepp/modules/blc.pm \
	tools/filepp/modules/c-comment.pm \
	tools/filepp/modules/cmacros.pm \
	tools/filepp/modules/comment.pm \
	tools/filepp/modules/cpp.pm \
	tools/filepp/modules/defplus.pm \
	tools/filepp/modules/for.pm \
	tools/filepp/modules/foreach.pm \
	tools/filepp/modules/format.pm \
	tools/filepp/modules/function.pm \
	tools/filepp/modules/grab.pm \
	tools/filepp/modules/hash-comment.pm \
	tools/filepp/modules/literal.pm \
	tools/filepp/modules/lua-comment.pm \
	tools/filepp/modules/maths.pm \
	tools/filepp/modules/regexp.pm \
	tools/filepp/modules/tolower.pm \
	tools/filepp/modules/toupper.pm \
	tools/filepp/share \
	tools/filepp/share/man \
	tools/filepp/share/man/man1 \
	tools/filepp/share/man/man1/filepp.1 \
	Makefile

PKG = \
	src/packet-bnetp.lua

SOURCES = \
	src/constants.lua \
	src/cpackets.lua \
	src/packet-bnetp0.lua \
	src/spackets.lua

src/packet-bnetp.lua: $(SOURCES)
	$(FILEPP) $(FILEPP_FLAGS) src/packet-bnetp0.lua > src/packet-bnetp.lua

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
