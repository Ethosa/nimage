# author: Ethosa

proc calc_alpha*(src, dst: uint32): uint32 =
  ## Mix scr and dst colors.
  var
    dst_r, dst_g, dst_b: uint32
    src_r, src_g, src_b, src_a: uint32
  dst_b = (dst and 255).uint32
  dst_g = ((dst shr 8) and 255).uint32
  dst_r = ((dst shr 16) and 255).uint32

  src_b = (src and 255).uint32
  src_g = ((src shr 8) and 255).uint32
  src_r = ((src shr 16) and 255).uint32
  src_a = ((src shr 24) and 255).uint32
  var
    a = src_a.float * (1.0/255.0)
    r, g, b: uint32

  r = (dst_r.float*(1.0-a) + src_r.float*a).uint32
  g = (dst_g.float*(1.0-a) + src_g.float*a).uint32
  b = (dst_b.float*(1.0-a) + src_b.float*a).uint32

  return (255 shl 24).uint32 or (r shl 16) or (g shl 8) or b
