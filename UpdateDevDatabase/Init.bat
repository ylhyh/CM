@echo off

set Env=Dev

set DBServer=192.168.45.19
set DBName=WBVV
set DBUser=wbvv-dev-update
set DBPass=wdu^&^*^(^)
set DBBackupPath=C:\Database\Backup

set CMStatusUpdateBatch=nul

set CurDir=%~dp0DBSource
cd %CurDir%
call %~dp0..\updatedb.bat