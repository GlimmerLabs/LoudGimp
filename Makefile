

# +----------+--------------------------------------------------------
# | Settings |
# +----------+

CFLAGS = -g -Wall


# +---------------+---------------------------------------------------
# | Sets of Files |
# +---------------+

# The extensions to racket implemented in C.
C_EXTENSIONS = \
	$(COMPILED_DIR)/irgb.so

# +-------------------------------------------------------------------
# | Special Settings for Racket C Stuff |
# +-------------------------------------+

RACO_CFLAGS = $(shell echo '' $(CFLAGS) | utils/racocflags)

# Inside Racket says to use --cgc, but that requires mzdyn.o, which does
# not seem to ship with the standard distribution, and I'm lazy.
RACO_GC = --3m

# We need to know where to put the compiled Racket library.
COMPILED_DIR = $(shell racket utils/compiled-goes-here.rkt)


# +------------------+------------------------------------------------
# | Standard Targets |
# +------------------+

default: gimp-dbus.rkt $(C_EXTENSIONS)

clean: rm gimp-dbus.rkt


# +-----------------+-------------------------------------------------
# | Special Actions |
# +-----------------+

# Expose exposes this directory to DrRacket
expose:
	raco link `pwd`

# +-----------------+-------------------------------------------------
# | Special Targets |
# +-----------------+

gimp-dbus.rkt: funs mkwrapper
	./mkwrapper funs > gimp-dbus.rkt

funs:
	racket utils/list-pdb-funs.rkt > funs

rebuild-funs: 
	rm -f funs
	make funs

irgb.o: irgb.c
	raco ctool --cc $(RACO_GC) $(RACO_CFLAGS) $<

irgb.so: irgb.o
	raco ctool --vv $(RACO_RC) ++ldf -L/usr/lib/x86_64-linux-gnu $(RACO_LDLIBS) --ld $@ $^

$(COMPILED_DIR)/irgb.so: irgb.so
	install -D $< $@

# +-------------+-----------------------------------------------------
# | Experiments |
# +-------------+

compiled-dir:
	echo $(COMPILED_DIR)
