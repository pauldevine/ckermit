REM ==== LEG EC : CONTROL on the SPARSE root.  Receive into D: at 9600 ====
REM Every line of this .BAT echoes.  There is no ECHO OFF and there
REM will not be one: when a leg fails you must be able to see WHICH
REM LINE failed.  Leg EJ printed 'Bad command or file name' on 26 Aug
REM and ECHO OFF meant neither the operator nor the log could say
REM which of six lines said it.
ECHO.
ECHO === LEG EC STARTING ===
REM The .OUT goes to A: on purpose -- D: is the variable under test.
REM If the D: or A: lines below fail you will SEE them now.
IF EXIST A:\STEPEC.OUT DEL A:\STEPEC.OUT
ECHO Switching to D:
D:
IF EXIST RCVEC.DAT DEL RCVEC.DAT
IF EXIST RCVEC.001 DEL RCVEC.001
ECHO Running D:\CKBB.EXE -r into D: ...
D:\CKBB.EXE --nodisplay -l /dev/seriala -b 9600 -r > A:\STEPEC.OUT
ECHO Switching back to A:
A:
ECHO.
ECHO === LEG EC DONE -- counters follow ===
TYPE STEPEC.OUT
