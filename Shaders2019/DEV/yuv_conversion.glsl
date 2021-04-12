vec3 yuv(vec3 col, int op) {
  mat3 rgb2yuv = mat3(
    .299, .587, .114,
    -.14713, -.28886, .436,
    .615, -.51499, -.10001
  );

  mat3 yuv2rgb = mat3(
    1, 0, 1.13983,
    1, -.39465, -.58060,
    1, 2.03211, 0
  );

  if (op == 0) {
    return col * rgb2yuv;
  } else {
    return col * yuv2rgb;
  }
}
