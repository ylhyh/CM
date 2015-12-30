@echo off

set Env=Prod

echo Starting to update database...
set DBServer=54.254.195.25
set DBName=WBVV_PROD
REM set DBUser=
REM set DBPass=
set CurDir=%~dp0DBSource

set TargetSubFolder=%date:~0,4%.%date:~5,2%.%date:~8,2%_%time:~0,2%.%time:~3,2%.%time:~6,2%.%time:~9,2%
set PublishFolder=%~dp0ReleaseHistory\%TargetSubFolder%
if exist %PublishFolder% (
    rd /S /Q %PublishFolder%
) else (
    md %PublishFolder%\DBScripts
    md %PublishFolder%\WebAndHost
)

set CMStatusUpdateBatch=%tmp%\DBUpdate_%random%.bat

cd %CurDir%
call %~dp0..\updatedb.bat
if %errorlevel% NEQ 0 goto Error

cd %~dp0CodeSource\
for /f "tokens=4 delims= " %%i in ('svn info ^| find "Last Changed Rev: "') do set CodeRevision=%%i
if %errorlevel% NEQ 0 goto Error
echo Code Revision #:%CodeRevision% >> %PublishFolder%\Readme.txt
cd %~dp0

echo Starting copy Api Host...
xcopy %~dp0CodeSource\PrecompiledWeb\Host\*.* %PublishFolder%\WebAndHost\Host\ /E /H /R /Y /EXCLUDE:%~dp0..\Excludes.txt
if %errorlevel% NEQ 0 goto Error

echo Starting copy Web...
xcopy %~dp0CodeSource\PrecompiledWeb\Web\*.* %PublishFolder%\WebAndHost\Web\ /E /H /R /Y /EXCLUDE:%~dp0..\Excludes.txt
if %errorlevel% NEQ 0 goto Error

echo Starting copy Admin...
xcopy %~dp0CodeSource\PrecompiledWeb\Admin\*.* %PublishFolder%\WebAndHost\Admin\ /E /H /R /Y /EXCLUDE:%~dp0..\Excludes.txt
if %errorlevel% NEQ 0 goto Error

echo Starting to replace configuration variables...
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@ApiHostBindAddress@@ http://api.5bvv.com

call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateAccessKey@@ 6ExYuSphTVpOCqshCbe8sQYL1u2XANzaLg1x-7Ms
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateSecretKey@@ 4fGRfdMYfg06E4-2NWuTGrsz-4EanL4YzB_K2_GW
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateBucketName@@ wobo-video
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivatePipelinePool@@ pipeline1;pipeline2;pipeline3;pipeline4
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@QiniuPrivateBucketDomain@@ 7xo7ls.media1.z0.glb.clouddn.com

call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@QiniuPublicBucketName@@ wobo-picture
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@QiniuPublicBucketDomain@@ 7xo7lz.com2.z0.glb.qiniucdn.com

call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@QiniuCallBackURL@@ api.5bvv.com

call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@SMSBaseUri@@ http://112.124.108.231:10000/api/SMS/
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@WebServerUrl@@ http://www.5bvv.com/

call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@DBServer@@ localhost
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@DBName@@ WBVV_PROD
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@DBReadUser@@ wbvv_prod
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@DBWriteUser@@ wbvv_prod
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@DBReadPass@@ (wobo@xixiang)
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@DBWritePass@@ (wobo@xixiang)
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@MemcachedBindAddress@@ 127.0.0.1
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config @@MemcachedBindPort@@ 33433
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\web\web.config @@ApiHostAddress@@ http://api.5bvv.com/api/
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\web\web.config @@ValidationKey@@ 2BA1DC068A862AF87AD4DEEB29C5CEA934D97F1B590703ED9C8BA14E2E86C6FACA06404F50FD2B09480532E4D64955B9521D1016AD94B8863B89E1CFD009D29A
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\web\web.config @@DecryptionKey@@ 26A11EC1577C2E0AFD22E807645A0C2F2D40DB23C6823E6A
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\web\web.config @@QQAppId@@ 101274019
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\web\web.config @@SinaAppKey@@ 2117316641
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\web\web.config @@QQCallBackPath@@ http://www.5bvv.com/SSOCallBack/QQCallBack
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\admin\web.config @@ApiHostAddress@@ http://api.5bvv.com/api/
if %errorlevel% NEQ 0 goto Error

echo Generating version information...
copy %~dp0..\versiontemplate.html %PublishFolder%\WebAndHost\admin\version.html
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\admin\version.html @@CodeRevision@@ %CodeRevision%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\admin\version.html @@BuildDate@@ "%date% %time%"
if %errorlevel% NEQ 0 goto Error

copy /Y %~dp0..\Qiniu.4.0.dll %PublishFolder%\WebAndHost\Host\

echo Copy auto update scripts to publish folder...
copy %~dp0Update.txt %PublishFolder%\Update.bat
if %errorlevel% NEQ 0 goto Error

echo Starting to zip the package...
"C:\Program Files\7-Zip\7z.exe" a -tzip %~dp0ReleaseHistory\%TargetSubFolder%.zip "%PublishFolder%\*"
if %errorlevel% NEQ 0 goto Error
rd /S /Q %PublishFolder%
if %errorlevel% NEQ 0 goto Error

REM if there is no error, will record DB Update History to CM DB.
if exist %CMStatusUpdateBatch% (
    echo Starting record DB status to database
    call %CMStatusUpdateBatch%
    if %errorlevel% NEQ 0 goto Error
    del %CMStatusUpdateBatch%
)

exit /b 0
:Error
echo An error has occurred
exit /b %errorlevel%