@echo off
cls
echo.
rem %~dp0 为当前批处理文件的路径。
set qhome=%~dp0q\
rem  根据安装路径修改：
path D:\Tinysoft\Analyse.NET;%path%;

start "tsl2csbar1m"   %~dp0q\w32\q.exe tsl2csbar1m.q