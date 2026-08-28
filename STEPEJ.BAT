REM ==== LEG EJ : EDIT 23 WITNESS -- the only leg that can see it ====
REM Every line of this .BAT echoes.  There is no ECHO OFF and there
REM will not be one: when a leg fails you must be able to see WHICH
REM LINE failed.  Leg EJ printed 'Bad command or file name' on 26 Aug
REM and ECHO OFF meant neither the operator nor the log could say
REM which of six lines said it.
ECHO.
ECHO === LEG EJ STARTING ===
REM BINARY IS D:\CKFNFD.EXE (314,120, 64ba06ed) -- the KEEP_DEBUG build.
REM CKFNF.EXE is NODEBUG and writes no log at all.
REM The result is one line of D:\DEBUG.LOG:
REM     v9k_ser_setflow crtscts/ixon[0]=1
REM It read 0 for this port's whole life.  Edit 23 must make it 1.
REM The clock on this leg is meaningless: -d costs ~25 ms per byte.
IF EXIST A:\STEPEJ.OUT DEL A:\STEPEJ.OUT
ECHO Switching to D:
D:
IF EXIST RCVEJ.DAT DEL RCVEJ.DAT
IF EXIST DEBUG.LOG DEL DEBUG.LOG
ECHO Running D:\CKFNFD.EXE -d --xonxoff -r into D: ...
D:\CKFNFD.EXE -d --xonxoff --nodisplay -l /dev/seriala -b 9600 -r > A:\STEPEJ.OUT
ECHO Switching back to A:
A:
ECHO.
ECHO === LEG EJ DONE -- counters follow ===
TYPE STEPEJ.OUT
