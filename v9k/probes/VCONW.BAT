ECHO OFF
REM item 18 probe: console write throughput (writes VCONW.OUT itself)
IF EXIST VCONW.OUT DEL VCONW.OUT
VCONW
