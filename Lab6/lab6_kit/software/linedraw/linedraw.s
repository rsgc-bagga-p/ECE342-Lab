// SW 0x2000
// LDA 0x3000

mvi r0, 0x00
mvhi r0, 0x30
mvi r1, 0x00
st r1, r0

// y0 x0
mvi r2, 0x00

mvi r0, 0x0c
mvhi r0, 0x30
st r2, r0

// y1 x1
mvi r3, 0x00
mvhi r3, 0xa2
mvi r4, 0x01

mvi r0, 0x10
mvhi r0, 0x30
st r3, r0
mvi r0, 0x12
mvhi r0, 0x30
st r4, r0

mvi r6, 0x31
mvhi r6, 0xa3

draw_loop:
addi r2, 0x01
addi r3, 0x01

cmp r2, r6
jz reset
j continue

reset:
mvi r2, 0x00
mvi r3, 0x00
mvhi r3, 0xa2
mvi r4, 0x01

continue:
mvi r0, 0x0c
mvhi r0, 0x30
st r2, r0
mvi r0, 0x10
mvhi r0, 0x30
st r3, r0

mvi r0, 0x00
mvhi r0, 0x20
ld r5, r0
mvi r0, 0x14
mvhi r0, 0x30
st r5, r0

mvi r0, 0x08
mvhi r0, 0x30
st r5, r0

j draw_loop


