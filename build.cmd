:<<"::is_bash"
@echo off
goto :is_windows
::is_bash
#
set -e #
cd -P -- "$(dirname -- "$0")" #
git submodule update --init --recursive #
( cd subninja && ./configure.py --bootstrap ) #
export PATH=$PWD/subninja:$PATH #
cd tools/gn #
exec bootstrap/bootstrap.py -s --no-clean #
echo "bootstrap/bootstrap.py: failure" #
exit 1 #

:is_windows
setlocal ENABLEEXTENSIONS

rem
rem Check for Visual Studio
if not "x%VSINSTALLDIR%" == "x" goto :vs_cmd_ok

echo VSINSTALLDIR not set. Please install Visual Studio (there is a no-charge
echo version) and run this command inside a "Command Prompt for Visual Studio"
echo window.
cmd /c exit 1
goto :eof

:vs_cmd_ok
rem only run vsdevcmd if DevEnvDir is not set
if not "x%DevEnvDir%" == "x" goto :check_for_git
call vsdevcmd -arch=x64
if errorlevel 1 goto :vsdevcmd_failed

:check_for_git
rem
rem Check for git
set startup_dir=%~dp0
set found_git=
for %%a in ("%PATH:;=";"%") do call :find_in_path "%%~a"

if not "x%found_git%" == "x" goto :found_git_ok
echo git not found in PATH. Please install Git:
echo.
echo https://git-scm.com
echo.
echo "git submodule update --init --recursive" failed: your build may fail.
goto :skip_found_git

:find_in_path
set str1="%1"
if not "x%str1:git\cmd=%" == "x%str1%" set found_git="%1"
goto :eof

:find_python3
if "x%1" == "x" goto :eof
if "x%keyname:Python\PythonCore\3=%" == "x%keyname%" goto :eof
set PythonDir=%1
goto :eof

:find_python
rem keys are parsed as %1
rem values underneath the current key are parsed as:
rem name="%1" type="%2" value="%3"
if not "x%2" == "x" goto :eof
set keyname=%1
rem Search for an "InstallPath" subkey
FOR /F "usebackq tokens=1-3" %%A IN (`REG QUERY %keyname%\InstallPath /ve 2^>nul`) DO call :find_python3 %%C
goto :eof

:vsdevcmd_failed
echo.
echo vsdevcmd failed. Please install Visual Studio (there is a no-charge
echo version) and run this command inside a "Command Prompt for Visual Studio"
echo window.
cmd /c exit 1
goto :eof

:ninja_build_failed
echo.
echo Failed to build subninja\ninja.exe
cmd /c exit 1
goto :eof

:gn_build_failed
echo.
echo Failed to build out_bootstrap\gn.exe
cmd /c exit 1
goto :eof

:found_git_ok
rem
rem git was found, clone submodules ("init submodules").
cd %startup_dir%
cmd /c git submodule update --init --recursive

:skip_found_git
rem
rem With or without git, the next step is to find python.
FOR /F "usebackq tokens=1-3" %%A IN (`REG QUERY HKLM\SOFTWARE\Python\PythonCore 2^>nul`) DO call :find_python %%A %%B %%C
FOR /F "usebackq tokens=1-3" %%A IN (`REG QUERY HKCU\SOFTWARE\Python\PythonCore 2^>nul`) DO call :find_python %%A %%B %%C
FOR /F "usebackq tokens=1-3" %%A IN (`REG QUERY HKLM\SOFTWARE\Wow6432Node\Python\PythonCore 2^>nul`) DO call :find_python %%A %%B %%C
if not "x%PythonDir%" == "x" goto :python_ok

echo Python3 not found. Please install Python3 for Windows:
echo.
echo https://python.org (version 3)
cmd /c exit 1
goto :eof

:python_ok
rem Use %PythonDir% to bootstrap subninja
cd %startup_dir%\subninja
if exist ninja.exe goto :skip_bootstrap
%PythonDir%\python.exe configure.py --bootstrap
if errorlevel 1 goto :ninja_build_failed
:skip_bootstrap
set PATH=%PATH%;%~dp0\subninja

cd ..\tools\gn
%PythonDir%\python.exe bootstrap\bootstrap.py -s --no-clean
if errorlevel 1 goto :gn_build_failed

cd %startup_dir%
