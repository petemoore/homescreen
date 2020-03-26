#!/bin/bash -eu

cd "$(dirname "${0}")"
rm -f dist/kernel8.img
mkdir -p dist
aarch64-unknown-linux-gnu-as -g -o homescreen.o homescreen.s
aarch64-unknown-linux-gnu-as -g -o uart.o uart.s
aarch64-unknown-linux-gnu-ld -e 0x80000 -M -o homescreen.elf homescreen.o uart.o
aarch64-unknown-linux-gnu-objcopy --set-start=0x80000 homescreen.elf -O binary dist/kernel8.img
aarch64-unknown-linux-gnu-readelf -a homescreen.elf
aarch64-unknown-linux-gnu-objdump -b binary -z --adjust-vma=0x80000 -maarch64 -D dist/kernel8.img
rm *.o homescreen.elf
[ -f dist/LICENCE.broadcom ] || wget -q -O dist/LICENCE.broadcom https://github.com/raspberrypi/firmware/blob/d5b8d8d7cce3f3eecb24c20a55cc50a48e3d5f4e/boot/LICENCE.broadcom?raw=true
[ -f dist/bootcode.bin ] || wget -q -O dist/bootcode.bin https://github.com/raspberrypi/firmware/blob/d5b8d8d7cce3f3eecb24c20a55cc50a48e3d5f4e/boot/bootcode.bin?raw=true
[ -f dist/fixup.dat ] || wget -q -O dist/fixup.dat https://github.com/raspberrypi/firmware/blob/d5b8d8d7cce3f3eecb24c20a55cc50a48e3d5f4e/boot/fixup.dat?raw=true
[ -f dist/start.elf ] || wget -q -O dist/start.elf https://github.com/raspberrypi/firmware/blob/d5b8d8d7cce3f3eecb24c20a55cc50a48e3d5f4e/boot/start.elf?raw=true
