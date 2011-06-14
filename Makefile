
all: build
run:
	./main.exe -d
build: main.exe

main.exe:
	cd plugins && make all
	opa --project-root '$(shell pwd)' --js-no-cleanup --js-no-global-inlining --js-no-local-inlining --js-no-local-renaming \
		src/common/fresh.opa src/common/sessionExt.opa src/common/observer.opa \
		plugins/requestAnimationFramePlugin.opp src/requestAnimationFrame.opa \
		plugins/webglPlugin.opp src/webgl/webgl.opa \
		plugins/opps/webglUtilsPlugin.opp src/webglUtils/webglUtils.opa \
		plugins/glMatrixPlugin.opp src/glMatrix/glMatrix.opa \
		src/custom_shaders.opa \
		src/engine/stack.opa src/engine/objects.opa src/engine/engine.opa \
		src/modeler/modeler.opa \
		src/pages/page_welcome.opa \
		src/main.opa
	mv src/main.exe main.exe



clean:
	cd plugins && make clean
	rm -rf _build _tracks \.mlstate main.exe src/main.exe *\.opx *\.opx.broken

.PHONY: all run build clean main.exe
