@echo off

set hbdir=c:\harbour
set include=%hbdir%\include
set lib=%hbdir%\lib
rem path c:\windows\system32;c:\windows;%hbdir%;%hbdir%\bin;%ccdir%\bin;

if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" call "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64

if exist app.exe del app.exe

c:\harbour\bin\hbmk2 app.hbp -comp=msvc64

if errorlevel 1 goto compileerror

rem  #del app.exp
rem #del app.lib

@cls
app.exe

goto exit

:compileerror

echo *** Error 

pause

:exit