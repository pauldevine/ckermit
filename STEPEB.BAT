REM ==== LEG EB : TREATMENT.  Same leg as EA, one binary over ====
REM Every line of this .BAT echoes.  There is no ECHO OFF and there
REM will not be one: when a leg fails you must be able to see WHICH
REM LINE failed.  Leg EJ printed 'Bad command or file name' on 26 Aug
REM and ECHO OFF meant neither the operator nor the log could say
REM which of six lines said it.
ECHO.
ECHO === LEG EB STARTING ===
REM Binary D:\CKFNF.EXE (231,252, 039fae2a) -- edits 23-26.
REM Read dec max= at decode #3 on the counters below.  EA should say 450.
IF EXIST RCVEB.DAT DEL RCVEB.DAT
IF EXIST RCVEB.001 DEL RCVEB.001
IF EXIST STEPEB.OUT DEL STEPEB.OUT
ECHO Running D:\CKFNF.EXE -r into A: ...
D:\CKFNF.EXE --nodisplay -l /dev/seriala -b 9600 -r > STEPEB.OUT
ECHO.
ECHO === LEG EB DONE -- counters follow ===
TYPE STEPEB.OUT
