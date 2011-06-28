
all: build
run:
	./main.exe #-d --display-logs --verbose 6
build: main.exe

publish:
	OPAOPT="--publish-src-code $(OPAOPT)" make build
	strip main.exe
	tar -czf main.exe.tar.gz main.exe
	rsync -vah --progress main.exe.tar.gz webgldemo@webgldemo.iserver.pro:

main.exe:
	cd plugins && make all && cd -
	opa $(OPAOPT) \
		src/common/fresh.opa src/common/sessionExt.opa src/common/observer.opa src/common/colorFloat.opa \
		plugins/requestAnimationFramePlugin.opp src/requestAnimationFrame.opa \
		plugins/webglPlugin.opp src/webgl/webgl.opa \
		plugins/opps/webglUtilsPlugin.opp src/webglUtils/webglUtils.opa \
		plugins/glMatrixPlugin.opp src/glMatrix/glMatrix.opa \
		src/custom_shaders.opa \
		src/engine/stack.opa src/engine/objects.opa src/engine/engine.opa \
		src/modeler/modeler.opa src/modeler/sceneServer.opa src/modeler/guiModeler.opa \
		src/pages/page_welcome.opa \
		src/main.opa
	mv src/main.exe main.exe



clean:
	cd plugins && make clean
	rm -rf _build _tracks \.mlstate main.exe src/main.exe *\.opx *\.opx.broken main.exe.tar.gz

.PHONY: all run build clean main.exe publish
