/*
  vkbd.c -- what does the Victor's keyboard deliver through INT 21h AH=07h?

  PORTING.md item 18 (CONNECT, Tier 1) needs the escape character -- ^\
  (0x1C, DFESC) -- to reach the terminal loop as a byte, and it reads the
  keyboard the way this port already does: INT 21h AH=07h, direct console
  input, no echo, no Ctrl-C check (ckvictor.c dos_raw_stdin()).  Two things
  are unknown and only a real keyboard can answer them (SS16ad flagged the
  second as the one thing MAME could not settle):

    1. Does AH=07h deliver 0x1C when the operator types Ctrl-\ at all?  If
       the Victor's keyboard driver eats it or maps it elsewhere, CKERMITW
       -c needs an --escape=N switch to pick a key that can be typed.

    2. What do the arrow, function and Alt-class keys produce?  On an
       IBM-compatible AH=07h returns 0x00 and the scan code follows on the
       next call; whether this keyboard does the same, or sends a multi-byte
       ESC sequence, or something else, decides how a future Tier-2 loop
       forwards those keys to a host.

  THIS IS A BENCH PROBE.  MAME mangles typed input (PORTING.md SS16a:
  digits arrive shifted; CKERMITW -r once arrived as CKERIT_R), so a
  keyboard test cannot be automated -- it wants the Victor's own keyboard.
  Boot it, run VKBD, press keys, read the hex on the screen, press Q to
  quit.  A byte read as 0x00 is reported together with the byte that
  follows it, labelled "ext", so an extended key shows both halves.

  Build (host container, Open Watcom):
    wcc -ml -0 -os -zq -bt=dos -fr=/dev/null vkbd.c
    wlink system dos name vkbd.exe file vkbd.obj

  INT 21h only, per rule 6.
*/

#include <dos.h>
#include <stdio.h>

/* One character, raw and unechoed -- INT 21h AH=07h, as dos_raw_stdin(). */
static int
raw_key(void)
{
    union REGS r;
    r.h.ah = 0x07;
    intdos(&r,&r);
    return((int)(r.h.al & 0xff));
}

/* Is a character waiting?  INT 21h AH=0Bh, as dos_stdin_ready(). */
static int
key_ready(void)
{
    union REGS r;
    r.h.ah = 0x0b;
    intdos(&r,&r);
    return(r.h.al ? 1 : 0);
}

static const char *
named(int c)
{
    switch (c) {
      case 0x1c: return("Ctrl-\\  <- THE ESCAPE CHARACTER (DFESC)");
      case 0x0d: return("CR");
      case 0x0a: return("LF");
      case 0x08: return("BS");
      case 0x09: return("TAB");
      case 0x1b: return("ESC");
      case 0x7f: return("DEL");
      case 0x20: return("SPACE");
      default:   return("");
    }
}

int
main(void)
{
    int c, c2;

    printf("vkbd: press keys to see their AH=07h byte; press Q to quit.\r\n");
    printf("vkbd: watch for Ctrl-\\ (should read 1c) and try the arrow,\r\n");
    printf("vkbd: function and Alt keys -- their bytes are the open ones.\r\n");
    printf("vkbd: ready=%d at start\r\n", key_ready());

    for (;;) {
        c = raw_key();
        if (c == 0x00) {                /* Extended-key lead byte?        */
            c2 = raw_key();             /* Scan code follows              */
            printf("vkbd: 00 ext=%02x (ready=%d)\r\n", c2, key_ready());
            continue;
        }
        printf("vkbd: %02x %s (ready=%d)\r\n", c, named(c), key_ready());
        if (c == 'Q' || c == 'q')
          break;
    }
    printf("vkbd: done.\r\n");
    return(0);
}
