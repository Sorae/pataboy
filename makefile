all: hello-world.o hello-world.gb rgbfix run

hello-world.o: hello-world.asm
	rgbasm -o hello-world.o hello-world.asm

hello-world.gb: hello-world.o
	rgblink -o hello-world.gb hello-world.o

rgbfix: hello-world.gb
	rgbfix -v -p 0xFF hello-world.gb

run:
	java -jar ~/dev/gb/emulicious/emulicious.jar hello-world.gb

clean:
	rm -rf *.o