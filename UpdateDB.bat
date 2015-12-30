@echo off

set CMDBServer=192.168.45.19
set CMDBUser=cm
set CMDBPass=cm@10160915
set CMDBName=CM

svn info
if %errorlevel% NEQ 0 goto Error

for /f "tokens=4 delims= " %%i in ('svn info ^| find "Last Changed Rev: "') do set LastRev=%%i
@echo Last Changed Revision: %LastRev%

if %errorlevel% NEQ 0 goto Error

sqlcmd -b -S %CMDBServer% -U %CMDBUser% -P %CMDBPass% -d %CMDBName% -Q "SELECT 'Max Revision Number:' + CONVERT(VARCHAR,ISNULL(Max(RevisionNumber),0)) MaxRev FROM DBUpdateHistory WHERE DBServer='%DBServer%' AND DBName='%DBName%' AND Success=1" > %CurDir%\temp_maxrev_query.tmp

if %errorlevel% NEQ 0 goto Error

for /f "tokens=2 delims=:" %%i in ('findstr /C:"Max Revision Number:" "%CurDir%\temp_maxrev_query.tmp"') do set PrevRev=%%i

if %errorlevel% NEQ 0 goto Error

del %CurDir%\temp_maxrev_query.tmp

@echo Previous Updated Revision: %PrevRev%

svn list --username huyaohui --password 123457 --trust-server-cert-failures=unknown-ca -v -R -r %LastRev% > "%CurDir%\newlist.tmp"
if %errorlevel% NEQ 0 goto Error

sort "%CurDir%\newlist.tmp" > "%CurDir%\sortedlist.tmp"
del "%CurDir%\newlist.tmp"
if %errorlevel% NEQ 0 goto Error

set sqlExecuteFailed=0
set successFiles=
set failedFiles=
set /a sqlFileCount=0
setlocal enabledelayedexpansion
for /f "usebackq tokens=1,7 delims= " %%i in ("%CurDir%\sortedlist.tmp") do (
    if %%i GTR %PrevRev% (
        if "%%j" NEQ "" (
           if "%Env%" EQU "Prod" (
                for /f %%i in ('%~dp0AddFrontZero.bat !sqlFileCount!') do set SQLFileNum=%%i
                copy "%CurDir%\%%j" "%PublishFolder%\DBScripts\SQL_!SQLFileNum!_%%i_%%j"
                echo %PublishFolder%\DBScripts\SQL_!SQLFileNum!_%%i_%%j
                echo sqlcmd -b -S %CMDBServer% -U %CMDBUser% -P %CMDBPass% -d %CMDBName% -Q "INSERT INTO DBUpdateHistory(RevisionNumber,DBServer,DBName,UpdatedFileName,Success,UpdateTime) VALUES(%%i,'%DBServer%','%DBName%','%%j',1,getdate())" > %CMStatusUpdateBatch%
                echo if %%errorlevel%% NEQ 0 exit /b %%errorlevel%% >> %CMStatusUpdateBatch%
                set /a sqlFileCount+=1
            ) else (
                echo Starting update SQL file: %%i %%j
                sqlcmd -b -S %DBServer% -U %DBUser% -P "%DBPass%" -d %DBName% -i "%CurDir%\%%j"

                if !errorlevel! EQU 0 (
                    echo SQL file execute successfully: %%i %%j
                    echo Starting record execution status to database
                    sqlcmd -b -S %CMDBServer% -U %CMDBUser% -P %CMDBPass% -d %CMDBName% -Q "INSERT INTO DBUpdateHistory(RevisionNumber,DBServer,DBName,UpdatedFileName,Success,UpdateTime) VALUES(%%i,'%DBServer%','%DBName%','%%j',1,getdate())"
                    if "!successFiles!" NEQ "" (
                        set successFiles=!successFiles!,[%%i::%%j]
                    ) else (
                        set successFiles=[%%i::%%j]
                    )
                ) else (
                    set sqlExecuteFailed=1
                    echo SQL file execute failed: %%i %%j
                    sqlcmd -b -S %CMDBServer% -U %CMDBUser% -P %CMDBPass% -d %CMDBName% -Q "INSERT INTO DBUpdateHistory(RevisionNumber,DBServer,DBName,UpdatedFileName,Success,UpdateTime) VALUES(%%i,'%DBServer%','%DBName%','%%j',0,getdate())"
                    if "!failedFiles!" NEQ "" (
                        set failedFiles=!failedFiles!,[%%i::%%j]
                    ) else (
                        set failedFiles=[%%i::%%j]
                    )
                )
            )
        )
    )
)

del "%CurDir%\sortedlist.tmp"

echo ------------------------------------------------------------------------------

if "%Env%" EQU "Prod" (
    if %sqlFileCount% NEQ 0 (
        echo 共复制了[%sqlFileCount%]个SQL文件到发布目录: %PublishFolder% ，下次打包将不会包括这些SQL文件。
        echo DB Scripts Revision #:%LastRev% > %PublishFolder%\Readme.txt
    ) else (
        echo 没有数据库更新。
        echo No DB scripts need to be executed. > %PublishFolder%\Readme.txt
    )
) else (
    if "%successFiles%" EQU "" (
        if "%failedFiles%" EQU "" (
            echo 没有文件需要更新,没有,没有,没有,没有
        ) else (
            echo 数据库更新失败: %failedFiles%
            goto Error
        )
    ) else (
        if "%failedFiles%" EQU "" (
            echo 数据库更新成功,成功,成功,成功,成功
        ) else (
            echo 部分文件更新成功: %successFiles%
            echo 部分文件更新失败: %failedFiles%
            goto Error
        )
    )
)

echo ------------------------------------------------------------------------------

if %sqlExecuteFailed% NEQ 0 goto Error

:End
exit /b 0

:Error
echo An error has occurred
if %errorlevel% EQU 0 (
    exit /b 1
) else (
    exit /b %errorlevel%
)