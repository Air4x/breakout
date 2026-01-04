.POSIX:
.SUFFIX:
HARE=hare
HAREFLAGS=-lraylib -L./vendor/ -lm

DESTDIR=
PREFIX=/usr/local
BINDIR=$(PREFIX)/bin


all: breakout

breakout: cmd/breakout/main.ha
	$(HARE) build $(HAREFLAGS) -o breakout $^

check:
	$(HARE) test $(HAREFLAGS)
clean:
	 rm -f cmd

install:
	install -Dm755 cmd $(DESTDIR)$(BINDIR)/cmd

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/cmd

.PHONY: all check clean install uninstall
