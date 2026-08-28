REM ==== LEG EA : CONTROL for edit 25.  32 KB receive into A: at 9600 ====
REM Every line of this .BAT echoes.  There is no ECHO OFF and there
REM will not be one: when a leg fails you must be able to see WHICH
REM LINE failed.  Leg EJ printed 'Bad command or file name' on 26 Aug
REM and ECHO OFF meant neither the operator nor the log could say
REM which of six lines said it.
ECHO.
ECHO === LEG EA STARTING ===
REM Binary D:\CKBB.EXE (231,172, c42c3598) -- HEAD BEFORE edits 23-26.
REM RUN EB IMMEDIATELY AFTER THIS.  One variable: the binary.
IF EXIST RCVEA.DAT DEL RCVEA.DAT
IF EXIST RCVEA.001 DEL RCVEA.001
IF EXIST STEPEA.OUT DEL STEPEA.OUT
ECHO Running D:\CKBB.EXE -r into A: ...
D:\CKBB.EXE --nodisplay -l /dev/seriala -b 9600 -r > STEPEA.OUT
ECHO.
ECHO === LEG EA DONE -- counters follow ===
TYPE STEPEA.OUT
