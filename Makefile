MKDIR?=mkdir
RM?=rm
ZIP?=zip
PERL?=/usr/bin/perl
LUA?=lua
LUA_VERSION?=530

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
	packet-bnetp-base.lua \
	packet-bnetp-bncs.lua \
	packet-bnetp-w3gs.lua


DIST = \
	$(PKG)

.PHONY: pkg

# Junk the directories in the zip file
# to align with previously released archives.
# TODO: avoid name clashes in PKG
$(PKGNAME)-$(VERSION).zip: $(PKG)
	$(ZIP) -9 -j $(PKGNAME)-$(VERSION).zip $(PKG)

pkg: $(PKGNAME)-$(VERSION).zip

## Re-enable when github_upload.py works again
# upload: pkg
#	tools/github_upload.py \
#		$(GHU_USER) \
#		$(GHU_PASS) \
#		$(GHU_REPO) \
#		$(REL_TAG)  \
#		$(REL_NAME) \
#		$(REL_BODY) \
#		-a $(PKGNAME)-$(VERSION).zip:$(PKGNAME)-$(VERSION).zip

-include Makefile.local
