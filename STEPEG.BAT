REM ==== LEG EG : REGRESSION, SEND 32,768 bytes BY NAME at 38400 ====
REM Every line of this .BAT echoes.  There is no ECHO OFF and there
REM will not be one: when a leg fails you must be able to see WHICH
REM LINE failed.  Leg EJ printed 'Bad command or file name' on 26 Aug
REM and ECHO OFF meant neither the operator nor the log could say
REM which of six lines said it.
ECHO.
ECHO === LEG EG STARTING ===
REM *** START THE HOST RECEIVER FIRST.  The Victor is the initiator. ***
REM
REM THIS LEG FAILED ON 26 AUG AND THE CAUSE WAS ON THE HOST, NOT HERE:
REM the host take-file said a bare 'receive', so the destination name
REM came from us -- fixture.dat -- and that file already existed on the
REM Mac, so the host REFUSED it in the A-packet ACK.  Signature: S, F, A,
REM then Z, no data packets, 'No files were transferred (refused:
REM destination file already exists)'.  s16bdEG.ksc now says
REM 'receive goteg.dat'.  THE FRESH-TARGET RULE APPLIES TO WHICHEVER END
REM IS RECEIVING, and on a send leg that is the host.
IF EXIST STEPEG.OUT DEL STEPEG.OUT
ECHO Sending A:\FIXTURE.DAT (32768 bytes) at 38400 ...
D:\CKFNF.EXE -l /dev/seriala -b 38400 -s FIXTURE.DAT > STEPEG.OUT
ECHO.
ECHO === LEG EG DONE -- counters follow ===
TYPE STEPEG.OUT
