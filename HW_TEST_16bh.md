# §16bh — post-merge regression: C-Kermit 11.0.509 under MAME

**6 September 2026, no Victor in reach.** `866e5c5` merged 25 upstream
commits (the 11.0.509 release, the musl static-lib pin refresh, John
Goerzen's jump-reduction and warn-reduction branches) onto the port branch,
and picked up a 27th upstream edit to make it compile at all. This is the
regression that says the port still works, in the §16ay/§16az style: every
leg reproduces a result an earlier section already established, so a
difference is a defect and not a discovery.

**Why this sitting is smaller than §16ay's.** 11.0.508 was 77 commits across
thirteen files and needed five legs to cover the ground. 11.0.509 is 25
commits, one real conflict, and every substantive change is confined to
`ckutio.c`'s signal/timeout plumbing (`ttoc()`'s `sigsetjmp`→`goto
ttoc_failed` refactor, `deadline_signal()`). Nothing in the diff touches the
ISR, the receive ring, the chip-programming path, or the protocol core.
`ckvictor.c` and `ckvisr.asm` are untouched (not upstream files, so the diff
below can't see them, but neither this merge nor edit 27 changed a line of
either). **Three legs, not five, and CONNECT — the only functional consumer
of the code that actually changed — is one of them.**

Batch the whole sheet in one sitting (the batching memory): setup is
5–6 min, a leg is ~30 s under MAME.

---

## §0 — preconditions, checked before any leg runs

0a. **All 27 edits verified intact, by diff rather than by grep** (§16ay's
    method — a `VICTOR9K` grep can't see an edit that kept its text and lost
    its guard). The merge commit `866e5c5` has an upstream parent
    (`866e5c5^2` = `c77cec3`), so `git diff c77cec3 HEAD -- <the 9 files
    ckutio.c/ckufio.c/ckcfns.c/ckcfn2.c/ckcmai.c/ckcnet.c/ckucmd.c/ckuusr.c/
    ckcdeb.h/ckcfnp.h>` is, by construction, the port's edits and nothing
    else: **591 insertions, 30 deletions, 9 files** — matches §8's list with
    edit 27 now in it. Run this again after staging the leg binary to
    confirm nothing drifted between the merge commit and what's on the
    image.

0b. **Build is clean.** `make -f victorow.mak` (24 objects), then `make -f
    victorow.mak sizes`. Expect DGROUP 48,912/65,536 (74%), `ckermitw.exe`
    233,942 bytes, 19 warning lines (all pre-existing, `ckvictor.c` at 0).
    `python3 v9k/tools/mzsize.py ckermitw.exe` → needs 245,750 (239K),
    smallest Victor 384K.

0c. **Image free space** — `vtg_image_util info ~/projects/mame/victor_kermit.img`.
    Partition 0 (A:) was at 1.3% free as of the last check; delete stale
    `RCV*.DAT`/`STEP*.OUT` from earlier sittings before staging fresh
    fixtures if a leg can't fit.

0d. **`CKERMITW.EXE` staged and round-trips.** Already done this session —
    `vtg_image_util copy ckermitw.exe victor_kermit.img:0:\CKERMITW.EXE`,
    verified md5 `cc537513…` both directions. Re-verify if anything above
    was rebuilt after that copy.

0e. **Target names are fresh.** `SET FILE COLLISION` is BACKUP and can't
    work on FAT — every receive `.BAT` opens with `IF EXIST <target> DEL
    <target>`. Names below: `RCVHA.DAT`.

0f. **`v9k/proofs`** — `make -C v9k/proofs` (vcrc16, vburst, vttinl, vwindow,
    vznewn). None of these touch the changed code, but they're free and
    they're the standing correctness argument for the edits that share a
    file with this merge (17, 18, 21 all live in `ckufio.c`/`ckcfns.c`,
    which the diff in 0a shows moved a fair amount from unrelated upstream
    changes — worth confirming they still pass rather than assuming a clean
    diff means a clean proof).

---

## The legs

All at 9600 under MAME on Victor MS-DOS 3.1, `socat` first, MAME second,
host `kermit` at t+110 s.

| leg | what it reproduces | what would count as a regression |
|---|---|---|
| HA | 32 KB receive — every `ttinl()`/receive-side `deadline_signal()` call site on this path (edits 11, 17, 18 also ride along) | anything but byte-exact, or `rxlost`/`rxfull` non-zero, or a hang (a broken `signal()` install/disarm would show up as either a spurious early timeout or an alarm that never fires) |
| HC | 32,768-byte send **by name** — the send-side `deadline_signal()` sites, upstream edit 16's exact range | `-s` refusing the file, a non-md5-identical arrival, or a send that hangs waiting on an alarm that never fires |
| HE | CONNECT Tier 1 entry → escape menu → `RECEIVE` → reconnect (§16be's CA/CD, reproduced) — **the only leg that actually exercises `ttoc()`**, the function the real conflict was in | banner/menu not appearing, typed characters not reaching the far end, the escape-and-reconnect round trip failing, or anything to do with `ttoc()`'s alarm setup silently going missing |

**What none of these three legs can exercise, and why that's unchanged by
this merge:** the `ttoc_failed` POSIX-recovery branch that edit 24 lives in
only runs on an actual write timeout under `FLO_XONX`, and no host on this
bench has ever sent an XOFF (§16bd) — that was already true before this
merge and this merge didn't touch what would make it newly reachable. HE
confirms the *common* path through the refactored `ttoc()` (the write
succeeds, `ttimoff()`/`alarm(xx)` run, function returns 0); it does not
confirm the failure path. That gap is pre-existing, not new.

---

## What a clean sitting looks like

- **0a**: 591/30/9 diff, nothing missing.
- **HA/HC**: byte-exact both directions, `rxlost=0 rxfull=0`.
- **HE**: banner, menu, both-directions typing, clean escape → RECEIVE →
  reconnect, byte-exact `RCVHA.DAT` — i.e., §16be's CONNECT result,
  unmoved.

Write the results into `PORTING.md` §16bh (already drafted with the merge
and edit 27; append a "confirmed under MAME" paragraph rather than a new
section) and, if any leg regresses, treat `ttutio.c`'s new `ttoc_failed`
structure or `deadline_signal()` as the first suspect before anything else
in the 9-file diff — it's the only place behavior actually changed.

**Not planned as part of this sitting: a hardware leg.** Nothing in this
merge touches the ISR, the ring, or chip programming, so there's no new
38400/real-silicon risk to retire. If HA/HC/HE all pass under MAME, that's
sufficient confirmation for a merge of this shape — reserve bench time for
work that actually changes timing-sensitive code.
