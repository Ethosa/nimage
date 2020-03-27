# author: Ethosa
import strutils
import math

import utils


type
  NimageMode* {.pure.} = enum
    IMG_BMP
  Nimage* = ref object
    w*, h*: uint32
    pixels*: seq[uint32]


proc fill*(img: Nimage, color: uint32) =
  ## Fills image to specific color.
  for y in 0..<img.h:
    for x in 0..<img.w:
      img.pixels[y*img.w + x] = color


proc newNimage*(w, h: uint32): Nimage =
  ## Creates a new Nimage object
  ##
  ## Arguments:
  ## - `w` - nimage width.
  ## - `h` - nimage height.
  result = Nimage(w: w, h: h, pixels: newSeq[uint32](w*h))
  result.fill(0x000000ff'u32)


proc pixel*(img: Nimage, x, y, color: uint32) {.inline.} =
  ## Draws pixel at x,y position.
  img.pixels[y*img.w + x] = calc_alpha(color, img.pixels[y*img.w + x])


proc hline*(img: Nimage, x, x1, y, color: uint32) {.inline.} =
  ## Draws vertical line from x,y to x,y1 position.
  if x > x1:
    for i in x1..x:
      img.pixel(i, y, color)
  else:
    for i in x..x1:
      img.pixel(i, y, color)


proc vline*(img: Nimage, x, y, y1, color: uint32) {.inline.} =
  ## Draws vertical line from x,y to x,y1 position.
  if y > y1:
    for i in y1..y:
      img.pixel(x, i, color)
  else:
    for i in y..y1:
      img.pixel(x, i, color)


proc line*(img: Nimage, x1, y1, x2, y2, color: uint32) {.inline.} =
  let
    nb_points =
      if x1 + x2 > y1 + y2:
        x1 + x2
      else:
        y1 + y2
    x_spacing = (x2.float-x1.float) / (nb_points.float)
    y_spacing = (y2.float-y1.float) / (nb_points.float)
  for i in 1..nb_points:
    img.pixel(
      x1 + (i.float * x_spacing).uint32,
      y1 + (i.float * y_spacing).uint32,
      color
    )


proc fill_rect*(img: Nimage, x1, y1, x2, y2, color: uint32) =
  ## Draws the filled rect in nimage object.
  for y in y1..y2:
    for x in x1..x2:
      img.pixel(x, y, color)


proc rect*(img: Nimage, x1, y1, x2, y2, color: uint32) =
  ## Draws the rect in nimage object.
  img.line(x1, y1, x2, y1, color)
  img.line(x2, y1, x2, y2, color)
  img.line(x1, y1, x1, y2, color)
  img.line(x1, y2, x2, y2, color)


proc circle*(img: Nimage, x, y, radius, color: uint32) =
  ## Draws the circle in nimage object.
  ##
  ## Arguments:
  ## - `x` - circle center at x.
  ## - `y` - circle center at y.
  ## - `radius` - circle radius.
  let
    step = 0.002
    r = radius.float
    x1 = x.float
    y1 = y.float
    res = PI*2
  var
    t = 0.00
    positions = newSeq[array[2, uint32]]((res / step + 2.0).int)
  while t < res:
    let
      xt = (r * cos(t) + x1).int
      yt = (r * sin(t) + y1).int
      x_end = if xt > 0: (xt).uint32 else: (xt * -2).uint32
      y_end = if yt > 0: (yt).uint32 else: (yt * -2).uint32
    if [x_end, y_end] notin positions:
      img.pixel(x_end, y_end, color)
      positions.add([x_end, y_end])
    t += step


proc fill_circle*(img: Nimage, x, y, radius, color: uint32) =
  ## Draws filled circle at x,y position with `radius`.
  let
    step = 0.015
    x1 = x.float
    y1 = y.float
    res = PI*2
  var
    t = 0.00
    r = radius.float
    positions = newSeq[array[2, uint32]]((res / step + 2.0).int)
  while r > 0.0:
    t = 0.00
    while t < res:
      let
        xt = (r * cos(t) + x1).int
        yt = (r * sin(t) + y1).int
        x_end = if xt > 0: (xt).uint32 else: (xt * -2).uint32
        y_end = if yt > 0: (yt).uint32 else: (yt * -2).uint32
      if [x_end, y_end] notin positions:
        img.pixel(x_end, y_end, color)
        positions.add([x_end, y_end])
      t += step
    r -= 1.0


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
    for y in 0..<img.h:
      for x in countdown(img.w.int-1, 0, 1):
        let c = cast[array[4, char]](img.pixels[y*img.w + x.uint32])
        data.add(join([c[1], c[2], c[3], c[0]], ""))

  var file = open(filename, fmWrite)
  file.write(data)
  file.close()

