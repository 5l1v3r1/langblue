all: build/hello.bin build/flipper.bin

build/hello.bin: build/print.json build/gets.json
	langblue-as hello.s >build/hello.json
	langblue-join build/hello.json build/print.json build/gets.json >build/hello_linked.json
	langblue-juice build/hello_linked.json build/hello.bin

build/flipper.bin: build/print.json build/gets.json build/strlen.json build/reverse.json
	langblue-as flipper.s >build/flipper.json
	langblue-join build/flipper.json build/print.json build/gets.json build/strlen.json build/reverse.json >build/flipper_linked.json
	langblue-juice build/flipper_linked.json build/flipper.bin

build/print.json: build
	langblue-as print.s >build/print.json

build/gets.json: build
	langblue-as gets.s >build/gets.json

build/strlen.json: build
	langblue-as strlen.s >build/strlen.json

build/reverse.json: build
	langblue-as reverse.s >build/reverse.json

build:
	mkdir build

clean:
	rm -rf build