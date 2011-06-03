
all: plugins

plugins: webglPlugin.opp/stamp

clean:
	rm -rf *\.opp

webglPlugin.opp/stamp: webglPlugin.js
	opa-plugin-builder -o webglPlugin webglPlugin.js

