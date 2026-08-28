REM ==== LEG ED : THE NULL LEG.  Treatment on the SPARSE root ====
REM Every line of this .BAT echoes.  There is no ECHO OFF and there
REM will not be one: when a leg fails you must be able to see WHICH
REM LINE failed.  Leg EJ printed 'Bad command or file name' on 26 Aug
REM and ECHO OFF meant neither the operator nor the log could say
REM which of six lines said it.
ECHO.
ECHO === LEG ED STARTING ===
REM Edit 25 has almost nothing to remove on 28 root entries.
REM ED should EQUAL EC.  If it does not, EB's saving is not zchko().
IF EXIST A:\STEPED.OUT DEL A:\STEPED.OUT
ECHO Switching to D:
D:
IF EXIST RCVED.DAT DEL RCVED.DAT
IF EXIST RCVED.001 DEL RCVED.001
ECHO Running D:\CKFNF.EXE -r into D: ...
D:\CKFNF.EXE --nodisplay -l /dev/seriala -b 9600 -r > A:\STEPED.OUT
ECHO Switching back to A:
A:
ECHO.
ECHO === LEG ED DONE -- counters follow ===
TYPE STEPED.OUT
