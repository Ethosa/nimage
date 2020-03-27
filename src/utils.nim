# author: Ethosa

proc calc_alpha*(src, dst: uint32): uint32 =
  ## Mix scr and dst colors.
  var
    dst_r, dst_g, dst_b: float
    src_r, src_g, src_b, src_a: float
  dst_b = ((dst shr 8) and 255).float
  dst_g = ((dst shr 16) and 255).float
  dst_r = ((dst shr 24) and 255).float

  src_a = (src and 255).float
  src_b = ((src shr 8) and 255).float
  src_g = ((src shr 16) and 255).float
  src_r = ((src shr 24) and 255).float
  var
    a = src_a.float * (1.0/255.0)
    r, g, b: uint32

  r = (dst_r*(1.0-a) + src_r*a).uint32
  g = (dst_g*(1.0-a) + src_g*a).uint32
  b = (dst_b*(1.0-a) + src_b*a).uint32

  return (r shl 24) or (g shl 16) or (b shl 8) or 255
