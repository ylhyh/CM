@echo off
set InputVal=%1
set CountLength=3

set len=0
:CalcLength
call set subStr=%%InputVal:~%len%,1%%
if "%subStr%" NEQ "" (
    set /a len+=1
    goto CalcLength
)

if %len% LSS %CountLength% (
    set InputVal=0%InputVal%
    goto CalcLength
)

echo %InputVal%