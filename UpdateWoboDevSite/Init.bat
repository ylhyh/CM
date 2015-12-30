@echo off

set Env=Dev

echo Starting to stop all services...
set WebAppPool=5BVV-Web
set AdminAppPool=5BVV-Admin
set ApiHostSrv=WBVV.API.HOST
set ApiCacheSrv=WBVV.API.Cache

call %~dp0..\StopAllServers.bat
if %errorlevel% NEQ 0 goto Error

echo Starting to update database...
set DBServer=192.168.45.19
set DBName=WBVV
set DBUser=wbvv-dev-update
set DBPass=wdu^&^*^(^)
set DBBackupPath=C:\Database\Backup
set CurDir=%~dp0DBSource

set CMStatusUpdateBatch=nul

cd %CurDir%
call %~dp0..\updatedb.bat
if %errorlevel% NEQ 0 goto Error

cd %~dp0CodeSource\
for /f "tokens=4 delims= " %%i in ('svn info ^| find "Last Changed Rev: "') do set CodeRevision=%%i
if %errorlevel% NEQ 0 goto Error
cd %~dp0

echo Starting to update Api Host...
del /F /Q C:\5BVV-Srv\ApiHost\
rd /S /Q C:\5BVV-Srv\ApiHost\Dict
xcopy %~dp0CodeSource\PrecompiledWeb\Host\*.* C:\5BVV-Srv\ApiHost\ /E /H /R /Y /EXCLUDE:%~dp0..\Excludes.txt
if %errorlevel% NEQ 0 goto Error

echo Starting to update Web...
rd /S /Q C:\5BVV-Web\web\
md C:\5BVV-Web\web
xcopy %~dp0CodeSource\PrecompiledWeb\Web\*.* C:\5BVV-Web\web\ /E /H /R /Y /EXCLUDE:%~dp0..\Excludes.txt
if %errorlevel% NEQ 0 goto Error

echo Starting to update Admin...
rd /S /Q C:\5BVV-Web\admin\
md C:\5BVV-Web\admin
xcopy %~dp0CodeSource\PrecompiledWeb\Admin\*.* C:\5BVV-Web\admin\ /E /H /R /Y /EXCLUDE:%~dp0..\Excludes.txt
if %errorlevel% NEQ 0 goto Error

echo Starting to replace configuration variables...
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@ApiHostBindAddress@@ http://*:8800
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@ApiHostServicePort@@ 8899

call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateAccessKey@@ dpuZPEw9sBCTlVaWq1h99lha5bMOazRAbW0hGog8
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateSecretKey@@ 2C58Mr8F5kbjEKPBUdlqzljW4ioaSlUK0S3x3tQi
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateBucketName@@ uploadfile
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivatePipelinePool@@ pipeline1;pipeline2;pipeline3;pipeline4
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateBucketDomain@@ 7xlxsl.com1.z0.glb.clouddn.com

call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@QiniuPublicBucketName@@ publicbucket
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@QiniuPublicBucketDomain@@ 7xnmhm.com1.z0.glb.clouddn.com

call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@QiniuCallBackURL@@ wobo.ylhyh.onmypc.net:8800

call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@SMSBaseUri@@ http://223.255.31.37:8426/api/SMS/
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@WebServerUrl@@ http://192.168.45.19/web/

call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@DBServer@@ %DBServer%
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@DBName@@ %DBName%
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@DBReadUser@@ wbvv-dev
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@DBWriteUser@@ wbvv-dev
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@DBReadPass@@ wbvv@1013
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@DBWritePass@@ wbvv@1013
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@MemcachedBindAddress@@ 127.0.0.1
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost\HKSJ.WBVV.Api.Host.exe.config @@MemcachedBindPort@@ 11211
call %~dp0..\ReplaceContent C:\5BVV-Web\web\web.config @@ApiHostAddress@@ http://192.168.45.19:8800/api/
call %~dp0..\ReplaceContent C:\5BVV-Web\web\web.config @@ValidationKey@@ AutoGenerate,IsolateApps
call %~dp0..\ReplaceContent C:\5BVV-Web\web\web.config @@DecryptionKey@@ AutoGenerate,IsolateApps
call %~dp0..\ReplaceContent C:\5BVV-Web\admin\web.config @@ApiHostAddress@@ http://192.168.45.19:8800/api/
if %errorlevel% NEQ 0 goto Error

echo Generating version information...
copy %~dp0..\versiontemplate.html C:\5BVV-Web\admin\version.html
call %~dp0..\ReplaceContent C:\5BVV-Web\admin\version.html @@CodeRevision@@ %CodeRevision%
call %~dp0..\ReplaceContent C:\5BVV-Web\admin\version.html @@BuildDate@@ "%date% %time%"
if %errorlevel% NEQ 0 goto Error

copy /Y %~dp0..\Qiniu.4.0.dll C:\5BVV-Srv\ApiHost\

echo Starting to start all services...
call %~dp0..\StartAllServers.bat
if %errorlevel% NEQ 0 goto Error

exit /b 0
:Error
echo An error has occurred
exit /b %errorlevel%