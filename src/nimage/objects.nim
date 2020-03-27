# author: Ethosa
type
  NimageMode* {.pure.} = enum
    IMG_BMP
  Nimage* = ref object
    w*, h*: uint32
    pixels*: seq[uint32]
