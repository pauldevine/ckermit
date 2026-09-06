/*
  vconw.c -- what does one INT 21h console write cost on this machine?

  PORTING.md item 18 (CONNECT, Tier 1) has to decide how the terminal loop
  puts host bytes on the screen: one big write per drained run, or a call
  per character.  Nothing in this port has ever measured INT 21h screen
  output.  SS16ap's ~4-5 s over 331-514 fullscreen display writes IMPLIES
  ~10 ms a write call, which would cap a per-character terminal near 100
  cps -- below a 1200 bps modem -- but that was inferred from the transfer
  display, not measured directly, so this asks the machine.

  Three arms, each doing a fixed number of INT 21h AH=40h write calls but a
  different chunk size:

      char  1-byte    writes -- the per-character loop
      line  80-byte   writes -- one screen line per call
      big   1920-byte writes -- a whole 80x24 screen at once

  Holding the chunk apart separates per-CALL overhead (the INT 21h round
  trip and the driver's per-request work) from per-BYTE cost (the driver
  actually painting glyphs).  The "char" arm's microseconds-per-call is the
  terminal's per-character ceiling, and 1e6 / that is the cps a naive
  per-char loop could sustain -- the number every later CONNECT figure is
  quoted against.  The arms have DIFFERENT call counts (char most, big
  fewest) because the whole probe must finish quickly: the big arm is
  per-byte costly and the char arm needs the most samples for its coarse
  clock.

  RESULTS GO TO A FILE THIS PROGRAM OPENS AND CLOSES ITSELF, one close per
  arm, NOT to a stdout redirect.  The first two runs were killed by
  -seconds_to_run while the big arm was still painting; a redirected
  VCONW.OUT is only finalised in the DOS directory when the program EXITS
  and closes it, so those runs left a screen full of test pattern and no
  file at all.  Opening, appending and closing after each arm finalises the
  directory entry as the arm completes, so even a cut-off run keeps the arms
  that already ran.  The test bytes still go to a separately opened "CON"
  handle, so they hit the screen (visible) and never touch the result file.

  Timing is INT 21h AH=2Ch (get time), whose DL is hundredths.  On Victor
  MS-DOS 3.1 that clock advances in 500 ms steps (PORTING.md SS16n), so the
  arms are sized to run several seconds each, well above the quantum.

  Build (host container, Open Watcom):
    wcc -ml -0 -os -zq -bt=dos -i=<watcom>/h -fr=/dev/null vconw.c
    wlink system dos name vconw.exe file vconw.obj

  INT 21h only, per rule 6.  Nothing here is Victor-specific; it is only
  interesting on a Victor because nobody had run it on this console.
*/

#include <dos.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <io.h>
#include <sys/stat.h>

#define V9K_CALLS_CHAR  2000L
#define V9K_CALLS_LINE  1000L
#define V9K_CALLS_BIG    100L
#define V9K_SCREEN  1920                /* 80 x 24                        */
#define V9K_OUT     "VCONW.OUT"

static char scr[V9K_SCREEN];

/* Centiseconds since midnight from INT 21h AH=2Ch. */
static long
now_centis(void)
{
    union REGS r;
    r.h.ah = 0x2c;
    intdos(&r,&r);
    return((((long)r.h.ch * 60L + r.h.cl) * 60L + r.h.dh) * 100L + r.h.dl);
}

static long
elapsed(long t0)
{
    long t = now_centis() - t0;
    if (t < 0L) t += 24L * 60L * 60L * 100L;   /* midnight wrap          */
    return(t);
}

/*
  One AH=40h write of n bytes from scr[] to the given handle.  Large model,
  so scr[] is far and DS must be loaded from its segment for the call.
*/
static void
dwrite(int handle, unsigned n)
{
    union REGS  r;
    struct SREGS s;

    segread(&s);
    r.h.ah = 0x40;
    r.x.bx = (unsigned)handle;
    r.x.cx = n;
    r.x.dx = FP_OFF(scr);
    s.ds   = FP_SEG(scr);
    intdosx(&r,&r,&s);
}

/* Open the console device for the test writes, independent of stdout. */
static int
open_con(void)
{
    union REGS  r;
    struct SREGS s;
    static char con[] = "CON";

    segread(&s);
    r.h.ah = 0x3d;                      /* Open existing file/device      */
    r.h.al = 0x01;                      /* For writing                    */
    r.x.dx = FP_OFF(con);
    s.ds   = FP_SEG(con);
    intdosx(&r,&r,&s);
    if (r.x.cflag)
      return(-1);
    return((int)r.x.ax);
}

/* Append one already-formatted line to the result file and close it. */
static void
emit(const char * s)
{
    int fd = open(V9K_OUT, O_WRONLY | O_CREAT | O_APPEND | O_TEXT,
                  S_IREAD | S_IWRITE);
    if (fd >= 0) {
        write(fd,s,(unsigned)strlen(s));
        close(fd);                      /* Finalises the directory entry  */
    }
}

static long
run_arm(int handle, unsigned chunk, long calls)
{
    long i, t0;
    t0 = now_centis();
    for (i = 0L; i < calls; i++)
      dwrite(handle,chunk);
    return(elapsed(t0));
}

int
main(void)
{
    int con, fd;
    long tc, tl, tb;
    char b[128];
    int i;

    for (i = 0; i < V9K_SCREEN; i++)    /* Visible pattern                */
      scr[i] = (char)('0' + (i % 10));

    fd = creat(V9K_OUT, S_IREAD | S_IWRITE);   /* Start the file fresh    */
    if (fd >= 0) close(fd);

    con = open_con();
    if (con < 0) {
        emit("vconw: cannot open CON\n");
        return(1);
    }

    sprintf(b,"vconw: char/line/big calls = %ld/%ld/%ld\n",
            V9K_CALLS_CHAR, V9K_CALLS_LINE, V9K_CALLS_BIG);
    emit(b);

    tc = run_arm(con,1,V9K_CALLS_CHAR);
    sprintf(b,"vconw: char chunk=   1 total=%ld cs  us/call=%ld\n",
            tc, (tc * 10000L) / V9K_CALLS_CHAR);
    emit(b);
    if (tc > 0L) {
        sprintf(b,"vconw: per-char-loop ceiling = %ld cps\n",
                (V9K_CALLS_CHAR * 100L) / tc);
        emit(b);
    }

    tl = run_arm(con,80,V9K_CALLS_LINE);
    sprintf(b,"vconw: line chunk=  80 total=%ld cs  us/call=%ld\n",
            tl, (tl * 10000L) / V9K_CALLS_LINE);
    emit(b);

    tb = run_arm(con,V9K_SCREEN,V9K_CALLS_BIG);
    sprintf(b,"vconw: big  chunk=1920 total=%ld cs  us/call=%ld  us/byte=%ld\n",
            tb, (tb * 10000L) / V9K_CALLS_BIG,
            (tb * 10000L) / (V9K_CALLS_BIG * (long)V9K_SCREEN));
    emit(b);

    emit("vconw: done.\n");
    return(0);
}
