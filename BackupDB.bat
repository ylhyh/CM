@echo off

set SQLFile=%temp%\BackupSQL_%random%.bat

echo DECLARE @datetime char(14);> %SQLFile%
echo DECLARE @withname varchar(1024);>> %SQLFile%
echo DECLARE @diskfile varchar(1024);>> %SQLFile%
echo set @datetime = CONVERT(char(8),getdate(),112) + REPLACE(CONVERT(char(8),getdate(),108),':','');>> %SQLFile%
echo set @withname = '%DBName%_' + @datetime;>> %SQLFile%
echo set @diskfile = '%DBBackupPath%\%DBName%_' + @datetime + '.bak';>> %SQLFile%
echo BACKUP DATABASE [%DBName%] TO DISK = @diskfile WITH NAME = @withname;>> %SQLFile%
echo GO >> %SQLFile%

sqlcmd -b -S %DBServer% -U %DBUser% -P "%DBPass%" -d %DBName% -i "%SQLFile%"
if %errorlevel% NEQ 0 goto Error

del "%SQLFile%"

exit /b 0

:Error
echo An error has occurred
if %errorlevel% EQU 0 (
    exit /b 1
) else (
    exit /b %errorlevel%
)