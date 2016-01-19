@echo off

set Env=QA

:: -----Cn Site Parameters-----
set Round=1
set WebAppPool=5BVV-Web-QA
set AdminAppPool=5BVV-Admin-QA
set ApiHostSrv=WBVV.API.HOST-QA
set ApiCacheSrv=WBVV.API.Cache-QA

set DBServer=192.168.45.19
set DBName=WBVV_QA
set DBUser=wbvv-qa-update
set DBPass=wqu~@#$
set DBBackupPath=C:\Database\Backup
set CurDir=%~dp0DBSource

set CMStatusUpdateBatch=nul

set ApiRoot=C:\5BVV-Srv\ApiHost-QA
set WebRoot=C:\5BVV-Web\web-QA
set AdminRoot=C:\5BVV-Web\admin-QA

set ApiHostBindAddress=http://*:9900
set ApiHostServicePort=9988
set QiniuCallBackURL=wobo.ylhyh.onmypc.net:9900
set WebServerUrl=http://192.168.45.19/qa/web/
set MemcachedBindPort=22322
set ActiveLanguage=zh-CN
set ApiHostAddress=http://192.168.45.19:9900/api/

goto Execute

:: -----En Site Parameters-----
:EnSiteUpdate
set Round=2
set WebAppPool=5BVV-Web-QA-en
set AdminAppPool=5BVV-Admin-QA-en
set ApiHostSrv=WBVV.API.HOST-QA-En
set ApiCacheSrv=WBVV.API.Cache-QA-En

set DBName=WBVV_QA_EN

set ApiRoot=C:\5BVV-Srv\ApiHost-QA-en
set WebRoot=C:\5BVV-Web\web-QA-en
set AdminRoot=C:\5BVV-Web\admin-QA-en

set ApiHostBindAddress=http://*:9901
set ApiHostServicePort=9999
set QiniuCallBackURL=wobo.ylhyh.onmypc.net:9901
set WebServerUrl=http://192.168.45.19/qa/web-en/
set MemcachedBindPort=22323

set ActiveLanguage=en-US
set ApiHostAddress=http://192.168.45.19:9901/api/


:: -----Action Start-----
:Execute
echo Starting to stop all services...
call %~dp0..\StopAllServers.bat
if %errorlevel% NEQ 0 goto Error

echo Starting to update database...
echo Starting backup database: %DBName%
call %~dp0..\BackupDB.bat

cd %CurDir%
call %~dp0..\updatedb.bat
if %errorlevel% NEQ 0 goto Error

cd %~dp0CodeSource\
for /f "tokens=4 delims= " %%i in ('svn info ^| find "Last Changed Rev: "') do set CodeRevision=%%i
if %errorlevel% NEQ 0 goto Error
cd %~dp0

echo Starting to update Api Host...
del /F /Q %ApiRoot%\
rd /S /Q %ApiRoot%\Dict
xcopy %~dp0CodeSource\PrecompiledWeb\Host\*.* %ApiRoot%\ /E /H /R /Y /EXCLUDE:%~dp0..\Excludes.txt
if %errorlevel% NEQ 0 goto Error

echo Starting to update Web...
rd /S /Q %WebRoot%\
md %WebRoot%
xcopy %~dp0CodeSource\PrecompiledWeb\Web\*.* %WebRoot%\ /E /H /R /Y /EXCLUDE:%~dp0..\Excludes.txt
if %errorlevel% NEQ 0 goto Error

echo Starting to update Admin...
rd /S /Q %AdminRoot%\
md %AdminRoot%
xcopy %~dp0CodeSource\PrecompiledWeb\Admin\*.* %AdminRoot%\ /E /H /R /Y /EXCLUDE:%~dp0..\Excludes.txt
if %errorlevel% NEQ 0 goto Error

echo Starting to replace configuration variables...
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@ApiHostBindAddress@@ %ApiHostBindAddress%
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@ApiHostServicePort@@ %ApiHostServicePort%

call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateAccessKey@@ YQaa4CHMqBBGKGc9s5ZA-EvWQTKIMm9VcKgGqj0j
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateSecretKey@@ hFnnXNXe924ee7F3OqysnzlZEiZnsDVIc7kCLXTU
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateBucketName@@ qa-video
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivatePipelinePool@@ pipeline1;pipeline2;pipeline3;pipeline4
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateBucketDomain@@ 7xp08k.media1.z0.glb.clouddn.com

call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@QiniuPublicBucketName@@ qa-picture
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@QiniuPublicBucketDomain@@ 7xp08j.com2.z0.glb.qiniucdn.com

call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@QiniuCallBackURL@@ %QiniuCallBackURL%

call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@SMSBaseUri@@ http://223.255.31.37:8426/api/SMS/
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@WebServerUrl@@ %WebServerUrl%

call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@DBServer@@ %DBServer%
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@DBName@@ %DBName%
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@DBReadUser@@ wbvv-qa
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@DBWriteUser@@ wbvv-qa
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@DBReadPass@@ wbvv@qa.46598
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@DBWritePass@@ wbvv@qa.46598
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@MemcachedBindAddress@@ 127.0.0.1
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@MemcachedBindPort@@ %MemcachedBindPort%
call %~dp0..\ReplaceContent %ApiRoot%\HKSJ.WBVV.Api.Host.exe.config @@ActiveLanguage@@ %ActiveLanguage%
call %~dp0..\ReplaceContent %WebRoot%\web.config @@ApiHostAddress@@ %ApiHostAddress%
call %~dp0..\ReplaceContent %WebRoot%\web.config @@ActiveLanguage@@ %ActiveLanguage%
call %~dp0..\ReplaceContent %WebRoot%\web.config @@ValidationKey@@ AutoGenerate,IsolateApps
call %~dp0..\ReplaceContent %WebRoot%\web.config @@DecryptionKey@@ AutoGenerate,IsolateApps

call %~dp0..\ReplaceContent %WebRoot%\web.config @@QQAppId@@ 101274600
call %~dp0..\ReplaceContent %WebRoot%\web.config @@SinaAppKey@@ 40713838
call %~dp0..\ReplaceContent %WebRoot%\web.config @@QQCallBackPath@@ http://sso.5bvv.com/SSOCallBack/QQCallBack

call %~dp0..\ReplaceContent %AdminRoot%\web.config @@ApiHostAddress@@ %ApiHostAddress%
call %~dp0..\ReplaceContent %AdminRoot%\web.config @@ActiveLanguage@@ %ActiveLanguage%

if %errorlevel% NEQ 0 goto Error

echo Generating version information...
copy %~dp0..\versiontemplate.html %AdminRoot%\version.html
call %~dp0..\ReplaceContent %AdminRoot%\version.html @@CodeRevision@@ %CodeRevision%
call %~dp0..\ReplaceContent %AdminRoot%\version.html @@BuildDate@@ "%date% %time%"
if %errorlevel% NEQ 0 goto Error

:: copy /Y %~dp0..\Qiniu.4.0.dll %ApiRoot%\

echo Starting to start all services...
call %~dp0..\StartAllServers.bat
if %errorlevel% NEQ 0 goto Error

if %Round% EQU 1 goto EnSiteUpdate

exit /b 0
:Error
echo An error has occurred
exit /b %errorlevel%