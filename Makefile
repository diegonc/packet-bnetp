MKDIR?=mkdir
RM?=rm
ZIP?=zip
PERL?=/usr/bin/perl
LUA?=lua
LUA_VERSION?=530

FILEPP=$(PERL) tools/filepp/filepp
FILEPP_FLAGS= \
	-m pb-utils.pm \
	-m literal.pm \
	-DLUA_VERSION=$(LUA_VERSION)
# GitHub upload params should be defined in Makefile.local
# GHU_USER: uploader's username
# GHU_PASS: uploader's password
# GHU_REPO: repository where release is created

PKGNAME=packet-bnetp
DISTNAME=packet-bnetp-src
VERSION:=$(shell date +%Y_%m_%d)
REL_TAG:=v$(shell date +%Y.%m.%d)
REL_NAME:=$(REL_TAG)
REL_BODY:=$(REL_TAG)

PKG = \
	src/packet-bnetp.lua

SOURCES = \
	src/testpackets.lua \
	src/constants.lua \
	src/checkedtable.lua \
	src/api/integer.lua \
	src/api/array.lua \
	src/api/stringz.lua \
	src/api/time.lua \
	src/api/strdw.lua \
	src/api/when.lua \
	src/api/flags.lua \
	src/api/iterator.lua \
	src/api/ipv4.lua \
	src/api/sockaddr.lua \
	src/api/slot.lua \
	src/api/bytes.lua \
	src/api/version.lua \
	src/valuemaps.lua \
	src/banner.lua \
	src/core.lua \
	src/constants_sid.lua \
	src/cpackets_sid.lua \
	src/spackets_sid.lua \
	src/constants_w3gs.lua \
	src/cpackets_w3gs.lua \
	src/spackets_w3gs.lua

DIST = \
	$(SOURCES) \
	$(PKG) \
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


src/packet-bnetp.lua: $(SOURCES)
	$(FILEPP) $(FILEPP_FLAGS) src/core.lua > src/packet-bnetp.lua

tools/xmlexport/export.lua: tools/xmlexport/export.lua.filepp
	$(FILEPP) $(FILEPP_FLAGS) -Itools/xmlexport -Isrc tools/xmlexport/export.lua.filepp > tools/xmlexport/export.lua

.PHONY: run-xmlexport
run-xmlexport: tools/xmlexport/export.lua
	LUA_PATH="./tools/xmlexport/lib/LuaExpatUtils/lua/?.lua;./tools/xmlexport/?.lua" $(LUA) tools/xmlexport/export.lua


.PHONY: pkg upload clean

# Junk the directories in the zip file
# to align with previously released archives.
# TODO: avoid name clashes in PKG
$(PKGNAME)-$(VERSION).zip: $(PKG)
	$(ZIP) -9 -j $(PKGNAME)-$(VERSION).zip $(PKG)

pkg: $(PKGNAME)-$(VERSION).zip
upload: pkg
	tools/github_upload.py \
		$(GHU_USER) \
		$(GHU_PASS) \
		$(GHU_REPO) \
		$(REL_TAG)  \
		$(REL_NAME) \
		$(REL_BODY) \
		-a $(PKGNAME)-$(VERSION).zip:$(PKGNAME)-$(VERSION).zip

clean:
	$(RM) src/packet-bnetp.lua

-include Makefile.local
