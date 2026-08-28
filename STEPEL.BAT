REM ==== LEG EL : MECHANISM.  -d receive into A: -- what IS the residual? ====
REM Every line echoes.  No ECHO OFF -- if a line fails you must see it.
ECHO.
ECHO === LEG EL STARTING ===
REM BINARY IS D:\CKFNFD.EXE (314,120, 64ba06ed) -- the KEEP_DEBUG build.
REM CKFNF.EXE is NODEBUG and writes no log.
REM
REM THIS IS THE LEG SS16bc STAGED AS HP AND NEVER RAN.
REM Read A:\DEBUG.LOG for the gtimer jump between the F packet and its
REM ACK.  SS16bc saw +5 s there containing FOUR STATS, ONE CREATE and ONE
REM DELETE.  Edit 25 should have removed the create and the delete.
REM   - if they are gone, edit 25 is confirmed BY INSPECTION, no clock;
REM   - whatever is still in that gap IS the ~3 s residual, named.
REM
REM 512-byte fixture ON PURPOSE: the stall is before any data moves, and
REM -d costs ~25 ms per received byte (SS16k).  The clock is NOT a result.
IF EXIST RCVEL.DAT DEL RCVEL.DAT
IF EXIST RCVEL.001 DEL RCVEL.001
IF EXIST STEPEL.OUT DEL STEPEL.OUT
IF EXIST DEBUG.LOG DEL DEBUG.LOG
ECHO Running D:\CKFNFD.EXE -d -r into A: (populated root) ...
D:\CKFNFD.EXE -d --nodisplay -l /dev/seriala -b 9600 -r > STEPEL.OUT
ECHO Log is A:\DEBUG.LOG -- do not overwrite it before extracting.
ECHO.
ECHO === LEG EL DONE -- counters follow ===
TYPE STEPEL.OUT
