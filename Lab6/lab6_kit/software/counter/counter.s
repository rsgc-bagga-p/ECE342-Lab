// SW 0x2000
// LEDR 0x2010
// QUAD_HEX_DECODE 0x2020

mvi r0, 0x00
mvhi r0, 0x20
mvi r1, 0x10
mvhi r1, 0x20
mvi r2, 0x20
mvhi r2, 0x20

mvi r5, 0xff
//mvhi r5, 0x7f

// initalize counter
counter_init:
mvi r3, 0x00
st r3, r2

counter_loop:
ld r4, r0
st r4, r1

delay_loop:
addi r4, 0x01
cmp r4, r5
//jn delay_loop
jz delay_continue
j delay_loop

delay_continue:
addi r3, 0x01
st r3, r2

//cmp r3, r5
//jn counter_loop
//j counter_init
j counter_loop

