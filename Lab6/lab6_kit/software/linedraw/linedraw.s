// SW 0x2000
// LDA 0x3000

// Set stall mode
mvi r0, 0x00
mvhi r0, 0x30
mvi r1, 0x00
st r1, r0

// start point: r2 = lower half of y0 x0 (upper half always zero)
mvi r2, 0x00

// end point: r4, r3 = y1 x1
mvi r3, 0x00
mvhi r3, 0xa2
mvi r4, 0x01

draw_loop:
addi r2, 0x01
addi r3, 0x01

// value of r2 when line reaches edge of screen
mvi r6, 0x4f
mvhi r6, 0x01
cmp r2, r6
jz reset
j continue

reset:
mvi r2, 0x00
mvi r3, 0x00
mvhi r3, 0xa2
mvi r4, 0x01

continue:
// store start point
mvi r0, 0x0c
mvhi r0, 0x30
st r2, r0
mvi r0, 0x0e
mvhi r0, 0x30
st r1, r0

// store end point
mvi r0, 0x10
mvhi r0, 0x30
st r3, r0
mvi r0, 0x12
mvhi r0, 0x30
st r4, r0

// load and store colour
mvi r0, 0x00
mvhi r0, 0x20
ld r5, r0
mvi r0, 0x14
mvhi r0, 0x30
st r5, r0

// go
mvi r0, 0x08
mvhi r0, 0x30
st r5, r0

// wait for a bit
mvi r6, 0x00
delay_loop:
addi r6, 0x01
cmpi r6, 0xff
jz delay_continue
j delay_loop

delay_continue:
// draw black line to cover previous line
mvi r0, 0x0c
mvhi r0, 0x30
st r2, r0
mvi r0, 0x0e
mvhi r0, 0x30
st r1, r0

mvi r0, 0x10
mvhi r0, 0x30
st r3, r0
mvi r0, 0x12
mvhi r0, 0x30
st r4, r0

mvi r5, 0x00
mvi r0, 0x14
mvhi r0, 0x30
st r5, r0

mvi r0, 0x08
mvhi r0, 0x30
st r5, r0

j draw_loop


