# author: Ethosa
import nimage

var img = newNimage(256, 256)

img.fill(0x262a32ff'u32)

img.hline(64, 256-64, 128, 0xf2f2f7ff'u32)
img.vline(128, 64, 256-64, 0xf2f2f7ff'u32)
img.line(64, 64, 256-64, 256-64, 0xf2f2f7ff'u32)
img.rect(64, 64, 256-64, 256-64, 0xf2f2f745'u32)
img.fill_rect(64, 64, 256-64, 256-64, 0xf2f2f745'u32)

img.circle(64, 64, 32, 0xf77ff780'u32)
img.fill_circle(64, 256-64, 32, 0xf77ff780'u32)

img.save("test1.bmp", IMG_BMP)
