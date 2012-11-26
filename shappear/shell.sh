#!/bin/bash
yasm -f elf32 shell.asm
ld -melf_i386 shell.o -o shell
