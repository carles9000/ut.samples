@echo off
cls


set ccdir=c:\gcc85\mingw64
set hbdir=c:\harbour
set include=%include%;%hbdir%\include;%ccdir%\include;
set lib=%lib%;%hbdir%\lib\win\mingw64;%ccdir%\lib;%ccdir%\x86_64-w64-mingw32\lib
set path=%path%;c:\windows\system32;c:\windows;%hbdir%;%hbdir%\bin;%ccdir%\bin

@del app.exe

hbmk2 app_gcc64.hbp -comp=mingw64

if errorlevel 1 goto compileerror

@cls
app.exe

goto exit

:compileerror

echo *** Error 

pause

:exit