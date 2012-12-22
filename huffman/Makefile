all:
	make -B pack
	make -B unpack

pack:
	yasm -f elf32 huffman.asm
	gcc huffman.o -o pack -m32

unpack:
	yasm -f elf32 unhuffman.asm
	gcc -c unhuffman.c -o unhuffman_c.o -m32
	gcc unhuffman.o unhuffman_c.o -o unpack -m32

test:
	gcc -c a.c -m32
	yasm -f elf32 add.asm
	gcc -m32 a.o add.o -o ololo

check:
	make -B all
	./pack a.hz test
	rm test2 || echo "no test2"
	./unpack test2 a.hz
	diff test test2
