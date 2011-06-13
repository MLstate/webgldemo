
all: plugins

plugins: webglPlugin.opp/stamp glMatrixPlugin.opp/stamp requestAnimationFramePlugin.opp/stamp webglUtilsPlugin.opp/stamp

clean:
	rm -rf *\.opp opps

webglPlugin.opp/stamp: webglPlugin.js
	opa-plugin-builder -o webglPlugin webglPlugin.js

glMatrixPlugin.opp/stamp: glMatrix-0.9.5.min.js glMatrixPlugin.js
	opa-plugin-builder -o glMatrixPlugin glMatrix-0.9.5.min.js glMatrixPlugin.js

requestAnimationFramePlugin.opp/stamp: RequestAnimationFramePlugin.js RequestAnimationFrame.js
	opa-plugin-builder -o requestAnimationFramePlugin RequestAnimationFrame.js RequestAnimationFramePlugin.js

webglUtilsPlugin.opp/stamp: webglUtils/webgl-utils.js webglUtils/webglUtilsPlugin.js
	opa-plugin-builder --build-dir opps -o webglUtilsPlugin webglUtils/webgl-utils.js webglUtils/webglUtilsPlugin.js