@echo off

echo Starting to init parameters...

:: Deploy folders:
set ApiDeployPath=D:\5bvv\host-en
set AdminDeployPath=D:\5bvv\admin-en
set WebDeployPath=D:\5bvv\web-en

:: App Pool name and Service name:
set WebAppPool=www.5bvv.com
set AdminAppPool=admin.5bvv.com
set ApiHostSrv=WBVV.API.Host-En
set ApiCacheSrv=WBVV.API.Cache-En

:: DB parameters:
set DBServer=localhost
set DBName=WBVV_PROD_EN
set DBUser=sa
set DBPass=wb+-*/$#@1
set DBBackupPath=D:\Database\MSSQL11.MSSQLSERVER\MSSQL\Backup

set ActiveLanguage=en-US