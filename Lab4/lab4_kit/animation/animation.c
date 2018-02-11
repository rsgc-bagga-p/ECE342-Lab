// SWITCH 0x0001_1000 - 0x0001_100f
// LEDR   0x0001_1010 - 0x0001_101f
// LDA    0x0001_1020 - 0x0001_103f

// SW[0]   Mode - 0/stall, 1/poll
// SW[1]   Direction - 0/down, 1/up
// SW[2]   Move type - 0/translation, 1/rotation
// SW[3]   Rotation - 0/CW, 1/CCW
// SW[9:7] Colour

// VGA 335 x 209

#include <math.h>

enum lda_reg {MODE = 0, STATUS, GO, START, END, COLOUR};

void unmerge_coord(int coord, int *x, int *y);
int merge_coord(int x, int y);

int main() {
	volatile int * switches = (int *)0x0001100f;
	volatile int * led = (int *)0x00011010;
	volatile int * lda = (int *)0x00011020;

	int angle_factor = 0;

	// (158, 104)
	*(lda + START) = 0x0d09e;
	// (178, 104)
	*(lda + END) = 0xed02b;

	while (1) {
		int x0, x1, y0, y1;
		unmerge_coord(*(lda + START), &x0, &y0);
		unmerge_coord(*(lda + END), &x1, &y1);

		// Check movement type
		if (*switches & 0x04) {
			// Rotate
			// Check direction
			if (*switches & 0x08) angle_factor++;
			else angle_factor--;

			x1 = 20 * cos(2 * M_PI / 30 * angle_factor) + x0;
			y1 = 20 * sin(2 * M_PI / 30 * angle_factor) + y0;
		}
		else {
			// Translate
			// Check direction
			if (*switches & 0x02) {
				if (y0 > 0) {
					y0--;
					y1--;
				}
				else {
					y0 = 209;
					y1 = 209;
				}
			}
			else {
				if (y0 < 209) {
					y0++;
					y1++;
				}
				else {
					y0 = 0;
					y1 = 0;
				}
			}
		}

		*lda = *switches; // Set mode
		*(lda + START) = merge_coord(x0, y0); // Start point
		*(lda + END) = merge_coord(x1, y1); // End point
		*(lda + COLOUR) = *switches >> 7; // Set colour
		*(lda + GO) = 1; // Start drawing

		// If mode = 1 (poll), loop until status = 1
		if (*lda & 0x01)
			while (*(lda + STATUS) & 0x01);

		// Wait 1/30th of a second
		for (int i = 0; i < 1666667; i++);

		*(lda + COLOUR) = (*switches) >> 2; // Set colour black
		*(lda + GO) = 1; // Erase line

		// If mode = 1 (poll), loop until status = 1
		if (*lda & 0x01)
			while (*(lda + STATUS) & 0x01);
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