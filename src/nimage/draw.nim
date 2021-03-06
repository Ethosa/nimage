# author: Ethosa
import math

import objects
import utils


# ---- PRIVATE ---- #
var default_positions: seq[array[2, uint32]]

proc cosin(q, r, x, y: float): array[2, uint32] {.cdecl.} =
  let
    xt = (r * cos(q) + x).int
    yt = (r * sin(q) + y).int
    x_end = if xt > 0: (xt).uint32 else: (xt * -2).uint32
    y_end = if yt > 0: (yt).uint32 else: (yt * -2).uint32
  return [x_end, y_end]

proc distance(x1, y1, x2, y2: uint32): float =
  return math.sqrt(
    math.pow(x2.float - x1.float, 2.0) + math.pow(y2.float - y1.float, 2.0)
  )


template setpixel(img, x, y, color, positions: untyped): untyped =
  if [`x`, `y`] notin `positions`:
    `img`.pixel(`x`, `y`, `color`)
    `positions`.add([`x`, `y`])


# ---- PUBLIC ---- #
proc rgb*(r, g, b: uint32): uint32 {.inline, cdecl.} =
  ## RGB color to uint32.
  return (r shl 24) or (g shl 16) or (b shl 8) or 255

proc rgba*(r, g, b, a: uint32): uint32 {.inline, cdecl.} =
  ## RGBA color to uint32
  return (r shl 24) or (g shl 16) or (b shl 8) or (a and 255)


proc fill*(img: Nimage, color: uint32) =
  ## Fills image to specific color.
  ##
  ## Aruments:
  ## - `color` - fill color.
  for y in 0..<img.h:
    for x in 0..<img.w:
      img.pixels[y*img.w + x] = color


proc pixel*(img: Nimage, x, y, color: uint32) {.inline.} =
  ## Draws pixel at x,y position. Supports Alpha-channel.
  ##
  ## Arguments:
  ## - `x` - position at X coord.
  ## - `y` - position at Y coord.
  img.pixels[y*img.w + x] = calc_alpha(color, img.pixels[y*img.w + x])


proc hline*(img: Nimage, x, x1, y, color: uint32) {.inline.} =
  ## Draws vertical line from x,y to x,y1 position.
  ##
  ## Arguments:
  ## - `x` - first position at X coord.
  ## - `x1` - second position at X coord.
  ## - `y` - position at X coord.
  ## - `color` - fill color.
  if x > x1:
    for i in x1..x:
      img.pixel(i, y, color)
  else:
    for i in x..x1:
      img.pixel(i, y, color)


proc vline*(img: Nimage, x, y, y1, color: uint32) {.inline.} =
  ## Draws vertical line from x,y to x,y1 position.
  ##
  ## Arguments:
  ## - `x` - position at X coord.
  ## - `y` - first position at X coord.
  ## - `y1` - second position at X coord.
  ## - `color` - fill color.
  if y > y1:
    for i in y1..y:
      img.pixel(x, i, color)
  else:
    for i in y..y1:
      img.pixel(x, i, color)


proc line*(img: Nimage, x1, y1, x2, y2, color: uint32,
           ps: ptr seq[array[2, uint32]] = default_positions.addr) {.inline.} =
  ## Draws line at nimage object.
  ##
  ## Arguments:
  ## - `x1` - first position at X coord.
  ## - `y1` - first position at Y coord.
  ## - `x2` - second position at X coord.
  ## - `y2` - second position at Y coord.
  ## - `color` - fill color.
  let
    nb_points =
      if x1 + x2 > y1 + y2:
        x1 + x2
      else:
        y1 + y2
    x_spacing = (x2.float-x1.float) / (nb_points.float)
    y_spacing = (y2.float-y1.float) / (nb_points.float)
  for i in 1..nb_points:
    let
      x = x1 + (i.float * x_spacing).uint32
      y = y1 + (i.float * y_spacing).uint32
    if [x, y] notin ps[]:
      img.pixel(x, y, color)
      ps[].add([x, y])
  if ps == default_positions.addr:
    ps[] = @[]


proc fill_rect*(img: Nimage, x1, y1, x2, y2, color: uint32) =
  ## Draws the filled rect in nimage object.
  ##
  ## Arguments:
  ## - `x1` - first position at X coord.
  ## - `y1` - first position at Y coord.
  ## - `x2` - second position at X coord.
  ## - `y2` - second position at Y coord.
  ## - `color` - fill color.
  for y in y1..y2:
    for x in x1..x2:
      img.pixel(x, y, color)


proc rect*(img: Nimage, x1, y1, x2, y2, color: uint32) =
  ## Draws the rect in nimage object.
  ##
  ## Arguments:
  ## - `x1` - first position at X coord.
  ## - `y1` - first position at Y coord.
  ## - `x2` - second position at X coord.
  ## - `y2` - second position at Y coord.
  ## - `color` - fill color.
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
  ## - `color` - fill color.
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
      pos = cosin(t, r, x1, y1)
      x_end = pos[0]
      y_end = pos[1]
    setpixel(img, x_end, y_end, color, positions)
    t += step


proc fill_circle*(img: Nimage, x, y, radius, color: uint32) =
  ## Draws filled circle at x,y position with `radius`.
  ##
  ## Arguments:
  ## - `x` - circle center at x.
  ## - `y` - circle center at y.
  ## - `radius` - circle radius.
  ## - `color` - fill color.
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
        pos = cosin(t, r, x1, y1)
        x_end = pos[0]
        y_end = pos[1]
      setpixel(img, x_end, y_end, color, positions)
      t += step
    r -= 1.0


proc pie*(img: Nimage, x, y, radius, start, finish, color: uint32) =
  ## Draws the pie at nimage object.
  ##
  ## Arguments:
  ## - `x` - pie center at X coord.
  ## - `y` - pie center at Y coord.
  ## - `radius` - pie radius.
  ## - `start` - start angle.
  ## - `finish` - finish angle.
  ## - `color` - fill color.
  let
    step = 0.002
    r = radius.float
    x1 = x.float
    y1 = y.float
    res = PI*2
  var
    t = res / 360.0 * start.float
    f = res / 360.0 * finish.float
    positions = newSeq[array[2, uint32]]((res / step + 2.0).int)
  while t < f:
    let
      pos = cosin(t, r, x1, y1)
      x_end = pos[0]
      y_end = pos[1]
    setpixel(img, x_end, y_end, color, positions)
    t += step
  # --- Draw lines --- #
  # - First - #
  var pos = cosin(res / 360.0 * start.float, r, x1, y1)
  img.line(pos[0], pos[1], x, y, color, positions.addr)
  # - Second - #
  pos = cosin(f, r, x1, y1)
  img.line(pos[0], pos[1], x, y, color, positions.addr)


proc fill_pie*(img: Nimage, x, y, radius, start, finish, color: uint32) =
  ## Draws the filled pie at nimage object.
  ##
  ## Arguments:
  ## - `x` - pie center at X coord.
  ## - `y` - pie center at Y coord.
  ## - `radius` - pie radius.
  ## - `start` - start angle.
  ## - `finish` - finish angle.
  ## - `color` - fill color.
  let
    step = 0.015
    x1 = x.float
    y1 = y.float
    res = PI*2
  var
    t = res / 360.0 * start.float
    f = res / 360.0 * finish.float
    r = radius.float
    positions = newSeq[array[2, uint32]]((res / step + 2.0).int)
  while r > 0.0:
    t = res / 360.0 * start.float
    while t < f:
      let
        pos = cosin(t, r, x1, y1)
        x_end = pos[0]
        y_end = pos[1]
      setpixel(img, x_end, y_end, color, positions)
      t += step
    r -= 1.0
  # --- Draw lines --- #
  # - First - #
  var pos = cosin(res / 360.0 * start.float, r, x1, y1)
  img.line(pos[0], pos[1], x, y, color, positions.addr)
  # - Second - #
  pos = cosin(f, r, x1, y1)
  img.line(pos[0], pos[1], x, y, color, positions.addr)


proc triangle*(img: Nimage, x1, y1, x2, y2, x3, y3, color: uint32) =
  ## Draws triangle at nimage object.
  ##
  ## Arguments:
  ## - `x1` - first position at X coord.
  ## - `y1` - first position at Y coord.
  ## - `x2` - second position at X coord.
  ## - `y2` - second position at Y coord.
  ## - `x3` - third position at X coord.
  ## - `y3` - third position at Y coord.
  ## - `color` - fill color.
  var positions: seq[array[2, uint32]]
  img.line(x1, y1, x2, y2, color, positions.addr)
  img.line(x2, y2, x3, y3, color, positions.addr)
  img.line(x1, y1, x3, y3, color, positions.addr)


proc fill_triangle*(img: Nimage, x1, y1, x2, y2, x3, y3, color: uint32) =
  ## Draws triangle at nimage object.
  ##
  ## Arguments:
  ## - `x1` - first position at X coord.
  ## - `y1` - first position at Y coord.
  ## - `x2` - second position at X coord.
  ## - `y2` - second position at Y coord.
  ## - `x3` - third position at X coord.
  ## - `y3` - third position at Y coord.
  ## - `color` - fill color.
  var positions: seq[array[2, uint32]]
  img.line(x1, y1, x2, y2, color, positions.addr)
  img.line(x2, y2, x3, y3, color, positions.addr)
  img.line(x1, y1, x3, y3, color, positions.addr)
  let
    center_x = ((x1 + x2 + x3).float / 3).uint32
    center_y = ((y1 + y2 + y3).float / 3).uint32
    a = distance(x1, y1, x2, y2)
    b = distance(x2, y2, x3, y3)
    c = distance(x1, y1, x3, y3)
    p = (a + b + c) / 2
    S = (math.sqrt(p * (p - a) * (p - b) * (p - c))).uint
  var q = newSeq[array[2, uint32]](S)
  q.add([center_x, center_y])
  while q.len > 0:
    let
      x = q[0][0]
      y = q[0][1]
    if [x, y] notin positions and x > 0'u32 and x < 65535'u32 and y > 0'u32 and y < 65535'u32:
      q.add([x+1, y])
      q.add([x-1, y])
      q.add([x, y+1])
      q.add([x, y-1])
      positions.add([x, y])
      img.pixel(x, y, color)
    q.delete(0)
