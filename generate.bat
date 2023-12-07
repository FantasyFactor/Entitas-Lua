@echo off
set FILE_GENERATOR="Generator/Generator.lua"
set DIR_COMPONENTS="Components"
set DIR_GENERATED="Generated"
set SCRIPT_ENTRY=""

setlocal enabledelayedexpansion

if exist %DIR_GENERATED% (
    rd /s /q %DIR_GENERATED%
)
mkdir %DIR_GENERATED%

for /r %DIR_COMPONENTS% %%f in (*.lua) do (
    set files=!files! %%~dpnf
)

lua %FILE_GENERATOR% %DIR_COMPONENTS% %DIR_GENERATED% %SCRIPT_ENTRY% !files:~1!
pause