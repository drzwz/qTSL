@echo off
cls
echo.
rem %~dp0 Ϊ��ǰ�������ļ���·����
set qhome=%~dp0q\
rem  ���ݰ�װ·���޸ģ�
path D:\Tinysoft\Analyse.NET;%path%;

start "tsl2csbar1m"   %~dp0q\w32\q.exe tsl2csbar1m.q