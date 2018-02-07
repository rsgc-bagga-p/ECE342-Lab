#define switches (volatile short *) 0x0002010
#define leds (short *) 0x0002000

void main()
{
  while (1)
    *leds = *switches;
}
