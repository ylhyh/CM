@echo off

set Env=Prod

set TargetSubFolder=%date:~0,4%.%date:~5,2%.%date:~8,2%_%time:~0,2%.%time:~3,2%.%time:~6,2%.%time:~9,2%
set PublishFolder=%~dp0ReleaseHistory\%TargetSubFolder%
if exist %PublishFolder% (
    rd /S /Q %PublishFolder%
) else (
    md %PublishFolder%\DBScripts\
    md %PublishFolder%\WebAndHost
)

:: -----Cn Site Parameters-----
echo Packing CN site...
set Round=1
set ActiveLanguage=zh-CN

set DBServer=54.254.195.25
set DBName=WBVV_PROD
:: set DBUser=
:: set DBPass=
set CurDir=%~dp0DBSource

set ApiHostBindAddress=http://api.5bvv.cn
set QiniuPrivateBucketName=wobo-video
set QiniuPrivateBucketDomain=7xo7ls.media1.z0.glb.clouddn.com
set QiniuPublicBucketName=wobo-picture
set QiniuPublicBucketDomain=7xo7lz.com2.z0.glb.qiniucdn.com
set QiniuCallBackURL=api.5bvv.cn
set WebServerUrl=http://www.5bvv.cn/
set DBConnectUser=wbvv_prod
set DBConnectPass=(wobo@xixiang)
set MemcachedBindPort=33433
set ApiHostAddress=http://api.5bvv.cn/api/
set WebValidationKey=2BA1DC068A862AF87AD4DEEB29C5CEA934D97F1B590703ED9C8BA14E2E86C6FACA06404F50FD2B09480532E4D64955B9521D1016AD94B8863B89E1CFD009D29A
set WebDecryptionKey=26A11EC1577C2E0AFD22E807645A0C2F2D40DB23C6823E6A
set QQAppId=101274019
set SinaAppKey=1792654996
set QQCallBackPath=http://www.5bvv.cn/SSOCallBack/QQCallBack

goto Execute

:: -----En Site Parameters-----
:EnSiteUpdate
echo Packing EN site...
set Round=2
set ActiveLanguage=en-US

set DBName=WBVV_PROD_EN

set ApiHostBindAddress=http://api.5bvv.com
set QiniuPrivateBucketName=wobo-video-en
set QiniuPrivateBucketDomain=7xq563.media1.z0.glb.clouddn.com
set QiniuPublicBucketName=wobo-picture-en
set QiniuPublicBucketDomain=7xq560.com2.z0.glb.qiniucdn.com
set QiniuCallBackURL=api.5bvv.com
set WebServerUrl=http://www.5bvv.com/
set DBConnectUser=wbvv_prod_en
set DBConnectPass=(wobo@zhigu)
set MemcachedBindPort=33434
set ApiHostAddress=http://api.5bvv.com/api/
set WebValidationKey=4F538EE7064FF40EC2C6ED96F390CA380AC3FCAE99D14DD25E4FEAF25D2C76DEACF4636FC5ED61F520DA6F30504D276C94A147CB825386855C1F14580045B215
set WebDecryptionKey=B446DC8667A477E30CBCBF047129E64EB4856854DF3593E7
set QQAppId=101288950
set SinaAppKey=
set QQCallBackPath=http://www.5bvv.com/SSOCallBack/QQCallBack

:: -----Action Start-----
:Execute
set CMStatusUpdateBatch=%tmp%\DBUpdate_%random%.bat

echo Starting to collect database update scripts...
md %PublishFolder%\DBScripts\%ActiveLanguage%
cd %CurDir%
call %~dp0..\updatedb.bat
if %errorlevel% NEQ 0 goto Error

if %Round% EQU 1 (
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
)
echo Starting to replace configuration variables...
copy %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.config %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@ApiHostBindAddress@@ %ApiHostBindAddress%

call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@QiniuPrivateAccessKey@@ YQaa4CHMqBBGKGc9s5ZA-EvWQTKIMm9VcKgGqj0j
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@QiniuPrivateSecretKey@@ hFnnXNXe924ee7F3OqysnzlZEiZnsDVIc7kCLXTU
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@QiniuPrivateBucketName@@ %QiniuPrivateBucketName%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@QiniuPrivatePipelinePool@@ pipeline1;pipeline2;pipeline3;pipeline4
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@QiniuPrivateBucketDomain@@ %QiniuPrivateBucketDomain%

call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@QiniuPublicBucketName@@ %QiniuPublicBucketName%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@QiniuPublicBucketDomain@@ %QiniuPublicBucketDomain%

call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@QiniuCallBackURL@@ %QiniuCallBackURL%

call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@SMSBaseUri@@ http://112.124.108.231:10000/api/SMS/
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@WebServerUrl@@ %WebServerUrl%

call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@DBServer@@ localhost
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@DBName@@ %DBName%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@DBReadUser@@ %DBConnectUser%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@DBWriteUser@@ %DBConnectUser%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@DBReadPass@@ %DBConnectPass%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@DBWritePass@@ %DBConnectPass%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@MemcachedBindAddress@@ 127.0.0.1
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@MemcachedBindPort@@ %MemcachedBindPort%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\Host\HKSJ.WBVV.Api.Host.exe.%ActiveLanguage%.config @@ActiveLanguage@@ %ActiveLanguage%

copy %PublishFolder%\WebAndHost\web\web.config %PublishFolder%\WebAndHost\web\web.%ActiveLanguage%.config
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\web\web.%ActiveLanguage%.config @@ApiHostAddress@@ %ApiHostAddress%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\web\web.%ActiveLanguage%.config @@ActiveLanguage@@ %ActiveLanguage%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\web\web.%ActiveLanguage%.config @@ValidationKey@@ %WebValidationKey%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\web\web.%ActiveLanguage%.config @@DecryptionKey@@ %WebDecryptionKey%

call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\web\web.%ActiveLanguage%.config @@QQAppId@@ %QQAppId%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\web\web.%ActiveLanguage%.config @@SinaAppKey@@ %SinaAppKey%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\web\web.%ActiveLanguage%.config @@QQCallBackPath@@ %QQCallBackPath%

copy %PublishFolder%\WebAndHost\admin\web.config %PublishFolder%\WebAndHost\admin\web.%ActiveLanguage%.config
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\admin\web.%ActiveLanguage%.config @@ApiHostAddress@@ %ApiHostAddress%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\admin\web.%ActiveLanguage%.config @@ActiveLanguage@@ %ActiveLanguage%
if %errorlevel% NEQ 0 goto Error

echo Generating version information...
copy %~dp0..\versiontemplate.html %PublishFolder%\WebAndHost\admin\version.html
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\admin\version.html @@CodeRevision@@ %CodeRevision%
call %~dp0..\ReplaceContent %PublishFolder%\WebAndHost\admin\version.html @@BuildDate@@ "%date% %time%"
if %errorlevel% NEQ 0 goto Error

:: copy /Y %~dp0..\Qiniu.4.0.dll %PublishFolder%\WebAndHost\Host\

echo Copy auto update scripts to publish folder...
echo call %%~dp0..\InitParams.%ActiveLanguage%.bat > %~dp0Update2.txt

copy %~dp0Update1.txt /b + %~dp0Update2.txt /b + %~dp0Update3.txt /b %PublishFolder%\Update.%ActiveLanguage%.bat
if %errorlevel% NEQ 0 goto Error

:: if there is no error, will record DB Update History to CM DB.
if exist %CMStatusUpdateBatch% (
    echo Starting record DB status to database
    call %CMStatusUpdateBatch%
    if %errorlevel% NEQ 0 goto Error
    del %CMStatusUpdateBatch%
)

if %Round% EQU 1 goto EnSiteUpdate

echo Starting to zip the package...
"C:\Program Files\7-Zip\7z.exe" a -tzip %~dp0ReleaseHistory\%TargetSubFolder%.zip "%PublishFolder%\*"
if %errorlevel% NEQ 0 goto Error
 rd /S /Q %PublishFolder%
if %errorlevel% NEQ 0 goto Error

exit /b 0
:Error
echo An error has occurred
exit /b %errorlevel%