build/hello.bin: build/hello.json build/print.json
	../bin/join build/hello.json build/print.json >build/hello_full.json
	../bin/juice build/hello_full.json build/hello.bin

build/hello.json: build
	../bin/assemble hello.s >build/hello.json

build/print.json: build
	../bin/assemble print.s >build/print.json

build:
	mkdir build

clean:
	rm -rf build