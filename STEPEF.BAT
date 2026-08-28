REM ==== LEG EF : REGRESSION at 38400, receive ====
REM Every line of this .BAT echoes.  There is no ECHO OFF and there
REM will not be one: when a leg fails you must be able to see WHICH
REM LINE failed.  Leg EJ printed 'Bad command or file name' on 26 Aug
REM and ECHO OFF meant neither the operator nor the log could say
REM which of six lines said it.
ECHO.
ECHO === LEG EF STARTING ===
REM Pass is byte-exact + rxlost=0 rxfull=0.  The clock is NOT the result.
IF EXIST RCVEF.DAT DEL RCVEF.DAT
IF EXIST RCVEF.001 DEL RCVEF.001
IF EXIST STEPEF.OUT DEL STEPEF.OUT
ECHO Running D:\CKFNF.EXE -r at 38400 into A: ...
D:\CKFNF.EXE --nodisplay -l /dev/seriala -b 38400 -r > STEPEF.OUT
ECHO.
ECHO === LEG EF DONE -- counters follow ===
TYPE STEPEF.OUT
