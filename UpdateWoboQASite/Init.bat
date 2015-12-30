@echo off

set Env=QA

echo Starting to stop all services...
set WebAppPool=5BVV-Web-QA
set AdminAppPool=5BVV-Admin-QA
set ApiHostSrv=WBVV.API.HOST-QA
set ApiCacheSrv=WBVV.API.Cache-QA

call %~dp0..\StopAllServers.bat
if %errorlevel% NEQ 0 goto Error

echo Starting to update database...
set DBServer=192.168.45.19
set DBName=WBVV_QA
set DBUser=wbvv-qa-update
set DBPass=wqu~@#$
set DBBackupPath=C:\Database\Backup
set CurDir=%~dp0DBSource

set CMStatusUpdateBatch=nul

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
del /F /Q C:\5BVV-Srv\ApiHost-QA\
rd /S /Q C:\5BVV-Srv\ApiHost-QA\Dict
xcopy %~dp0CodeSource\PrecompiledWeb\Host\*.* C:\5BVV-Srv\ApiHost-QA\ /E /H /R /Y /EXCLUDE:%~dp0..\Excludes.txt
if %errorlevel% NEQ 0 goto Error

echo Starting to update Web...
rd /S /Q C:\5BVV-Web\web-QA\
md C:\5BVV-Web\web-QA
xcopy %~dp0CodeSource\PrecompiledWeb\Web\*.* C:\5BVV-Web\web-QA\ /E /H /R /Y /EXCLUDE:%~dp0..\Excludes.txt
if %errorlevel% NEQ 0 goto Error

echo Starting to update Admin...
rd /S /Q C:\5BVV-Web\admin-QA\
md C:\5BVV-Web\admin-QA
xcopy %~dp0CodeSource\PrecompiledWeb\Admin\*.* C:\5BVV-Web\admin-QA\ /E /H /R /Y /EXCLUDE:%~dp0..\Excludes.txt
if %errorlevel% NEQ 0 goto Error

echo Starting to replace configuration variables...
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@ApiHostBindAddress@@ http://*:9900
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@ApiHostServicePort@@ 9999

call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateAccessKey@@ 5XpBDEz38TW5Bpe8ntpNIYnvdrLLEp3_AR5c645V
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateSecretKey@@ TohP7pWKs6Acou3UKRLZTFBZv4k4xHEhcqSiLAXQ
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateBucketName@@ qa-private
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivatePipelinePool@@ pipeline1;pipeline2;pipeline3;pipeline4
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateBucketDomain@@ 7xnjmm.media1.z0.glb.clouddn.com

call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@QiniuPublicBucketName@@ qa-public
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@QiniuPublicBucketDomain@@ 7xnjmk.com1.z0.glb.clouddn.com

call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@QiniuCallBackURL@@ wobo.ylhyh.onmypc.net:9900

call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@SMSBaseUri@@ http://223.255.31.37:8426/api/SMS/
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@WebServerUrl@@ http://192.168.45.19/qa/web/

call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@DBServer@@ %DBServer%
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@DBName@@ %DBName%
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@DBReadUser@@ wbvv-qa
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@DBWriteUser@@ wbvv-qa
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@DBReadPass@@ wbvv@qa.46598
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@DBWritePass@@ wbvv@qa.46598
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@MemcachedBindAddress@@ 127.0.0.1
call %~dp0..\ReplaceContent C:\5BVV-Srv\ApiHost-QA\HKSJ.WBVV.Api.Host.exe.config @@MemcachedBindPort@@ 22322
call %~dp0..\ReplaceContent C:\5BVV-Web\web-QA\web.config @@ApiHostAddress@@ http://192.168.45.19:9900/api/
call %~dp0..\ReplaceContent C:\5BVV-Web\web-QA\web.config @@ValidationKey@@ AutoGenerate,IsolateApps
call %~dp0..\ReplaceContent C:\5BVV-Web\web-QA\web.config @@DecryptionKey@@ AutoGenerate,IsolateApps

call %~dp0..\ReplaceContent C:\5BVV-Web\web-QA\web.config @@QQAppId@@ 101274600
call %~dp0..\ReplaceContent C:\5BVV-Web\web-QA\web.config @@SinaAppKey@@ 40713838
call %~dp0..\ReplaceContent C:\5BVV-Web\web-QA\web.config @@QQCallBackPath@@ http://sso.5bvv.com/SSOCallBack/QQCallBack

call %~dp0..\ReplaceContent C:\5BVV-Web\admin-QA\web.config @@ApiHostAddress@@ http://192.168.45.19:9900/api/
if %errorlevel% NEQ 0 goto Error

echo Generating version information...
copy %~dp0..\versiontemplate.html C:\5BVV-Web\admin-QA\version.html
call %~dp0..\ReplaceContent C:\5BVV-Web\admin-QA\version.html @@CodeRevision@@ %CodeRevision%
call %~dp0..\ReplaceContent C:\5BVV-Web\admin-QA\version.html @@BuildDate@@ "%date% %time%"
if %errorlevel% NEQ 0 goto Error

copy /Y %~dp0..\Qiniu.4.0.dll C:\5BVV-Srv\ApiHost-QA\

echo Starting to start all services...
call %~dp0..\StartAllServers.bat
if %errorlevel% NEQ 0 goto Error

exit /b 0
:Error
echo An error has occurred
exit /b %errorlevel%