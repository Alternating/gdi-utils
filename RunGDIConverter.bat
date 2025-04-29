@echo off
setlocal

REM Default paths
set SOURCE_PATH=M:\Games2\Dreamcast
set DEST_PATH=M:\Games
set GDI_UTILS_PATH=C:\Users\Alter-pc\Documents\gdi-utils\bin\bin-nodejs\index.js

echo Dreamcast GDI Image Batch Converter
echo ==================================
echo.

REM Get user input
set /p INPUT_SOURCE=Enter source path [%SOURCE_PATH%]: 
if not "%INPUT_SOURCE%"=="" set SOURCE_PATH=%INPUT_SOURCE%

set /p INPUT_DEST=Enter destination path [%DEST_PATH%]: 
if not "%INPUT_DEST%"=="" set DEST_PATH=%INPUT_DEST%

set /p INPUT_UTILS=Enter GDI-utils path [%GDI_UTILS_PATH%]: 
if not "%INPUT_UTILS%"=="" set GDI_UTILS_PATH=%INPUT_UTILS%

echo.
echo Starting conversion process...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0BulkGDIConverter.ps1" -SourcePath "%SOURCE_PATH%" -DestPath "%DEST_PATH%" -GdiUtilsPath "%GDI_UTILS_PATH%"

echo.
echo Conversion process finished.
pause