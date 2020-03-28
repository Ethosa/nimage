# author: Ethosa
import nimage


var img = newNimage(256, 256)

img.triangle(16, 16, 128, 64, 64, 128, 0xf77ff755'u32)

img.fill_triangle(128, 128-16, 128+64, 128, 256-16, 256-16, 0xf77ff755'u32)

img.save("test2.bmp")
