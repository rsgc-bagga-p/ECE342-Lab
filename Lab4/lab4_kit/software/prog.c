#define switches0 (volatile char *) 0x0002010
#define switches1 (volatile char *) 0x0002011
#define leds0 (char *) 0x0002000
#define leds1 (char *) 0x0002001

void main()
{
  while (1){
    *leds0 = *switches0;
    *leds1 = *switches1;
  }
}
