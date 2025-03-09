@echo off

if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" call "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64

if exist app.exe del app.exe

set hbdir=c:\harbour
set include=%include%;%hbdir%\include
set lib=%lib%;%hbdir%\lib
set path=%path%;path c:\windows\system32;c:\windows;%hbdir%;%hbdir%\bin

hbmk2 app_msvc64.hbp -comp=msvc64

IF ERRORLEVEL 1 GOTO COMPILEERROR

del app.exp
del app.lib

@cls
app.exe

GOTO EXIT

:COMPILEERROR

echo *** Error 

pause

:EXIT