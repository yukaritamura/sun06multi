#!/bin/sh

(cd ./blocken; ./patch.sh)
(cd ./shangha3j; ./patch.sh; ./make.sh)

interleave /m ./blocken/ic32j.bin.patched ./blocken/ic31j.bin.patched ./blocken.prg
interleave /m ./heberpop/hbp_ic31.ic31 ./heberpop/hbp_ic32.ic32 ./heberpop.prg
interleave /m ./shangha3j/s3j_v11.ic3 ./shangha3j/s3j_v11.ic2 ./shangha3j.prg

cat \
  ./heberpop/hbp_ic98_v1.0.ic98 \
  ./heberpop/hbp_ic99_v1.0.ic99 \
  ./heberpop/hbp_ic100_v1.0.ic100 \
  ./heberpop/hbp_ic101_v1.0.ic101 > gfx.u1

cat ./blocken/ic98j.bin ./blocken/ic99j.bin > gfx.u2

cat ./shangha3j/s3j_char-a1.ic43 > gfx.u3

cat ./heberpop/hbp_ic102_v1.0.ic102 ./blocken/ic100j.bin > gfx.u4

cat \
  ./heberpop/hbp_ic34_v1.0.ic34 \
  ./blocken/ic34.bin \
  ./shangha3j/snd.rom \
  ./shangha3j/snd.rom > snd.u1

cat \
  ./heberpop/hbp_ic53_v1.0.ic53 \
  ./blocken/ic53.bin \
  ./shangha3j/s3j_v10.ic75 \
  ./shangha3j/s3j_v10.ic75 \
  ./shangha3j/s3j_v10.ic75 \
  ./shangha3j/s3j_v10.ic75 > snd.u2

cat heberpop.prg \
  blocken.prg blocken.prg blocken.prg blocken.prg \
  shangha3j.prg shangha3j.prg shangha3j.prg shangha3j.prg > prg.u1
