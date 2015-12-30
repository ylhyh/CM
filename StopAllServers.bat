@echo off

echo Stopping Web...
for /f "tokens=4 delims=:)" %%i in ('%Windir%\System32\inetsrv\appcmd list apppool %WebAppPool%') do set ServiceStatus=%%i
if '%ServiceStatus%' EQU 'Started' (
    %Windir%\System32\inetsrv\appcmd stop apppool %WebAppPool%
)
if %errorlevel% NEQ 0 goto Error

echo Stopping Admin...
for /f "tokens=4 delims=:)" %%i in ('%Windir%\System32\inetsrv\appcmd list apppool %AdminAppPool%') do set ServiceStatus=%%i
if '%ServiceStatus%' EQU 'Started' (
    %Windir%\System32\inetsrv\appcmd stop apppool %AdminAppPool%
)
if %errorlevel% NEQ 0 goto Error

echo Stopping Api Host...
for /f "tokens=3 delims= " %%i in ('SC QUERY %ApiHostSrv% ^| find "STATE "') do set ServiceStatus=%%i
if '%ServiceStatus%' EQU '4' (
	echo %ApiHostSrv% is running, try to stop it...
	net stop %ApiHostSrv%
)
if %errorlevel% NEQ 0 goto Error

echo Stopping Api Cache...
for /f "tokens=3 delims= " %%i in ('SC QUERY %ApiCacheSrv% ^| find "STATE "') do set ServiceStatus=%%i
if '%ServiceStatus%' EQU '4' (
	echo %ApiCacheSrv% is running, try to stop it...
	net stop %ApiCacheSrv%
)
if %errorlevel% NEQ 0 goto Error

exit /b 0
:Error
echo An error has occurred
exit /b %errorlevel%