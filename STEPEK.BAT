REM ==== LEG EK : EDIT 26 REGRESSION -- server mode, the host drives ====
REM Every line of this .BAT echoes.  There is no ECHO OFF and there
REM will not be one: when a leg fails you must be able to see WHICH
REM LINE failed.  Leg EJ printed 'Bad command or file name' on 26 Aug
REM and ECHO OFF meant neither the operator nor the log could say
REM which of six lines said it.
ECHO.
ECHO === LEG EK STARTING ===
REM Watch for 'Listing files: <a real path>' in the host's dir output.
REM That %s is fnbuf, and it is what edit 26 protects.
REM The host ends this with FINISH.  Type Ctrl-C only if it wedges.
IF EXIST STEPEK.OUT DEL STEPEK.OUT
ECHO Entering server mode at 9600 ...
D:\CKFNF.EXE --nodisplay -l /dev/seriala -b 9600 -x > STEPEK.OUT
ECHO.
ECHO === LEG EK DONE -- counters follow ===
TYPE STEPEK.OUT
