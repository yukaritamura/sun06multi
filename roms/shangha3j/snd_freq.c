#include <stdio.h>
#include <stdlib.h>
#include <math.h>

double clock = 8000000.0;

void fnum(double freq, int* b, double* fnum) {
  double base = 144.0 * freq * pow(2.0, 20.0) / clock;
  for (*b = 0; *b < 8; *b = *b + 1) {
    *fnum = base / pow(2.0, *b - 1);
    if (*fnum < 2047.5)
      return;
  }
  *fnum =  (double)0x3ff;
  *b = 7;
}

double psgclk = 1500000.0;

double psgfreq(int tp) {
  double t = tp ? (double)tp : 0.1;
  return psgclk / 16.0 / t;
}

int main(int argc, char** argv) {
  int b;
  double f;
  for (int tp = 0; tp < 0x1000; ++tp) {
    fnum(psgfreq(tp), &b, &f);
    int v = (int)floor(f + 0.5) + (b << 11);
    printf("defw 0x%02x%02x\n", (v >> 8) & 0xff, v & 0xff);
  }
  return 0;
}

