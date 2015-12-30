@echo off
echo Starting Api Cache...
net start %ApiCacheSrv%
if %errorlevel% NEQ 0 goto Error

echo Starting Api Host...
net start %ApiHostSrv%
if %errorlevel% NEQ 0 goto Error

echo Starting Admin...
%Windir%\System32\inetsrv\appcmd start apppool %AdminAppPool%
if %errorlevel% NEQ 0 goto Error

echo Starting Web...
%Windir%\System32\inetsrv\appcmd start apppool %WebAppPool%
if %errorlevel% NEQ 0 goto Error

exit /b 0
:Error
echo An error has occurred
exit /b %errorlevel%