// SWITCH 0x0001_1000 - 0x0001_100f
// LEDR   0x0001_1010 - 0x0001_101f
// LDA    0x0001_1020 - 0x0001_103f

// SW[0]   Mode - 0/stall, 1/poll
// SW[1]   Direction - 0/CW, 1/CCW
// SW[9:7] Colour

// VGA 335 x 209

#include <math.h>

#define SWITCH (volatile int *)0x00011000
#define LED (volatile int *)0x00011010
#define LDA (volatile int *)0x00011020

enum LDA_reg {MODE = 0, STATUS, GO, START, END, COLOUR};

void unmerge_coord(int coord, int *x, int *y);
int merge_coord(int x, int y);

int main() {
	int angle_factor = 0;

	*(LDA + START) = merge_coord(168, 105);
	*(LDA + END) = merge_coord(188, 125);

	while (1) {
		int x0, y0, x1, y1;
		unmerge_coord(*(LDA + START), &x0, &y0);
		unmerge_coord(*(LDA + END), &x1, &y1);

		// Rotate
		// Check direction
		if (*SWITCH & 0x02) angle_factor++;
		else angle_factor--;

		x1 = 20 * cos(2 * M_PI / 60 * angle_factor) + x0;
		y1 = 20 * sin(2 * M_PI / 60 * angle_factor) + y0;

		*LDA = *SWITCH; // Set mode
		*(LDA + START) = merge_coord(x0, y0); // Start point
		*(LDA + END) = merge_coord(x1, y1); // End point
		*(LDA + COLOUR) = *SWITCH >> 7; // Set colour
		
		// If mode = 1 (poll), loop until status = 0
		if (*LDA & 0x01)
			while (*(LDA + STATUS) & 0x01);
		
		*(LDA + GO) = 1; // Start drawing

		// Wait 1/30th of a second
		// (50M cycles)/(7 cycles per loop)/30 = 238095 loops
		for (int i = 0; i < 238095; i++);
		
		*(LDA + START) = merge_coord(x0, y0); // Start point
		*(LDA + END) = merge_coord(x1, y1); // End point
		*(LDA + COLOUR) = 0; // Set colour black
		
		// If mode = 1 (poll), loop until status = 0
		if (*LDA & 0x01)
			while (*(LDA + STATUS) & 0x01);
		
		*(LDA + GO) = 1; // Erase line
	}
  
  return 0;
}

void unmerge_coord(int coord, int *x, int *y) {
	*x = coord & 0x01ff;
	*y = (coord >> 9) & 0x00ff;
}

int merge_coord(int x, int y) {
	return ((y << 9) & 0x01fe00) + (x & 0x01ff);
}