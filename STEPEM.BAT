REM ==== LEG EM : CONTROL for EL.  Same -d leg one VOLUME over ====
REM Every line echoes.  No ECHO OFF -- if a line fails you must see it.
ECHO.
ECHO === LEG EM STARTING ===
REM D: has 28 root entries against A:'s 200-odd.  Same binary, same
REM fixture, same rate -- ONE VARIABLE, the volume.  Diff the two
REM DEBUG.LOGs around rcvfil() and the difference is the directory cost.
REM RUN THIS IMMEDIATELY AFTER EL.
IF EXIST A:\STEPEM.OUT DEL A:\STEPEM.OUT
ECHO Switching to D:
D:
IF EXIST RCVEM.DAT DEL RCVEM.DAT
IF EXIST RCVEM.001 DEL RCVEM.001
IF EXIST DEBUG.LOG DEL DEBUG.LOG
ECHO Running D:\CKFNFD.EXE -d -r into D: (sparse root) ...
D:\CKFNFD.EXE -d --nodisplay -l /dev/seriala -b 9600 -r > A:\STEPEM.OUT
ECHO Switching back to A:
A:
ECHO.
ECHO === LEG EM DONE -- counters follow ===
TYPE STEPEM.OUT
