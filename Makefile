.PHONY: all syntax main.js
SOURCES = canvasw.coffee uiobject.coffee main.coffee

all: syntax main.js

syntax: $(SOURCES)
	coffee -c canvasw.coffee
	coffee -c uiobject.coffee
	coffee -c main.coffee

main.js: $(SOURCES)
	coffee -cbj main.js $(SOURCES)

