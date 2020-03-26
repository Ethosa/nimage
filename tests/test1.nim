# author: Ethosa
import nimage

var img = ni_create(256, 256, RGBA)

img.fill(0x262a32ff'u32)

img.hline(64, 256-64, 128, 0xf2f2f7ff'u32)
img.vline(128, 64, 256-64, 0xf2f2f7ff'u32)
img.line(64, 64, 256-64, 256-64, 0xf2f2f7ff'u32)

img.save("test1.bmp", IMG_BMP)
