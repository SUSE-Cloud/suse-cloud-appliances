# This assumes that you have the reveal.js repo from GitHub cloned
# into ../reveal.js.
#
# Override with make REVEAL=/path/to/reveal.js
REVEAL ?= ../reveal.js
# Override with make QRCODE=/path/to/qrcodejs
QRCODE ?= ../qrcodejs

# Directories we pull from reveal.js
REVEAL_SYMLINKS ?= plugin lib css js

# Scripts we pull from qrcodejs
QRCODE_SYMLINKS ?= qrcode.js

all: symlinks

symlinks: $(REVEAL_SYMLINKS) $(QRCODE_SYMLINKS)

$(REVEAL_SYMLINKS):
	ln -s $(REVEAL)/$@

$(QRCODE_SYMLINKS):
	ln -s $(QRCODE)/$@

clean:
	rm -f $(REVEAL_SYMLINKS) $(QRCODE_SYMLINKS)

.PHONY: all symlinks clean
