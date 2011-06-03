
all: build
run:
	./main.exe -d
build: main.exe


main.exe:
	cd plugins && make all
	opa --project-root '$(shell pwd)' \
		plugins/webglPlugin.opp \
		src/webgl/webgl.opa \
		src/main.opa
	mv src/main.exe main.exe



clean:
	cd plugins && make clean
	rm -rf _build _tracks \.mlstate main.exe src/main.exe *\.opx *\.opx.broken

.PHONY: all run build clean main.exe
