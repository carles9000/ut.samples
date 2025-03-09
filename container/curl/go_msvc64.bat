@echo off

if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" call "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64

if exist app.exe del app.exe


set hbdir=c:\harbour
set include=%include%;%hbdir%\include
set lib=%lib%;%hbdir%\lib\win\msvc64
set path=%path%;path c:\windows\system32;c:\windows;%hbdir%;%hbdir%\bin


hbmk2 app_msvc64.hbp -comp=msvc64

if exist app.exp del app.exp
if exist app.lib del app.lib

if errorlevel 1 goto compileerror

@cls
app.exe

goto exit

:compileerror

echo *** Error 

pause

:exit