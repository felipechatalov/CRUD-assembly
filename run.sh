#!/usr/bin/bash

echo "Assembling CRUD..."
as --32 -gstabs main.s -o main.o

echo "Linking CRUD..."
ld -m elf_i386 main.o -l c -dynamic-linker /lib/ld-linux.so.2 -o main

echo "Running CRUD..."
./main