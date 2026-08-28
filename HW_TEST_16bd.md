# Bench run sheet — §16bd: the four found-and-not-fixed defects, on the machine

**This document is the thing to work from. Follow it top to bottom.**

**Written 26 August 2026, BEFORE any leg ran.** Every result box below is
empty until the leg that fills it has run. §0, the leg table, the
predictions and the decision rules are fixed in advance so that a leg
cannot be redefined after its output is seen. (§16az's closing asked for
this; §16ba, §16bb and §16bc established the habit.)

**Leg letters are the E series.** Checked against tracked *and* untracked
files — `git ls-files | grep STEP` misses the untracked `STEPX*`/`STEPY*`/
`STEPZ*` sets that §16bc's own check would have walked into. Spent first
letters are A, B, C, D, F, G, H, J, K, M, N, P, R, S, U, V, W, X, Y, Z.
**E, L, Q and T are free; this sitting takes E.** `EI` is skipped: it reads
as E1.

---

## What this sitting is for

**Upstream edits 23, 24, 25 and 26 went into the tree on 25 August 2026**
and none of them has run on hardware. They are the four defects this port
had found and **deliberately not fixed** — carried in `PORTING.md` §8's
report list for as long as five sections — and the decision to fix them was
made explicitly under hard rule 1 rather than arrived at.

| edit | file | what it does | visible? |
|---|---|---|---|
| **23** | `ckutio.c` | `ttpkt()`'s `TESTING234` block preserves `IXON\|IXOFF` instead of clearing them 4 lines before `tcsetattr()` | **one debug line** — leg EJ |
| **24** | `ckutio.c` | `ttoc()`'s only `tcflow(TCOON)` hoisted out of the `debug()` argument `NODEBUG` deletes it with | **no** — see "What this sitting cannot answer" |
| **25** | `ckufio.c` | `zchko()` stops creating and deleting every file it is asked about | **yes, ~4.4 s** — legs EA/EB/EC/ED |
| **26** | `ckcfns.c` | `snddir()`'s bodyless `if` given a body, so a failed `zfnqfp()` cannot print an uninitialised `fnbuf` | **regression only** — leg EK |

**Only edit 25 has an effect this harness can see, and it is large.**
§16bc legs HL/HN measured `zchko()`'s create-and-delete pair at **4.404 s
(host clock) and 4.50 s (Victor `elapsed=`)** per received file on a
156-entry FAT root, fixed and rate-independent, with `dec max=` localising
**3.50 s of it to a single decode interval**. That is the largest fixed
cost this port has ever measured on the receive path, and it is not on the
receive path at all — it is before it, in the writability probe.

**A:'s root now holds 191 files and 2 directories, up from 156 at §16bc**,
so the effect should be at least as large.

### Why the control is unusually strong this time

`D:\CKBB.EXE` on the image is **md5 `c42c3598d685e3204321c33a724e04b9`**,
and a clean rebuild of the current tree with edits 23–26 stashed reproduces
that md5 **exactly** (verified 26 August). So:

- the A/B is a **binary difference, not a rebuild** — §16aq's `--nobulk`
  shape, one better, because the control also has a published result;
- the working tree's uncommitted `ckvictor.c` changes (the 22 August
  external-clock correction) are **provably code-inert** — comment-only,
  established by that md5 rather than by reading them;
- `CKBB.EXE` is **the same binary that produced §16bc legs HL and HN**.

**The published HL/HN numbers are still not reused as the control.** Legs
EA and EC re-run them adjacent, because §16al's finding stands: the same
`CKPRE` binary gave 18.29 s non-line in §16ah and 21.43 s in §16al with the
wire held constant, so **the spread is the host and cross-sitting
comparisons are worthless.**

---

## §0 — preconditions

| check | how | status |
|---|---|---|
| image backed up before any write | `cp` | ☑ **`victor_kermit.img.bak-20260826-pre16bd`, 26 Aug** |
| **free space**, read through a **FRESH COPY** — the tool caches by path and will hand you a stale answer (§16bc) | `vtg_image_util info` on a copy at a new path | ☑ **`A:` 336 KB (42 clusters), `D:` 7.9 MB**, post-staging |
| **root-entry headroom** — the variable under test | `root_dir_sectors` 57 × 512 ÷ 32 | ☑ **912 entries; `A:` uses 193, `D:` uses 28** |
| leg-letter collision | tracked **and untracked** — `ls STEPE*` and `git ls-files` | ☑ E series free, verified 26 Aug |
| target names never used | `vtg_image_util list` — no `RCVE*`, no `STEPE*`, no `CKFNF*` anywhere on the image | ☑ checked 26 Aug |
| the eight `.BAT`s exist **and are staged** | §0a | ☑ **8 of 8 round-tripped and `cmp`'d** |
| `.BAT` files still CRLF **after** landing on the image | copy back, count `\r` | ☑ **8 of 8** |
| every receive `.BAT` opens with `IF EXIST <target> DEL <target>` **and `IF EXIST <target>.001 DEL <target>.001`** | §16al's rule, §16bb's addition. Machine-kept, not remembered | ☑ **written into all six receive legs** |
| each staged binary's md5 round-trips **off the image** | copy back, `md5` | ☑ `CKFNF` `039fae2a…`, `CKFNFD` `64ba06ed…`, **`CKBB` `c42c3598…`** |
| **a WRITE round-trips, not only a read** | §16bc lesson 7 — `CKFNF.EXE`/`CKFNFD.EXE` were written to `D:` and read back byte-identical | ☑ |
| **every `.ksc` body names its own leg** | `for f in s16bdE*.ksc; do ...` — see the receipt below | ☑ **8 of 8** |
| the `-d` guard: every leg reports **`deb=0`** except **EJ**, which is `-d` on purpose **and must run `CKFNFD.EXE`, not `CKFNF.EXE`** | §16aw, and §16bc broke this rule while quoting it | ☑ written into `STEPEJ.BAT` |
| proofs pass | `make -C v9k/proofs` — expect **5 of 5** | ☑ **5 of 5, 26 Aug** (`vburst`, `vcrc16`, `vttinl` 100,023 cases, `vwindow`, `vznewn` 6,013 checks) |
| **the host client is 11.0.508 from this tree** | `kermit -C "show versions, exit"` **and** `strings wermit \| grep "tthflow POSIX_CRTSCTS tcsetattr"` — `SHOW FEATURES` only proves the symbol was defined while `ckuus5.c` compiled (§16bc) | ☐ |
| `~/.kermrc` names the adapter that is plugged in | | ☐ |
| **the Pico's copy is this image** | the bench serves `victor_kermit.img` from the Pico SASI; the MAME image and the Pico's copy are **not automatically the same file** (§16bc §0a) — sync it, then re-verify `CKFNF.EXE`'s md5 off the bench image | ☐ |

**Shipping configuration under test**, so a `-d` flag in this sheet without
a staged binary beside it is a suggestion and not a setting:

```
V9K_RXBUFSIZ 4096   DRPSIZ 4000   DFWSIZ 1        V9K_OBUFSIZE 8192
V9K_FLOW FLO_NONE   hi 3072 / lo 1024             V9K_PREFIXING PX_CAU
```

---

## §0a — staging. **DONE 26 August. This is a receipt, not a to-do.**

Backup taken first: `victor_kermit.img.bak-20260826-pre16bd`.

| on `A:` (partition 0) | | |
|---|---|---|
| `STEPEA` `STEPEB` `STEPEC` `STEPED` `STEPEF` `STEPEG` `STEPEJ` `STEPEK` `.BAT` | 8 files | round-tripped off the image and `cmp`'d against the tree — **8 of 8 identical, CRLF intact after landing** |
| `FIXTURE.DAT` | 32,768 | already there, round-tripped, md5 `d94d2bed…` |

| on `D:` (partition 1) | bytes | md5 | what it is |
|---|---:|---|---|
| `CKBB.EXE` | 231,172 | `c42c3598…` | **the control.** Already there; md5 verified off the image and against a fresh rebuild of the tree with edits 23–26 stashed |
| `CKFNF.EXE` | **231,252** | `039fae2a…` | **new** — edits 23–26, shipping configuration |
| `CKFNFD.EXE` | **314,120** | `64ba06ed…` | **new** — the same, `XFLAGS=-dKEEP_DEBUG`, for leg EJ only |

Measured from the tree:

| binary | DGROUP | image | needs | smallest Victor |
|---|---|---:|---:|---|
| `CKBB` (control) | 48,896 / 65,536 (74%) | 231,172 | 243,236 (237K) | 384K |
| **`CKFNF`** | **48,896 / 65,536 (74%)** | **231,252** | **243,316 (237K)** | **384K** |
| `CKFNFD` | — | 314,120 | 320,872 (313K) | 512K |

**Four edits cost +80 bytes of image and not one byte of DGROUP.** Edit 25
removes a `zdelet()` call and two branches, which is most of why. **19
warnings before and 19 after**, the same nineteen, none at any of the four
sites — counted on a clean rebuild of each tree rather than assumed.

**All four edits were confirmed present in the preprocessed `NODEBUG`
output** with `wcc -pl`, which is the instrument §16aj used to find two of
them: `xonxoff = ttraw.c_iflag & (0x0400|0x1000)` and the matching
`ttraw.c_iflag |= xonxoff`; `tcf = tcflow(ttyfd,1)`, where §16aj recorded
that `tcflow` occurred nowhere but its own prototype; `open(name,
0x0001|flags,0600)` with no `O_CREAT` and no `zdelet` inside `zchko`; and
`ckstrncpy(fnbuf,name,128+1)` under a real `if`.

### One thing the staging found, and it is a harness defect in §16bc

**`s16bcHA.ksc` logs to `s16bcHP.pkt` and sends `rcvhp.dat`** — HP's
512-byte fixture — while its header describes HA's 32 KB receive. §16bc
reported HA as a 32 KB receive at 26.200 s, so the bench did not run the
tracked file; but **the tracked artifact is wrong and would silently
mis-run if it were reused**, which is the entire reason these files are in
git. It is machine-checkable in one line, and that check is now a §0 row:

```sh
for f in s16bd*.ksc; do leg=$(basename $f .ksc); \
  body=$(grep -o 'log packets [a-zA-Z0-9]*' $f | head -1 | awk '{print $3}'); \
  [ "$body" != "$leg" ] && echo "MISMATCH $f -> $body"; done
```

All eight of this sitting's take-files pass it. **A leg label is unique only
within its sitting and a take-file is only as good as its body** — the same
species as the H-series label collision between §16ap and §16bc.

---

### Fixtures — recipes, because `.gitignore` excludes `*.dat`

| file | bytes | md5 | used by |
|---|---:|---|---|
| `rcve{a,b,c,d,f}.dat` | 32,768 | `d94d2beda069ef0ef340977e7fd6995d` | EA, EB, EC, ED, EF — copies of `trans.dat` |
| `rcvej.dat` | 512 | `b6a1125fa9e47be216d9eb7fe9684c36` | EJ — small on purpose; `-d` costs ~25 ms per received byte |
| `A:\FIXTURE.DAT` | 32,768 | `d94d2bed…` | EG, sent **by name** |

```python
# rcvej.dat
open('rcvej.dat','wb').write(bytes((i*5 + 17) & 0xFF for i in range(512)))
```

**`TRANS.DAT` is not on this image** (§16bc). `A:\FIXTURE.DAT` is
byte-identical to it and **edit 16 keys off the file SIZE, not the name**,
so leg EG is unaffected.

---

## Before every leg

- **The Victor takes about 40 s to load.** On a leg where the Victor
  *receives*, start the Victor first, wait for the drive to go quiet, then
  start the host. On leg **EG** the Victor *sends* — **start the host
  receiver FIRST**, because the Victor is the initiator and gives up if
  nothing answers its S packets.
- **Run each pair back to back: EA→EB, then EC→ED.** Nothing here is
  comparable across a gap (§16al).
- Power-cycle the Victor **and** the Pico between runs.
- **A leg ends when the VICTOR exits, not when the host does** (§16bb).
- Four artifacts per leg: `s16bdE<x>.host`, `s16bdE<x>.pkt`,
  `STEPE<x>.OUT`, and the transferred file `cmp`'d against its fixture.
- **`cmp` first, then the counters.** A leg that is fast and wrong is the
  failure mode.
- **Redirect the host**: `kermit -C "take s16bdEA.ksc, exit" > s16bdEA.host`.
  A leg missing the `.host` cannot resolve any difference smaller than the
  Victor's 50 cs quantum, which is most of them.

**Read every log the same way:**

```sh
python3 v9k/tools/pktstat.py --rxbytes <from the .OUT> s16bdE<x>.pkt
```

Residual **−11** clean, **+28** with a startup timeout. **Non-line cost =
host clock − (wire bytes × 260 µs)**. The Victor's `elapsed=` and the
host's `statistics` do **not** measure the same interval — quote the pair,
never one alone (§16v). **`wire=` is a receive-leg figure only.**

**The arithmetic rule that governs every A/B below: this bench does not
repeat to better than ~0.4–1.3 s** (§16ah 1.277 s; §16ak 398 ms; §16bc
pass 2 held four legs to 73 ms). **Do not read an effect smaller than that
off two legs.** The effect this sitting is built around is ~4.4 s, which is
comfortably above it — that is why the sitting is worth running.

---

## The legs

| leg | rate | binary | volume | asks |
|---|---|---|---|---|
| **EA** | 9600 | `D:\CKBB` | `A:\` | control on the **populated** root — re-runs §16bc HL |
| **EB** | 9600 | `D:\CKFNF` | `A:\` | **THE HEADLINE** — does edit 25 remove the 4.4 s? |
| **EC** | 9600 | `D:\CKBB` | `D:\` | control on the **sparse** root — re-runs §16bc HN |
| **ED** | 9600 | `D:\CKFNF` | `D:\` | **THE NULL LEG** — edit 25 should do nothing here |
| **EF** | 38400 | `D:\CKFNF` | `A:\` | regression at the shipping rate, receive |
| **EG** | 38400 | `D:\CKFNF` | `A:\` | regression, **send 32,768 BY NAME** (edit 16's range) |
| **EJ** | 9600 | `D:\CKFNFD -d --xonxoff` | `D:\` | **edit 23 witness** — the only leg that can see it |
| **EK** | 9600 | `D:\CKFNF -x` | `A:\` | **edit 26 regression** — `REMOTE DIRECTORY` over 193 entries |

---

## Tier 1 — edit 25. Legs **EA**, **EB**, **EC**, **ED**

A 2×2: {control, treatment} × {populated root, sparse root}. The point of
the second factor is that **it makes the mechanism testable, not just the
effect.** A saving that appears on `A:` and not on `D:` is `zchko()`; a
saving that appears on both is something else — layout, or the rebuild —
and §16w says this machine is sensitive enough to code size that the
question has to be asked.

### Predictions, fixed before the run

| | EA (ctl, `A:`) | EB (trt, `A:`) | EC (ctl, `D:`) | ED (trt, `D:`) |
|---|---:|---:|---:|---:|
| host clock | ~57 s (HL: 57.006) | **~52.6 s** | ~52.6 s (HN: 52.602) | **~52.6 s** |
| `elapsed=` | ~5950 cs | **~5500 cs** | ~5500 cs | **~5500 cs** |
| **`dec max=`** | **~450 at #3** | **~100–150 at #3** | ~100 at #3 | ~100 at #3 |
| wire bytes | 39,564 | **39,564** | 39,564 | 39,564 |

**The sharpest statement of the hypothesis is not "EB is faster than EA".
It is "after edit 25, the VOLUME STOPS MATTERING": EB ≈ ED.** That is one
number to look at and it does not depend on either published control.

### Decision rules, fixed before the run

1. **Edit 25 is CONFIRMED** iff all of: `EA − EB ≥ 2.0 s`; `|EC − ED| ≤
   1.3 s`; EA and EB report **identical wire bytes**; all four byte-exact
   with `rxlost=0 rxfull=0`.
2. **If `EA − EB ≥ 2.0 s` but `|EC − ED| > 1.3 s`** — the reading is
   **VOID**. Whatever moved is not `zchko()`, and no amount of arguing from
   EA/EB recovers it.
3. **If EA and EB differ in wire bytes**, the legs are not comparable and
   the clock difference means nothing. **Read the wire before the clock.**
4. **If `EA − EB < 2.0 s` and everything is byte-exact**, edit 25 is
   correct but does not do what §16bc's mechanism says it does. **Report
   that and stop** — do not go hunting for the 4.4 s in this sitting.
5. `dec max=` **corroborates, it does not adjudicate** (§16ar): it cannot
   tell a decode from a silence. `rxpeak` and the two clocks are the
   result; `dec` localises it.

> **RESULT EA/EB/EC/ED — 27 August 2026. All four byte-exact,
> `rxlost=0 rxfull=0`. THE CLOCK COMPARISON IS VOID BY RULE 3: TWO OF THE
> FOUR LEGS WENT OFF-SHAPE.**
>
> | | EA (ctl, `A:`) | EB (trt, `A:`) | EC (ctl, `D:`) | ED (trt, `D:`) |
> |---|---:|---:|---:|---:|
> | wire (`rxbytes`) | **51,205** | 39,483 | 39,483 | **46,476** |
> | timeouts / resends | **3 / 7** | 1 / 1 | 1 / 1 | **2 / 4** |
> | host clock | 68.454 s | 56.151 s | 52.587 s | 59.182 s |
> | Victor `elapsed=` | 7900 cs | 5900 cs | 5500 cs | 6200 cs |
> | **`dec max=`** | **450 @#3** | **350 @#3** | **100 @#3** | **100 @#9** |
> | non-line cost | 15.12 s | 15.02 s | 11.46 s | 10.77 s |
> | md5 | ✓ | ✓ | ✓ | ✓ |
>
> **Rule 3 fired.** EA and EB do not have identical wire bytes — EA took 3
> timeouts and 7 retransmissions against EB's 1 and 1 — so the 12.3 s
> clock difference is not readable as edit 25's effect. ED, the null leg,
> is off-shape too (2/4). **Half the sitting went off-shape against
> §16ah's budgeted third.**
>
> **What survives is `dec max`, and it is a within-sitting, single-variable
> comparison: same volume, same rate, binary differs. `A:` decode #3 goes
> 450 → 350 cs.** `dec` is quantised at 50 cs and §16ar's rule holds — it
> corroborates, it does not adjudicate — but it isolates the one interval
> `zchko()` lives in, and it moved 2 quanta in the predicted direction.
> **Leg EF repeats it independently at 38400: 350, where §16bc leg HA on
> the same volume read 450.**
>
> **The null leg holds on the counter**: EC and ED both read 100.
>
> **But the `A:`-vs-`D:` penalty is NOT gone.** By non-line cost the
> treatment legs are 15.02 (`A:`) against 10.77 (`D:`) — **still ~4.2 s
> apart**. So edit 25 removed part of the stall, not the whole of it, and
> that is exactly what the mechanism predicts: §16bc found **four stats,
> one CREATE and one DELETE**; edit 25 removes the CREATE and the DELETE
> and leaves the four stats. **§16bc's attribution of the whole 4.4 s to
> the create/delete pair was too strong.**
>
> **VERDICT: edit 25 is SAFE and appears to remove ~1 s of a ~4 s penalty.
> The magnitude is NOT established by this sitting.** See the re-run below.

---

## Tier 2 — regression at the shipping rate. Legs **EF**, **EG**

These ask whether four upstream edits broke anything at 38400, which is a
**hardware-only path** — MAME cannot drive this machine above about 9600,
so nothing before this sitting has tested them at the rate the port ships.

**Pass is byte-exact + `rxlost=0 rxfull=0`, not a clock comparison.** There
is no adjacent 38400 control in this sitting; §16bc's HA (26.200 s, 1,250
cps) and HB/§16ai's CC (22.207 s, 1,475 cps) are cross-sitting and are
**context, not baselines** (§16al). If EF also comes in ~4 s under HA that
is consistent with edit 25 at 38400 — §16bc found `dec max=450` on leg HA,
so the directory cost is there at that rate too — and it is a **bonus, not
the result.**

> **RESULT EF — PASS.** Byte-exact, `rxlost=0 rxfull=0 rxpeak=2642 of
> 4096`, 40,536 wire bytes, 1 timeout / 2 resends, 26.804 s, 1,222 cps.
> **`dec max=350 at #2`** — the second independent instance of the 450 →
> 350 move, at the shipping rate. Four upstream edits, no regression at
> 38400.
>
> **RESULT EG — VOID, AND THE CAUSE IS THIS SHEET'S.** The Victor was
> fine; **the HOST refused the file.** `s16bdEG.ksc` said a bare
> `receive`, so the destination name came from the sender —
> `FIXTURE.DAT` → `fixture.dat` — and **that file has existed in the
> project directory since 11 August**. Packet log: S, F, A, then **Z with
> no data packets**, and the host printed *"No files were transferred
> (refused: destination file already exists)"*. Victor side: `elapsed=150
> cs`, `rxbytes=108`, `wfile n=0`.
>
> **This is the file-collision trap that §16ak lost two legs to and that
> §0 of this sheet documents — applied to the wrong end of the wire.**
> The rule was written as "every receive `.BAT` opens with `IF EXIST
> <target> DEL <target>`", which covers the Victor receiving and says
> nothing about a leg where the Victor SENDS and the host receives.
> §16bc's own `s16bcHB.ksc` had it right in one line — `receive
> gothb.dat`, an explicit fresh destination — and this sheet did not copy
> it. **THE FRESH-TARGET RULE BELONGS TO WHICHEVER END IS RECEIVING.**
> Fixed: `s16bdEG.ksc` now says `receive goteg.dat`.

---

## Tier 3 — the witnesses. Legs **EJ**, **EK**

### EJ — edit 23, and it is one line of a log

Edit 23 changes nothing this port does. `v9k_ser_setflow()` reads
upstream's `flow` variable and never the termios bits — §16aj established
that by measurement, after the first version of that function read the bits
and leg FB came back with the mode still off. So the **only** observable is
the cross-check `debug()` that `ckvictor.c` §1f carries for exactly this
purpose, written "so that the day it does change is visible rather than
inferred":

```
v9k_ser_setflow crtscts/ixon [0] 1
                              ^   ^
                     CRTSCTS -+   +- IXON|IXOFF, and this is the one
```

**It has read 0 for this port's entire life** because `ttpkt()`'s
`TESTING234` block cleared those bits four lines before the `tcsetattr()`
that applies the struct. **It must now read 1.**

- **The binary is `D:\CKFNFD.EXE`.** `CKFNF.EXE` is `NODEBUG` and will
  write no log at all. A `-d` flag with no binary behind it is a
  suggestion (§16aw), and §16bc broke that rule in the same sheet that
  quoted it.
- **Runs entirely on `D:`** — the debug log is large and `A:` has 336 KB.
- **The clock on this leg is not a result.** `-d` costs ~25 ms per received
  byte (§16k) and starves the ring on its own.
- **Behaviour must not change.** Byte-exact, and `held`/`xon`/`xoff`
  whatever they were.

> **RESULT EJ — EDIT 23 CONFIRMED ON HARDWARE.** From `D:\DEBUG.LOG`
> (39,274 bytes), in order through the run:
>
> ```
> setflow flow=0
> v9k_ser_setflow crtscts/ixon[0]=0     <- before ttpkt(), flow not yet XONX
> setflow flow=1                        <- FLO_XONX selected
> v9k_ser_setflow crtscts/ixon[0]=0
> v9k_ser_setflow crtscts/ixon[0]=1     <- ttpkt()'s struct, BITS INTACT
> v9k_ser_setflow crtscts/ixon[0]=1
> v9k_ser_setflow crtscts/ixon[0]=1
> v9k_ser_setflow crtscts/ixon[0]=1
> v9k_ser_setflow crtscts/ixon[0]=0     <- ttres() restoring at close
> ```
>
> **Four calls read 1 where this counter has read 0 for the port's entire
> life**, and the 0 → 1 → 0 shape across the transfer is exactly what edit
> 23 predicts: the bits arrive with `ttpkt()`'s struct and go away again
> when the original termios is restored. `flow in=1 out=1 hi=3072 lo=1024`
> confirms `--xonxoff` was actually selected. Transfer byte-exact,
> `rxlost=0 rxfull=0`, `deb=1`.
>
> `crtscts/ixon` reads: ☑ **1** ☐ 0 (edit 23 did not reach the wire)
>
> **The operator saw `Bad command or file name` on this leg and the leg
> nevertheless completed.** Which line printed it cannot be recovered from
> the artifacts, **because `ECHO OFF` suppressed the line that failed.**
> That is the whole argument against `ECHO OFF` and it is why every `.BAT`
> in this sheet was rewritten on 27 August: no `ECHO OFF`, an `ECHO`
> banner around the command, and `TYPE <leg>.OUT` at the end so the
> counters land on the screen instead of only in a file.

### EK — edit 26, regression only

Edit 26's failure path is **not reachable on this port** — `zfnqfp()`
succeeds here, which is exactly why the defect survived to be found by
reading rather than by failing. So this leg proves **no regression** and
nothing more. **Do not write it up as a confirmation of edit 26.**

What to check, in order:

1. **`REMOTE HELP` first** (§16ax): before concluding a feature does not
   work, check that the thing asking for it can ask.
2. `REMOTE DIRECTORY` completes over `A:`'s **193 root entries**, with a
   terminating Z, zero timeouts and zero retransmissions. §16aw listed 157
   in 31.077 s with the debug log **shut**; expect somewhat more here.
3. **The listing header reads `Listing files: <a real path>`** — that
   `%s` is `fnbuf`, and it is the thing edit 26 protects. Garbage there
   would mean the edit broke the success path.
4. A **collapsing** packet length (236 → 68) is a diagnosis, not a wedge
   (§16aw). So is a 10 s loop: that is the Victor correctly answering NAKs
   the host queued.

> **RESULT EK — PASS, no regression in `snddir()`.** `REMOTE HELP`
> answered (1,461 bytes). `REMOTE PWD` → `A:`. `REMOTE SPACE` → `Free
> space: 176K` (edit 20). **`REMOTE DIRECTORY` listed 202 files and 2
> directories, 8,443,975 bytes, with its Summary line**, 0 timeouts, 0
> retransmissions, 1 damaged packet.
>
> **The header reads `Listing files: A:/*`** — a real path, so edit 26 did
> not break the success path, which is all this leg was ever able to show.
> `dec max=1700 at #17` over the listing.

---

## What this sitting cannot answer

**Edit 24 is not exercised by any leg here, and no leg is proposed for it.**
`ttoc()` reaches `tcflow(TCOON)` only when a **single-character write has
timed out** *and* flow is `FLO_XONX` — that is, when the far end has XOFF'd
us and the XON never arrived. Nothing on this bench has ever produced that:
§16ak leg DX armed the interception path on a real cable and the host never
sent an XOFF at all (`xoff = 0`), and §16bc leg EJ's ancestor caught two
host **START** characters and no stops.

Manufacturing it would mean making the host hold the line off for longer
than `TTOC_TMO` — which is a test of the host, not of this port — and the
port carries its own backstop for the case anyway (`V9K_FCSPIN`, and edit
24 makes it belt-and-braces rather than sole). **Record edit 24 as shipped,
preprocessor-verified, and unexercised.** That is the honest state and it
belongs in the same list as the assembly ISR's overrun branch and the
flow-control assert's ring-full path — code that is written, reviewed, and
has never run.

**Two other standing gaps this sitting does not close:** nothing has yet
seen the host's CTS move at the moment the Victor's RTS does (§16an), and
`v9k/tools/wirenoise.py` has still never corrupted a real wire (§16av).

---

## After the sitting

- **Extract every artifact into `v9k/legs/` before deleting anything from
  the image.** §16bc found eight files that were on the image and not in
  the tree and would have been lost rather than merely deleted.
- `A:` has **336 KB free (42 clusters of 8,192)**. The run consumes about
  **16 clusters**: two 32 KB receives (EA, EB) and eight `.OUT` files at
  one cluster each. That leaves ~26 clusters of margin. **Out of disk is
  now `ENOSPC` rather than a hang** (§16av fixed `zoutdump()`'s loop), but
  a full volume is still the failure that looks most like a broken port.
- Update `PORTING.md` §8's "None of the four has run on hardware" and
  `NEXT_SESSION.md` item 8 with what actually happened.
- If edit 25 confirms, **the ~4.4 s belongs in every receive figure this
  port has ever published for `A:\`** — §16bc's note that the stall "is
  inside every whole-run 9600 figure this tree has published" now cuts the
  other way, and the figures that need restating should be listed rather
  than left to be rediscovered.


---

## What this sitting settled, and what it did not — 27 August 2026

**Settled:**

1. **No regression from any of the four edits.** Six transfers byte-exact,
   `rxlost=0 rxfull=0` on every leg, at 9600 and 38400, both volumes, plus
   a full server sweep. `+80` bytes of image, zero DGROUP.
2. **Edit 23 confirmed** — leg EJ, `crtscts/ixon[0]=1`, four times.
3. **Edit 26 no-regression** — leg EK, a real path in the listing header.
4. **Edit 25 is safe and moves `dec max` at `A:` decode #3 from 450 to
   350 cs**, twice independently (EB at 9600, EF at 38400).

**Not settled: the size of edit 25's saving**, and the sitting cannot be
argued into settling it. Two of four legs went off-shape and the clock
comparison is void by the sheet's own rule 3.

**Retracted from §16bc:** the whole 4.4 s `A:\` penalty is **not** the
create/delete pair. After edit 25 the `A:`-vs-`D:` gap is still ~4.2 s of
non-line cost. §16bc's own evidence said so and was over-read — it found
**four stats, one CREATE and one DELETE**, and only the last two are gone.

### The re-run, and why it is cheaper than it looks

**Use `dec max` as the primary instrument and the clock as secondary.**
`dec max` reads one decode interval, so a retransmission elsewhere in the
transfer does not contaminate it — which is exactly the failure that voided
EA/EB. It is quantised at 50 cs, so it cannot resolve better than 0.5 s;
that is enough for a 1 s effect and not enough for the residual.

- **Three legs per arm, four arms — EA/EB/EC/ED × 3.** Take the modal
  `dec max`. Reject any leg whose wire bytes differ from its arm's mode.
- **Then one `-d` leg into `A:\`** with `CKFNFD.EXE` to find out what the
  remaining ~4 s is. §16bc leg HP was staged for this and never ran, and
  §16aw permits `-d` here because the target is a discrete multi-second
  event and not a throughput claim. **That is the leg that matters now** —
  the magnitude question is secondary to knowing what the other three
  seconds are.

### PRECONDITION FOR ANY RE-RUN: `A:` IS DOWN TO 176 KB

**203 files, 176 KB free (1.8%), 22 clusters.** A single re-run pass needs
about 16 clusters and three passes need far more. **Clear the E-series
artifacts first** — they are all extracted into the tree already
(`STEPE*.OUT`, `RCVE{A,B,F}.DAT` on `A:`, `RCVE{C,D,J}.DAT` and
`DEBUG.LOG` on `D:`). Deleting them returns ~14 clusters and drops the root
population by ~10 entries, which slightly weakens the very effect under
test; **record the entry count with the result.**

### Harness changes made 27 August

1. **`ECHO OFF` is gone from all eight `.BAT` files and is not coming
   back.** When leg EJ printed `Bad command or file name` and still
   completed, nothing in the artifacts could say which of six lines said
   it. Every line now echoes, including the REM commentary, there is an
   `ECHO` banner around the command, and each `.BAT` ends with **`TYPE
   <leg>.OUT`** so the counters appear on screen rather than only in a
   file the operator has to go and find.
2. **`s16bdEG.ksc` receives into `goteg.dat`**, an explicit fresh name.
3. **New §0 row for the next sheet:** *on a leg where the VICTOR SENDS,
   the host is the receiver — give it a fresh destination name.* The
   existing rule only ever covered the Victor.


---

## Round 2 — 27 August 2026. Legs EG, EL, EM

**RESULT EG — VOID AGAIN, AND MY ROUND-1 FIX CAUSED IT.** Adding an
explicit as-name (`receive goteg.dat`) cured the collision refusal and
introduced a prompt: C-Kermit asks **`Accept incoming file "...goteg.dat"?`**
on stdin, and the take-file's stdout is redirected, so the question went
into `s16bdEG.host` and the run waited for a key nobody could see. Ran
twice, hung both times.

**NEXT_SESSION documents this exact trap — for the VICTOR side.**
`RXEA.KSC` carries `set receive confirm off` and `set exit warning off`,
and **no host-side take-file in this tree had ever needed them**, because
none had used an as-name. Both lines are now in `s16bdEG.ksc`. **The rule
is the general one: any take-file whose stdout is redirected must disable
every interactive prompt, on whichever end it runs.**

**RESULT EL / EM — the round's question, answered.** Both byte-exact,
`rxlost=0 rxfull=0`, `deb=1`, identical fixtures (`33bab046…`).

**1. Edit 25 is confirmed BY INSPECTION, no clock involved.** `A:\DEBUG.LOG`:

```
zchko attempting to open[rcvel.dat]
zchko open[rcvel.dat]=-1
zchko does not exist, not probed[rcvel.dat]      <- edit 25's new branch
zchko access[.]
```

**No `isatty`, no `delete ok`.** The create and the delete are gone, on
both volumes.

**2. And the `A:` penalty is STILL THERE.** `gtimer` across the
F-packet-to-ACK window:

| | root entries | gap |
|---|---:|---:|
| **EL** (`A:`) | ~203 | **+5 s** |
| **EM** (`D:`) | 28 | **+1 s** |

**3. The two syscall sequences are IDENTICAL** — same operations, same
order, only the volume letter differs. So the ~4 s is **not an extra
operation; it is the per-operation cost**, and what that window contains is
**four negative lookups of a name that is not there**: `isdir` stat,
`zchko`'s `open` → ENOENT, `zchki` stat, and `isdir` on the qualified path,
plus `access[.]` and `zgtdir`. **A negative lookup must scan the whole root
to prove absence**, so each one walks 203 entries on `A:` and 28 on `D:`.

**THE RESIDUAL IS NAMED: repeated full-root negative lookups in
`rcvfil()`, not disk writes.** `zchko()`, `zchki()` and `zmkdir()/zfnqfp()`
each independently stat the same absent name. **§16bc's attribution of the
whole 4.4 s to the create/delete pair is retracted, and this sheet repeated
it** — the create and delete are provably gone and ~4 s remains. Edit 25's
real saving is the ~1 s that `dec max` showed (450 → 350).

### Leg EN — staged, and it closes the subtraction

The one thing EL/EM cannot give is **the same measurement without edit 25**,
because the shipping control `CKBB.EXE` is `NODEBUG` and writes no log.
**`CKBBD.EXE` — 314,168, md5 `23e77b89…`, HEAD minus edits 23–26 built with
`KEEP_DEBUG` — is now staged on `D:`**, with `STEPEN.BAT` and
`s16bdEN.ksc`. Expect to see, exactly where EL says *"does not exist, not
probed"*:

```
zchko open[rcven.dat]=<fd>
zchko isatty[rcven.dat]=0
zchko delete ok[rcven.dat]
```

and a `gtimer` gap to subtract from EL's +5 s.

### ⚠ `A:` IS AT 88 KB FREE (0.9%), 210 FILES

**Clear it before running EN.** EN writes a ~39 KB `DEBUG.LOG`, a `.OUT`
and a 512-byte file — about 7 of the 11 remaining clusters. Everything from
rounds 1 and 2 is already extracted into the tree.


---

## Round 3 — leg EN. **Edit 25 is measured: it saves exactly 1.0 s.**

Byte-exact, `rxlost=0 rxfull=0`, same 512-byte fixture (`33bab046…`).

**The A/B by inspection, which needs no clock at all:**

| | EN — `CKBBD`, no edit 25 | EL — `CKFNFD`, edit 25 |
|---|---|---|
| | `zchko open[rcven.dat]=7` | `zchko open[rcvel.dat]=-1` |
| | `zchko isatty[rcven.dat]=0` | `zchko does not exist, not probed` |
| | `zchko delete ok[rcven.dat]` | *(nothing)* |

**The control creates a real descriptor and deletes the file; the treatment
does neither.** Edit 25 does exactly what it was written to do.

**And the clock, aligned on the `gtimer` reset:**

| step | EN (`A:`, no 25) | EL (`A:`, 25) | EM (`D:`, 25) | EN−EL | EL−EM |
|---|---:|---:|---:|---:|---:|
| reset | 1 | 1 | 1 | 0 | 0 |
| **F→ACK** | **7** | **6** | **2** | **1** | **4** |
| …14 further readings… | | | | **1 every time** | 3–5 |
| end | 29 | 28 | 23 | **1** | 5 |

**`EN − EL` is 1 second at every one of fourteen successive readings.** The
step is introduced precisely in the F-packet-to-ACK window and carried
unchanged to the end — a step function, not noise. **Total elapsed agrees
independently and exactly: 3600 cs against 3500 cs.**

### The answer, in three numbers

- **The `A:\` receive penalty is 5 s per file** (EL's F→ACK window against
  EM's 1 s on a 28-entry root).
- **Edit 25 removes 1.0 s of it.**
- **4.0 s remains, and it is upstream's `rcvfil()`, not `zchko()`'s
  writes.** Four independent negative lookups of the same absent name —
  `isdir` stat, `zchko`'s `open` → ENOENT, `zchki` stat, `isdir` on the
  qualified path — each of which must scan the entire root to prove the
  name is not there. 211 entries on `A:`, 28 on `D:`.

**§16bc's "the `A:\` stall is `zchko()` creating and deleting a file" is
therefore RETRACTED at four-fifths.** The create and delete are real, are
measurable, and are 1 s of 5. **This sheet's own predictions repeated
§16bc's figure and were wrong by 4×** — written down here rather than
quietly corrected, because the error was in reading a mechanism off a
single leg that had no way to separate the create from the lookups around
it.

### What it means for the port

**Receiving into a directory with few entries costs 1 s instead of 5.**
That also explains a result nobody had explained: **§16ba leg VF received
into a SUBDIRECTORY of the volume that VA stalled on and was ACKed at
t+2** — a fresh subdirectory has almost no entries, so its negative lookups
are cheap. Two sittings apart, same mechanism.

**The 4 s is a report-upstream item with a hard number behind it now**, and
it belongs beside the `zchko()` design note already in `PORTING.md` §8's
report list.


---

## Closing — and one process rule that cost this sitting two extra trips

**§16bd is COMPLETE. Leg EG was retired unrun, deliberately.** It tested
nothing: edit 25 is receive-only (`zchko()` asks whether an *output* file
can be created, and a sending Victor creates none), edit 26's path is
`REMOTE DIRECTORY` which leg EK covered, edit 23's `ttpkt()` call is one
call at packet-mode entry and is identical in both directions — **leg EF
already exercised it at 38400** — and edit 16's ≥32,768 send-by-name range
has four hardware confirmations already (§16ah BS, §16ay, §16az, §16bc HB).
EG was a completeness box with no hypothesis behind it. `STEPEG.BAT` and
`s16bdEG.ksc` stay in the tree, fixed, for whenever the machine is up for
another reason.

### THE RULE: BATCH BY SITTING, NOT BY QUESTION

**Bench setup costs 5-6 minutes; a leg costs 30 seconds.** Setup dominates
by an order of magnitude, so the unit of planning is **the sitting, not the
leg**. This sheet ran three sittings where one would have done:

| round | legs | why it was its own trip |
|---|---|---|
| 1 | EA EB EC ED EF EG EJ EK | — |
| 2 | EG EL EM | EL/EM were designed *after* round 1's result |
| 3 | EN | EN was designed *after* round 2's result, **and EG was left out of it for no reason** |

Rounds 2 and 3 were each one leg's worth of new thinking. **EN could have
been staged alongside EL/EM**: its purpose — a `-d` control without edit 25
— was predictable the moment EL was designed, because the shipping control
is `NODEBUG` and that was known before either was written.

**Before ending any sitting's staging, ask: what will the plausible RESULTS
of these legs make me want to run next, and can I stage that now?** A
control binary that costs one `make` and 300 KB of `D:` is always worth
staging speculatively. A leg that turns out to be unnecessary costs 30
seconds; a leg that was not staged costs another 5-6 minute setup.

**And do not report an unrun leg as an outstanding item unless it was
actually asked for.** Round 3 asked for EN and got EN; listing EG as "still
unrun" afterwards put a planning failure on the operator's side of the
ledger.
