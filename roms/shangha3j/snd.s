OUT_FM_ADDR_123_W: equ 0
OUT_FM_DATA_123_W: equ 1
OUT_FM_ADDR_456_W: equ 2
OUT_FM_DATA_456_W: equ 3
IN_FM_STATUS_R: equ 0
OUT_OKI: equ 0x80
IN_LATCH: equ 0xc0

PSG_ADDR: equ 0xf800
PSG_DATA: equ 0xf801
OKI_DATA: equ 0xf802

PSG_R0: equ 0xf810
PSG_R1: equ 0xf811
PSG_R2: equ 0xf812
PSG_R3: equ 0xf813
PSG_R4: equ 0xf814
PSG_R5: equ 0xf815

; 0xf900-0xf915: PSG registers buffer
REGS_HIGH: equ 0xf9
REGS_BUFF: equ 0xf900
REGS_COPY: equ 0xf910

  org 0x0
start:
  di
  ld sp, 0x0000
  call init
  ei
  jp main

padding:
  defs 0x2d

; CMD
; 0x8n: Sets PSG addr to n
; 0x9n: Sets PSG high data to n
; 0xAn: Sets PSG low data to n, and executes PSG write
; 0xBn: Sets OKI high data to n
; 0xCn: Sets OKI low data to n, and execute OKI write
; a, b: tmp
; d: OKI high
; c: PSG addr
; e: PSG high
int:
  di                ; 4
  ex af, af'        ; 4
  exx               ; 4
  in a, (IN_LATCH)  ; 11
  ld b, a           ; 4
  and 0xf0          ; 7
  cp 0x90           ; 7 (41)
  jr c, cmd8        ; 12/7
  jr z, cmd9        ; 12/7
  cp 0xb0           ; 7 (62)
  jr c, cmda        ; 12/7
  jr z, cmdb        ; 12/7
cmdc:  ; (76)
  ld a, b           ; 4
  and 0x0f          ; 7
  or d              ; 4
  out (OUT_OKI), a  ; 11
  jr ret            ; 12 (76+38+[26]) => 140
cmd8:  ; (53)
  ld a, b           ; 4
  and 0x0f          ; 7
  ld c, a           ; 4
  jr ret            ; 12 (53+27+26) => 106)
cmd9:  ; (60)
  ld a, b           ; 4
  sla a             ; 4
  sla a             ; 4
  sla a             ; 4
  sla a             ; 4
  ld e, a           ; 4
  jr ret            ; 12 (68+36+26) => 130
cmda:  ; (74)
  ld a, b           ; 4
  and 0x0f          ; 7
  or e              ; 4
  ld h, REGS_HIGH   ; 7
  ld l, c           ; 4
  ld (hl), a        ; 10
  jr ret            ; 12 (74+36+26) => 140
cmdb:  ; (81)
  ld a, b           ; 4
  sla a             ; 4
  sla a             ; 4
  sla a             ; 4
  sla a             ; 4
  ld d, a           ; 4 (81+24+[26]) => 131
ret:
  exx               ; 4
  ex af, af'        ; 4
  ei                ; 4
  reti              ; 14 (26)

main:
  ld ix, REGS_BUFF
  ld iy, REGS_COPY
regs_0:
  ld b, (ix+0)
  ld a, (iy+0)
  cp b
  jr nz, update_ch1_freq
regs_1:
  ld b, (ix+1)
  ld a, (iy+1)
  cp b
  jr z, regs_2
update_ch1_freq:
  ld a, (ix+1)
  ld (iy+1), a
  and 0x0f
  ld d, a
  ld e, (ix+0)
  ld (iy+0), e
  ld hl, fm_freq
  add hl, de
  add hl, de
  ld b, (hl)
  inc hl
  ld d, (hl)
  ld e, 0xa4
  call fm_wr
  ld d, b
  ld e, 0xa0
  call fm_wr
regs_2:
  ld b, (ix+2)
  ld a, (iy+2)
  cp b
  jr nz, update_ch2_freq
regs_3:
  ld b, (ix+3)
  ld a, (iy+3)
  cp b
  jr z, regs_4
update_ch2_freq:
  ld a, (ix+3)
  ld (iy+3), a
  and 0x0f
  ld d, a
  ld e, (ix+2)
  ld (iy+2), e
  ld hl, fm_freq
  add hl, de
  add hl, de
  ld b, (hl)
  inc hl
  ld d, (hl)
  ld e, 0xa5
  call fm_wr
  ld d, b
  ld e, 0xa1
  call fm_wr
regs_4:
  ld b, (ix+4)
  ld a, (iy+4)
  cp b
  jr nz, update_ch3_freq
regs_5:
  ld b, (ix+5)
  ld a, (iy+5)
  cp b
  jr z, regs_6
update_ch3_freq:
  ld a, (ix+5)
  ld (iy+5), a
  and 0x0f
  ld d, a
  ld e, (ix+4)
  ld (iy+4), e
  ld hl, fm_freq
  add hl, de
  add hl, de
  ld b, (hl)
  inc hl
  ld d, (hl)
  ld e, 0xa6
  call fm_wr
  ld d, b
  ld e, 0xa2
  call fm_wr
regs_6:
  ; TODO
regs_7:
  ld b, (ix+7)
  ld a, (iy+7)
  cp b
  jr z, regs_8
  ld (iy+7), b
  bit 0, b
  jr z, tone_on_ch1
disable_ch1:
  ld d, 0
  jr mixer_ch1
tone_on_ch1:
  ld d, 0xc0
mixer_ch1:
  ld e, 0xb4
  call fm_wr
  bit 1, b
  jr z, tone_on_ch2
disable_ch2:
  ld d, 0
  jr mixer_ch2
tone_on_ch2:
  ld d, 0xc0
mixer_ch2:
  ld e, 0xb5
  call fm_wr
  bit 2, b
  jr z, tone_on_ch3
disable_ch3:
  ld d, 0
  jr mixer_ch3
tone_on_ch3:
  ld d, 0xc0
mixer_ch3:
  ld e, 0xb6
  call fm_wr
regs_8:
  ld a, (ix+8)
  ld d, (iy+8)
  cp d
  jr z, regs_9
  ld (iy+8), a
  and 0x0f
  jr z, mute_ch1
  ld d, a
  ld a, 20 ; 15
  sub d
  sla a
  ld d, a
  ld e, 0x40
  call fm_wr
  ld a, 3 ; 6
  add a, d
  ld d, a
  ld e, 0x44
  call fm_wr
  ld a, 2 ; 3
  add a, d
  ld d, a
  ld e, 0x48
  call fm_wr
  ld a, 1 ; 2
  add a, d
  ld d, a
  ld e, 0x4c
  call fm_wr
  jr regs_9
mute_ch1:
  ld d, 0x7f
  ld e, 0x40
  call fm_wr
  ld e, 0x44
  call fm_wr
  ld e, 0x48
  call fm_wr
  ld e, 0x4c
  call fm_wr
regs_9:
  ld a, (ix+9)
  ld d, (iy+9)
  cp d
  jr z, regs_10
  ld (iy+9), a
  and 0x0f
  jr z, mute_ch2
  ld d, a
  ld a, 20 
  sub d
  sla a
  ld d, a
  ld e, 0x41
  call fm_wr
  ld a, 3
  add a, d
  ld d, a
  ld e, 0x45
  call fm_wr
  ld a, 2
  add a, d
  ld d, a
  ld e, 0x49
  call fm_wr
  ld a, 1
  add a, d
  ld d, a
  ld e, 0x4d
  call fm_wr
  jr regs_10
mute_ch2:
  ld d, 0x7f
  ld e, 0x41
  call fm_wr
  ld e, 0x45
  call fm_wr
  ld e, 0x49
  call fm_wr
  ld e, 0x4d
  call fm_wr
regs_10:
  ld a, (ix+10)
  ld d, (iy+10)
  cp d
  jr z, regs_11
  ld (iy+10), a
  and 0x0f
  jr z, mute_ch3
  ld d, a
  ld a, 20 
  sub d
  sla a
  ld d, a
  ld e, 0x42
  call fm_wr
  ld a, 3
  add a, d
  ld d, a
  ld e, 0x46
  call fm_wr
  ld a, 2
  add a, d
  ld d, a
  ld e, 0x4a
  call fm_wr
  ld a, 1
  add a, d
  ld d, a
  ld e, 0x4e
  call fm_wr
  jr regs_11
mute_ch3:
  ld d, 0x7f
  ld e, 0x42
  call fm_wr
  ld e, 0x46
  call fm_wr
  ld e, 0x4a
  call fm_wr
  ld e, 0x4e
  call fm_wr
regs_11:
  ; TODO
regs_12:
  ; TODO
regs_13:
  ; TODO
  jp main

fm_wr: ; !a, d = data, e = addr
  call fm_wait
  ld a, e
  out (OUT_FM_ADDR_123_W), a
  call fm_wait
  ld a, d
  out (OUT_FM_DATA_123_W), a
  ret

fm_wait: ; !a
  in a, (IN_FM_STATUS_R)
  bit 7, a
  jr nz, fm_wait
  ret

init:
  ld hl, fm_init_data
  ld b, (fm_init_data_end - fm_init_data) / 2
init_loop:
  ld e, (hl)
  inc hl
  ld d, (hl)
  inc hl
  call fm_wr
  djnz init_loop
  ld hl, REGS_BUFF
  ld b, 32
  xor a
meminit_loop:
  ld (hl), a
  inc hl
  djnz meminit_loop
  ret

fm_init_data:
  ; FB 1, Alg 7
  defw 0x0fb0
  defw 0x0fb1
  defw 0x0fb2
  ; Pan C, AMS Off, PMS Off
  defw 0xc0b4
  defw 0xc0b5
  defw 0xc0b6
  ; Detune 0, Multiple 1,3,5,7
  defw 0x0130
  defw 0x0334
  defw 0x0538
  defw 0x073c
  defw 0x0131
  defw 0x0335
  defw 0x0539
  defw 0x073d
  defw 0x0132
  defw 0x0336
  defw 0x053a
  defw 0x073e
  ; TL 127
  defw 0x7f40
  defw 0x7f44
  defw 0x7f48
  defw 0x7f4c
  defw 0x7f41
  defw 0x7f45
  defw 0x7f49
  defw 0x7f4d
  defw 0x7f42
  defw 0x7f46
  defw 0x7f4a
  defw 0x7f4e
  ; KS 0, AR 31
  defw 0x1f50
  defw 0x1f54
  defw 0x1f58
  defw 0x1f5c
  defw 0x1f51
  defw 0x1f55
  defw 0x1f59
  defw 0x1f5d
  defw 0x1f52
  defw 0x1f56
  defw 0x1f5a
  defw 0x1f5e
  ; AMON 0, DR 0
  defw 0x0060
  defw 0x0064
  defw 0x0068
  defw 0x006c
  defw 0x0061
  defw 0x0065
  defw 0x0069
  defw 0x006d
  defw 0x0062
  defw 0x0066
  defw 0x006a
  defw 0x006e
  ; SR 0
  defw 0x0070
  defw 0x0074
  defw 0x0078
  defw 0x007c
  defw 0x0071
  defw 0x0075
  defw 0x0079
  defw 0x007d
  defw 0x0072
  defw 0x0076
  defw 0x007a
  defw 0x007e
  ; SL 0, RR 0
  defw 0x0080
  defw 0x0084
  defw 0x0088
  defw 0x008c
  defw 0x0081
  defw 0x0085
  defw 0x0089
  defw 0x008d
  defw 0x0082
  defw 0x0086
  defw 0x008a
  defw 0x008e
  ; Block 4, F-Num2 4; 0x24
  defw 0x24a4
  defw 0x24a5
  defw 0x24a6
  ; F-Num1 0x0e
  defw 0x0ea0
  defw 0x0ea1
  defw 0x0ea2
  ; Key On
  defw 0xf028  ; Sl4, Sl3, Sl2, Sl1, /, CH[2:0]
  defw 0xf128  ; Sl4, Sl3, Sl2, Sl1, /, CH[2:0]
  defw 0xf228  ; Sl4, Sl3, Sl2, Sl1, /, CH[2:0]
fm_init_data_end:

fm_freq:
  include "snd_freq.h"
