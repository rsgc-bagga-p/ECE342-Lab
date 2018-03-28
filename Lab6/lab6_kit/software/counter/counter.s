// SW 0x2000
// LEDR 0x2010
// QUAD_HEX_DECODE 0x2020

mvi r0, 0x00
mvhi r0, 0x20
mvi r1, 0x10
mvhi r1, 0x20
mvi r2, 0x20
mvhi r2, 0x20

// initalize counter
mvi r3, 0x00
st r3, r2

counter_loop:
ld r4, r0
st r4, r1
mvi r5, 0x00

	delay_loop:
	//mvi r6, 0x00
	
	//	inner_loop:
	//	addi r6, 0x01
	//	cmpi r6, 0xff
	//	jz inner_continue
	//	j inner_loop
	
	//inner_continue:
	addi r5, 0x01
	cmp r5, r4
	jz delay_continue
	j delay_loop

delay_continue:
addi r3, 0x01
st r3, r2

j counter_loop

