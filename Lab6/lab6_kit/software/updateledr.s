// Continuously pull values from 0x2000 (SW)
// Update 0x3000 (LEDR) with pulled values

mvi   r0, 0x00
mvhi  r0, 0x20 // address of SW
mvi   r1, 0x00
mvhi  r1, 0x30 // address of LEDR

loop:
ld    r3, r0   // read SW values
st    r4, r1   // update LEDR to match SW values
j     loop     // do it again
