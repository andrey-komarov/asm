#!/bin/sh

yasm -f elf32 -g dwarf2 $1.asm && gcc -o $1 $1.o -m32 && ./$1
