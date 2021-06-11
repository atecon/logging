topsrc = ../..
prefix = /usr/local
datarootdir = ${prefix}/share
win32pkg = no
tooldir = $(topsrc)/tools

MAKE = make
INSTALL = /usr/bin/install -c

ifeq ($(INSTALL_DATA),)
  INSTALL_DATA = $(INSTALL) -m 644
endif

ifeq ($(win32pkg),yes)
  GFNDIR = $(prefix)/functions
else
  GFNDIR = $(datarootdir)/gretl/functions
endif

GRETLCLI = ../../cli/gretlcli

PKG = logging
PKGSRC = $(topsrc)/addons/logging/src

vpath %.inp $(PKGSRC)
vpath %.spec $(PKGSRC)

INP = logging.inp
SPEC = logging.spec
SMPL = logging_sample.inp
HELP = logging_help.txt

all: $(PKG).gfn

$(PKG).gfn: symlinks $(INP) $(SPEC) $(SMPL) $(HELP)
	$(GRETLCLI) -t pkg.inp

$(PKG).zip: $(PKG).gfn
	echo makepkg $(PKG).zip | $(GRETLCLI) -t -

.PHONY : symlinks check install installdirs clean

symlinks:
	@if [ ! -f $(SPEC) ] || [ $(PKGSRC)/$(SPEC) -nt $(SPEC) ] ; then ln -sf $(PKGSRC)/$(SPEC) . ; fi
	@if [ ! -f $(SMPL) ] || [ $(PKGSRC)/$(SMPL) -nt $(SMPL) ] ; then ln -sf $(PKGSRC)/$(SMPL) . ; fi
	@if [ ! -f $(HELP) ] || [ $(PKGSRC)/$(HELP) -nt $(HELP) ] ; then ln -sf $(PKGSRC)/$(HELP) . ; fi
	$(MAKE) symlinks

check: $(PKG).gfn
	$(tooldir)/test_addon $(GRETLCLI)

install: $(PKG).gfn installdirs
	$(INSTALL_DATA) $(PKG).gfn $(DESTDIR)$(GFNDIR)/$(PKG)
	$(INSTALL_DATA) doc/$(PKG).pdf $(DESTDIR)$(GFNDIR)/$(PKG)

installdirs:
	$(tooldir)/mkinstalldirs $(DESTDIR)$(GFNDIR)/$(PKG)

clean: 
	@rm -f $(PKG).gfn $(PKG)-i18n.c $(PKG).xml $(PKG).zip
	@rm -f *.plt *.dat string_table.txt
	@rm -f test.out
	@$(MAKE) -C src clean
	@$(MAKE) -C tests clean

