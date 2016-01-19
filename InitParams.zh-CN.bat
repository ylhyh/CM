@echo off

echo Starting to init parameters...

:: Deploy folders:
set ApiDeployPath=D:\5bvv\host
set AdminDeployPath=D:\5bvv\admin
set WebDeployPath=D:\5bvv\web

:: App Pool name and Service name:
set WebAppPool=www.5bvv.cn
set AdminAppPool=admin.5bvv.cn
set ApiHostSrv=WBVV.API.Host
set ApiCacheSrv=WBVV.API.Cache

:: DB parameters:
set DBServer=localhost
set DBName=WBVV_PROD
set DBUser=sa
set DBPass=wb+-*/$#@1
set DBBackupPath=D:\Database\MSSQL11.MSSQLSERVER\MSSQL\Backup

set ActiveLanguage=zh-CN