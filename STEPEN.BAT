REM ==== LEG EN : CONTROL for EL.  -d receive into A: WITHOUT edits 23-26 ====
REM Every line echoes.  No ECHO OFF.
ECHO.
ECHO === LEG EN STARTING ===
REM BINARY IS D:\CKBBD.EXE (314,168, 23e77b89) -- HEAD BEFORE edits 23-26,
REM built with KEEP_DEBUG.  It is the ONLY binary that can show the
REM zchko() create+delete actually happening, because the shipping
REM control CKBB.EXE is NODEBUG and writes no log.
REM
REM EL (with edit 25) showed the F-packet-to-ACK gap at +5 s on A: and
REM EM showed +1 s on D:.  This leg gives the SAME measurement on A:
REM WITHOUT edit 25, so the before/after is one subtraction instead of a
REM cross-sitting guess.  Expect to SEE in the log, where EL had
REM 'zchko does not exist, not probed':
REM     zchko open[rcven.dat]=<fd>
REM     zchko isatty[rcven.dat]=0
REM     zchko delete ok[rcven.dat]
REM
REM SAME 512-BYTE FIXTURE as EL.  The clock is not a result; the gtimer
REM jump in the log is.
IF EXIST RCVEN.DAT DEL RCVEN.DAT
IF EXIST RCVEN.001 DEL RCVEN.001
IF EXIST STEPEN.OUT DEL STEPEN.OUT
IF EXIST DEBUG.LOG DEL DEBUG.LOG
ECHO Running D:\CKBBD.EXE -d -r into A: (populated root, NO edit 25) ...
D:\CKBBD.EXE -d --nodisplay -l /dev/seriala -b 9600 -r > STEPEN.OUT
ECHO Log is A:\DEBUG.LOG -- extract it before running anything else.
ECHO.
ECHO === LEG EN DONE -- counters follow ===
TYPE STEPEN.OUT
