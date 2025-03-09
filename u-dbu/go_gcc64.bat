@echo off
cls

set ccdir=c:\gcc85\mingw64
set hbdir=c:\harbour
set include=%include%;%hbdir%\include;%ccdir%\include;
set lib=%lib%;%hbdir%\lib\win\mingw64;%ccdir%\lib;%ccdir%\x86_64-w64-mingw32\lib;
set path=%path%;path c:\windows\system32;c:\windows;%hbdir%;%hbdir%\bin;%ccdir%\bin;

@del app.exe

hbmk2 app.hbp -comp=mingw64

if not errorlevel 1 goto run

:error

pause

goto end

:run
cls

start app.exe

:end
