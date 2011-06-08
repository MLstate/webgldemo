
all: plugins

plugins: webglPlugin.opp/stamp glMatrixPlugin.opp/stamp requestAnimationFramePlugin.opp/stamp

clean:
	rm -rf *\.opp

webglPlugin.opp/stamp: webglPlugin.js
	opa-plugin-builder -o webglPlugin webglPlugin.js

glMatrixPlugin.opp/stamp: glMatrix-0.9.5.min.js glMatrixPlugin.js
	opa-plugin-builder -o glMatrixPlugin glMatrix-0.9.5.min.js glMatrixPlugin.js

requestAnimationFramePlugin.opp/stamp: RequestAnimationFramePlugin.js RequestAnimationFrame.js
	opa-plugin-builder -o requestAnimationFramePlugin RequestAnimationFrame.js RequestAnimationFramePlugin.js
