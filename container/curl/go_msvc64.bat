@echo off

if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" call "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64

if exist app.exe del app.exe


\harbour\bin\hbmk2 app_msvc64.hbp -comp=msvc64


if errorlevel 1 goto compileerror

@cls
app.exe

goto exit

:compileerror

echo *** Error 

pause

:exit