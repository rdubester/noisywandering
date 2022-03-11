float easeInOutSin(float x) {
  return -cos(PI * x - 1) / 2;
}

float easeInOutQuad(float x) {
  return x < 0.5 ? 2 * x * x : 1 - pow(-2 * x + 2, 2) / 2;
}
