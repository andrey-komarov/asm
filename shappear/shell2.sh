#!/bin/bash
yasm -f elf32 shell2.asm
ld -melf_i386 shell2.o -o shell2
