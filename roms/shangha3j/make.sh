#!/bin/sh

z80asm snd.s -o tmp
head -c 65536 /dev/zero >> tmp
head -c 65536 tmp > snd.rom
rm tmp

