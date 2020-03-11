package main

import (
	"fmt"
	"image/png"
	"log"
	"os"
	"strings"
)

func main() {
	pngFile, err := os.Open("Lucon_aa_txt_16x16.png")
	if err != nil {
		log.Fatalf("Whoops: %v", err)
	}
	defer func(f *os.File) {
		err := f.Close()
		if err != nil {
			log.Fatalf("Whoops: %v", err)
		}
	}(pngFile)
	img, err := png.Decode(pngFile)
	if err != nil {
		log.Fatalf("Whoops: %v", err)
	}

	fmt.Println(`.global chars

.text

#################################################################################
#################################################################################
#### Don't put in a .data section since that will bloat the executable since ####
#### .data section will be aligned to a page boundary                        ####
#################################################################################
#################################################################################
# .data  <<------ NO!!!


# -------------------------------
# THE 'ZX SPECTRUM CHARACTER SET'
# -------------------------------

.align 5
R1_3D00:
chars:`)

	for c := 32; c < 128; c++ {
		x := c % 16
		y := c / 16
		fmt.Println("")
		char := string(rune(c))
		if c == 127 {
			char = "(c)"
		}
		fmt.Printf("# 0x%02X - Character: '%v' %v CHR$(%v)\n\n", c, char, strings.Repeat(" ", 9-len(char)), c)
		for j := y * 16; j < (y+1)*16; j++ {
			fmt.Print(`        .hword    0b`)

			for i := x * 16; i < (x+1)*16; i++ {
				r, g, b, a := img.At(i, j).RGBA()
				if r+g+b+a < 20000 {
					fmt.Print("0")
				} else {
					fmt.Print("1")
				}
			}
			fmt.Println("")
		}
		//		fmt.Println("")
	}
}
