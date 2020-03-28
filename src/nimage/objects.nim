# author: Ethosa
import strutils


type
  NimageMode* {.pure.} = enum
    IMG_BMP
  Nimage* = ref object
    w*, h*: uint32
    pixels*: seq[uint32]


proc newNimage*(w, h: uint32): Nimage =
  ## Creates a new Nimage object
  ##
  ## Arguments:
  ## - `w` - nimage width.
  ## - `h` - nimage height.
  result = Nimage(w: w, h: h, pixels: newSeq[uint32](w*h))
  for y in 0..<result.h:
    for x in 0..<result.w:
      result.pixels[y*result.w + x] = 0x000000ff'u32


proc save*(img: Nimage, filename: string,
           mode: NimageMode = IMG_BMP) =
  ## Saves Nimage object in the file.
  var data: string
  case mode
  of IMG_BMP:
    data.add("BM\x9a\x00\x00\x00\x00\x00\x00\x00")
    data.add("z\x00\x00\x00")
    data.add("l\x00\x00\x00")
    data.add(join(cast[array[4, char]](img.w), ""))
    data.add(join(cast[array[4, char]](img.h), ""))
    data.add("\x01\x00 \x00\x03\x00\x00\x00 \x00")
    data.add("\x00\x00\x13\x0b\x00\x00\x13\x0b\x00")
    data.add("\x00\x00\x00\x00\x00\x00\x00\x00\x00")
    data.add("\x00\x00\xFF\x00\x00\xFF\x00\x00\xFF")
    data.add("\x00\x00\x00\x00\x00\x00\xFF niW\x00")
    data.add("\x00\x00\x00\x00\x00\x00\x00\x00\x00")
    data.add("\x00\x00\x00\x00\x00\x00\x00\x00\x00")
    data.add("\x00\x00\x00\x00\x00\x00\x00\x00\x00")
    data.add("\x00\x00\x00\x00\x00\x00\x00\x00\x00")
    data.add("\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00")
    for y in countdown(img.h.int-1, 0, 1):
      for x in 0..<img.w:
        let
          c = cast[array[4, char]](
            img.pixels[y.uint32*img.w + x.uint32]
          )
        data.add(join([c[1], c[2], c[3], c[0]], ""))

  var file = open(filename, fmWrite)
  file.write(data)
  file.close()
