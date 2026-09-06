# HW_TEST_16be — CONNECT on real hardware (item 18, Tier 1)

**Written 28 August 2026, before any leg runs.** First bench sitting for
CONNECT. The loop, the console-write probe and the design are PORTING.md
§16be; what MAME could reach (entry, banner, receive display) is proven
there, so **every leg here is one MAME could NOT reach: the real console
cost, the keyboard, the send half, the escape menu, BREAK/hangup on the
wire, and the ANSI-TSR question.**

Batch the whole sheet in one sitting — setup is 5–6 min, a leg is ~30 s
(the batching memory).

> **STAGING STATUS — 28 Aug 2026 (updated after the container came back).**
> The shipping CONNECT build (`CKERMITW.EXE`), the parser build with CONNECT
> (`CKICP.EXE`) and both probes ARE staged on A:, round-trip write check
> passed, ~200 KB free for the receive legs. **Every leg runs except NC**,
> which needs `CKICPA.EXE` (parser build with the transfer display forced to
> ANSI) — it is built and in the repo but NOT on A: (two 462 KB binaries plus
> room for a 32 KB received file do not fit at once), and NC is conditional
> on NB failing anyway. Stage `CKICPA` on demand (see §0).

---

## 0. Preconditions — do all of these before leg 1

0a. **Image free space.** `vtg_image_util info <img>:0` — partition 0 (A:)
    runs full (§16bc). The CONNECT binaries are large; if A: cannot hold
    them, stage to partition 1 (D:, 7.5 MB free) and run `D:<name>`, or
    clear stale `STEP*.OUT`. Record the number.

0b. **Round-trip a write to the image**, not just a read — every §0 since
    §16al proves only that the *host* can write it (§16bc lesson 3). Copy a
    scratch file on and read it back.

0c. **Target names are fresh.** Every receive leg writes a file the image
    has never held, and every receive `.BAT` opens with
    `IF EXIST <target> DEL <target>` (§16al's structural fix). Names here:
    `RCVBE.DAT`. `SET FILE COLLISION` is BACKUP and cannot work on FAT —
    fresh name every run.

0d. **The ANSI TSR.** Write down its exact filename and load command as it
    is typed on the Victor (this sheet calls the step "load the TSR"). Note
    whether it installs as `DEVICE=` in CONFIG.SYS or is run as a TSR from
    the prompt, and whether it hooks the console device or an interrupt —
    if it only interprets ANSI on a BIOS path and not on INT 21h AH=40h,
    our loop's output will NOT reach it (rule 6: we are INT 21h only). The
    NA leg tests this directly.

0e. **Cable or modem.** The core legs (PA–CD, NA–NC) run over the **direct
    USB-C→RS-232 cable to the Mac**, Mac playing host/BBS — carrier-watch
    OFF, no dialer. A modem + real BBS is a *follow-on* sitting; when it
    happens, §4's carrier clause (`ttgmdm()` forces DCD under `CLOCAL`)
    needs revisiting against RR0 bit 3, because nothing has ever looked at
    the real DCD pin. Do not mix the two in one sitting.

0f. **Bench basics** (§6): power-cycle Victor *and* Pico between runs; do
    not write the image while the machine runs; `~/.kermrc` already points
    the Mac at the bench adapter, so Mac take-files need only what differs.

### Already staged on `~/projects/mame/victor_kermit.img` partition 0 (A:)

Real hardware has a real keyboard, so **the operator types commands at the
`A:\` prompt — there are no `.BAT` files** (those were only a MAME
keyboard workaround). What is on A: now:

| file | bytes | md5 (12) | for |
|---|---:|---|---|
| `CKERMITW.EXE` | 233,518 | `e976c2c08e1e` | shipping CONNECT build (`-c` legs), ESC-key escape |
| `CKICP.EXE` | 462,764 | `7d553246cc02` | parser build, CONNECT command, ESC-key escape |
| `VCONW.EXE` | 13,928 | — | probe PA |
| `VKBD.EXE` | 12,424 | — | probe PB |

A: has **200 KB free** (room for the 32 KB receive legs), and the **§0b
round-trip write check passed** (host wrote and read back `RTCHECK.TXT`).
Both `CKICP` and `CKERMITW` carry the Tier 1 loop (verified by the `connv`
string in each).

### `CKICPA` — built, in the repo, stage on demand for leg NC only

`CKICPA.EXE` (462,630, md5 `eef76ac0c0ab`) is the parser build with
`-dV9K_CON_FORCE_ANSI` — the transfer display forced to ANSI, needed only if
leg NB shows garbage. It is NOT on A: because a second 462 KB binary plus
room for a 32 KB received file will not fit. To stage it when NB calls for
it, free ~460 KB first — the old probe `.EXE` are the cheapest (their source
is in `v9k/probes/`, results in PORTING.md):

```sh
IMG=~/projects/mame/victor_kermit.img
for f in VFMODEA VFMODEB VFMODEC VFMODEF VFMODEG VMATCH VWILD VACCESS; do
  vtg_image_util delete "$IMG:0:\\$f.EXE"; done
vtg_image_util copy CKICPA.EXE "$IMG:0:\\CKICPA.EXE"
```

**Capture rule (§16ba): a leg that must show a screen cannot carry a
redirect, and a leg that must record counters cannot show its screen.** The
probe legs write their own files (VCONW) or you photograph the screen
(VKBD); the CONNECT legs are photographed.

---

## 1. Probe legs — the real console and the real keyboard

**PA — console write cost on the actual Victor console.** Run `VCONW`
(writes `VCONW.OUT` itself). MAME measured 2.75 ms per 1-byte call, ~908
µs/byte, 363 cps per-char ceiling — **but MAME's console timing is
suspect** (§16n's disk timing was MAME's, not the Victor's). This is the
real number, and it decides the true terminal ceiling and how much the
loop's batching actually buys.
*Settles:* the terminal's real throughput ceiling; whether per-char would
have been fatal or merely slow.
*Capture:* `VCONW.OUT` off the image.

**PB — keyboard, the §16ad open question.** Run `VKBD`. Press, in order and
reading the hex it prints: **`Ctrl-\`** (must read `1c` — the escape
character), then `Ctrl-C`, the four **arrow keys**, a couple of **function
keys**, an **Alt-**letter, `Enter`, `Backspace`, then `Q` to quit.
*Settles:* (1) whether `^\` can be typed at all — if it does NOT read `1c`,
`CKERMITW -c` needs an `--escape=N` switch (§16i mechanism) and the parser
build needs `SET ESCAPE n`; pick a key that PB shows is reachable. (2) What
extended keys deliver (a single byte, a `00`+scan pair, or an ESC sequence)
— the input side of any future Tier 2.
*Capture:* photograph the screen (it is interactive; no redirect).

---

## 2. CONNECT core — the half MAME could not test

Mac side for CA–CC: put the Mac in CONNECT too, so the two terminals face
each other and anything typed on one appears on the other —
`kermit -C "set speed 38400, set flow none, connect"` (kermrc supplies the
line). Escape back on the Mac with its own `Ctrl-\ C` when done.

**CA — entry, escape menu, clean return.** *Runnable now (both binaries
staged).* Two forms: `CKERMITW -l /dev/seriala -b 38400 -c` enters CONNECT
directly, and `CKICP` → `set speed 38400` → `connect` enters from the
prompt. Expect the banner and `Escape character: Ctrl-\`. **The escape character is now the labelled `<esc>` key (ESC, 0x1b) — press
`<esc>` then the command letter, NOT Ctrl-\.** Exercise the menu:
**`<esc> ?`** (help list), **`<esc> S`** (status: speed, echo, bytesize,
parity), then **`<esc> C`** (close). Under `-c` that **exits** the program;
under `CKICP` it should **land back at `C-Kermit>`** — run both and confirm
the difference, since it is the whole reason there are two binaries. **Also
confirm the arrow keys still pass through** (type into CONNECT, press an
arrow — it should send to the Mac, NOT pop the menu): that is the conchk()
peek (§16bf) doing its job.
*Settles:* keyboard input INSIDE the loop, the escape scan, the help/status
handlers; and (parser build) `conres()` restoring the console so the
prompt is usable — the return path `-c` does not take.

**CB — send half + echo.** *Runnable now (`CKERMITW … -c`).* In CONNECT,
type a line of text on the Victor;
confirm each character appears on the **Mac's** CONNECT screen (proves
Victor→line), and — since the Mac echoes in its CONNECT — that it comes
back and displays on the Victor. Type into the Mac; confirm it appears on
the Victor (the receive half, now interactively rather than the scripted
§16be snapshot). Try a few 8-bit / control bytes.
*Settles:* `ttoc(dopar())` send path, `cmask`/parity, and duplex echo.

**CC — BREAK and hangup on the wire (scope leg).** *Runnable now
(`CKERMITW … -c`).* Logic analyzer on the
TTL side per §16an (probe the 7201 TD line and `/DTR`; the RS-232 side is
±12 V). In CONNECT: **`^\ B`** — TD should be held low ~275 ms (WR5 bit 4;
`ttsndb()`/`sndbrk()` — **its first real exercise**). **`^\ L`** — ~1.5 s.
Then **`^\ H`** (or `U`) — `/DTR` should drop (WR5 bit 7; `tthang()`, which
works since §16av's `msleep()` fix) and CONNECT should end. In the parser
build `^\ H` returns to the prompt with the line hung up; **`^\ Q`** should
hang up and exit the program.
*Settles:* `tcsendbreak`/`sndbrk` actually toggle the pin (static analysis
only until now — §16an), and hangup drops DTR.

**CD — BBS-shaped round trip (the workflow item 18 exists for).** *Runnable
now — `CKICP` is staged.* Mac plays
the BBS. Victor `CKICP` → `connect`. Mac sends a "menu" line (from its
CONNECT, or `kermit -C "... output DOWNLOAD? \13\10"`). On the Victor:
**`<esc> C`** back to the prompt, `receive`, then on the Mac `send TRANS.DAT`
(32,768 bytes, md5 `d94d2beda069ef0ef340977e7fd6995d`). After FINISH,
`connect` again and confirm the session resumes.
*Settles:* connect → escape → RECEIVE → reconnect, end to end, which is the
whole reason CONNECT is back. md5 the received `RCVBE.DAT`.

---

## 3. ANSI — the question that decides whether Tier 2 exists

**The hypothesis: with the Victor's ANSI TSR loaded, we write NOTHING for
CONNECT.** Our loop passes host bytes straight to the console via INT 21h,
the TSR renders the `ESC[…`. If NA confirms it, Tier 2 (an ANSI→VT52
translator on our end) is retired. NB then checks the only real catch — the
file-transfer display, which emits VT52.

Mac-side ANSI emitter (a canned test is more reproducible than typing):
```sh
# s16beANSI.ksc on the Mac
set speed 38400
set flow none
pause 3
output \27[2J\27[1;1H\27[7m ANSI TSR TEST \27[0m\13\10
output \27[5;20HmovedHere\13\10
output \27[10;1Hline10 col1\13\10
output \27[2;40Hcol40\13\10
pause 10
exit
```

**NA — TSR pass-through renders ANSI.** *Runnable now.* On the Victor:
**load the TSR** (§0d), then `CKERMITW -l /dev/seriala -b 38400 -c`. On the Mac:
`kermit -C "take s16beANSI.ksc"`. Expect the screen CLEARED, `ANSI TSR
TEST` in reverse video near the top, and the later strings placed at the
addressed row/columns — NOT the literal bytes `[2J[1;1H…` printed as text.
*Settles:* whether the TSR interprets ANSI on our INT 21h output path. If
it does, **no ANSI code is needed for CONNECT** — Tier 2 is closed by
configuration, not by writing a translator.
*Contrast leg:* repeat WITHOUT the TSR loaded — you should see the literal
escape bytes as text (the Victor console is VT52, not ANSI). That contrast
is what proves NA measured the TSR and not something else.

**NB — does the transfer display survive the TSR? (the real work item.)**
*Runnable now with the shipping build's receive: `CKERMITW -l /dev/seriala
-b 38400 -r` — the fullscreen display is the same code whether reached from
CONNECT or a bare receive.* With the TSR STILL loaded, run that and on the
Mac `send TRANS.DAT` (into a fresh name — see §0c). Watch the display
(`§1g`, which emits VT52 `ESC Y`/`ESC E`/`ESC K`).
- **Renders correctly** → the TSR passes unknown (VT52) ESC sequences
  through to the native console. **Nothing to write, ever.** Note it and
  stop.
- **Garbage / literal `Y`+coords** → the TSR consumes all ESC and only
  speaks ANSI, so the display must emit ANSI when the TSR is loaded. Go to
  NC. This is the FreeDOS case (`§1g`), and the fix already exists.
*Settles:* the entire residual ANSI work — "nothing" vs "a dialect flag."

**NC — only if NB was garbage: the ANSI-forced display.** *Needs `CKICPA` —
built and in the repo; stage it on demand per §0 (frees room by deleting the
old probe `.EXE`).* With the TSR loaded, run `CKICPA` (parser build with
`-dV9K_CON_FORCE_ANSI`) and repeat the receive. The transfer display should now paint correctly through the TSR.
*Settles:* that `§1g`'s existing ANSI arm is the whole fix, and the only
new code is a runtime selector — e.g. a `SET TERMINAL TYPE ANSI/VT52` or a
probe for the TSR — to pick the dialect without a separate binary. Byte-md5
`RCVBE2.DAT`.

---

## 4. What a clean sitting looks like

- **PA**: a real cps ceiling, whatever it is; quote it against MAME's 363 /
  ~1,100 so §16be's batching claim is anchored to hardware.
- **PB**: `^\` reads `1c` (or an alternative escape identified); extended
  keys characterised.
- **CA–CD**: banner, menu, send both ways, BREAK/DTR on the scope, and a
  byte-exact `RCVBE.DAT` after an escape-and-receive.
- **NA**: ANSI renders under the TSR → Tier 2 retired.
- **NB/NC**: either the transfer display already survives the TSR (nothing
  to do) or `-dV9K_CON_FORCE_ANSI` fixes it (one dialect flag to wire up).

Write the results into a new PORTING.md section (§16bf or later) and update
NEXT_SESSION.md item 18. If NA/NB close the ANSI question, strike Tier 2
from item 18 and record that the TSR does the job — a feature removed by
measurement, which is the cheapest kind.

---

## 5. Notes carried in from the build side (do not rediscover these)

- **CK_AUTODL is OFF** in both builds (confirmed by `wcc -pl`), so a Kermit
  S packet arriving mid-CONNECT will NOT auto-start a receive yet; you must
  escape and `receive` by hand (CD does this deliberately). Turning it on
  is a `ckvictor.h` flag plus the `ksbuf[]` matcher — a separate item.
- **The parser build cannot** do `-C`, macros, variables or `INPUT`
  (`NOSPL`); it has the `C-Kermit>` prompt and `TAKE`, nothing more.
- **`msleep()` works** (§16av), so `tthang()` and the BREAK timing are real
  now; that is why CC is worth a scope.
- The console is **80×24** to CONNECT and the transfer display (`LINES=24`,
  the OEM driver reserves row 25); an ANSI TSR may or may not honour that —
  watch the bottom line in NA.
