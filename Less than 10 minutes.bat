@echo off
setlocal enabledelayedexpansion

:: ============================================================================
::  Short Video Finder
::  Finds videos shorter than a specified duration and moves them.
::
::  ** IMPORTANT REQUIREMENT **
::  This script requires FFmpeg. Please download it from https://ffmpeg.org
::  and place the "ffprobe.exe" file (from the 'bin' folder of the download)
::  in the same directory as this batch script.
:: ============================================================================

:: --- CONFIGURATION ---
:: A list of video file extensions to look for.
set "VIDEO_EXTENSIONS=*.mkv *.mp4 *.avi *.mov *.wmv *.flv .webm *.mpg *.mpeg"

:: The name of the folder where short videos will be moved.
set "DESTINATION_FOLDER_NAME=Short Videos"

:: A folder to ignore during the scan.
set "EXCLUDE_FOLDER=non-video"

:: The maximum duration in seconds. 10 minutes = 600 seconds.
set "MAX_DURATION_SECONDS=600"


:: --- SCRIPT LOGIC (Do not edit below this line) ---

:: Get the directory where this script is located.
set "ROOT_FOLDER=%~dp0"
set "DESTINATION_PATH=%ROOT_FOLDER%%DESTINATION_FOLDER_NAME%"

:: Check if ffprobe.exe exists in the script's directory.
if not exist "%~dp0ffprobe.exe" (
    echo [ERROR] ffprobe.exe not found in this script's directory.
    echo.
    echo Please download FFmpeg from https://ffmpeg.org/download.html
    echo Unzip the download, go into the 'bin' folder, and copy 'ffprobe.exe'
    echo into the same folder where this script is located.
    echo.
    pause
    exit /b
)

:: Create the destination folder if it doesn't already exist.
if not exist "%DESTINATION_PATH%" (
    echo Creating destination folder: %DESTINATION_FOLDER_NAME%
    mkdir "%DESTINATION_PATH%"
)

echo.
echo Starting scan for short videos...
echo =================================================

:: Loop through all subdirectories of the root folder.
for /d %%D in ("%ROOT_FOLDER%*") do (
    set "CURRENT_FOLDER_NAME=%%~nxD"

    :: Check if the current folder is one we should skip.
    if /i "!CURRENT_FOLDER_NAME!" neq "%DESTINATION_FOLDER_NAME%" (
        if /i "!CURRENT_FOLDER_NAME!" neq "%EXCLUDE_FOLDER%" (
            
            echo.
            echo --- Checking folder: "!CURRENT_FOLDER_NAME!" ---
            
            :: Loop through all specified video file types in the current subdirectory.
            for %%E in (%VIDEO_EXTENSIONS%) do (
                for %%F in ("%%D\%%E") do (
                    if exist "%%F" (
                        
                        echo   Analyzing "%%~nxF"...
                        
                        :: Use ffprobe to get the video's duration in seconds.
                        :: The output is captured by the for /f loop.
                        for /f "delims=" %%I in ('"%~dp0ffprobe.exe" -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "%%F"') do (
                            set "DURATION_FLOAT=%%I"
                        )
                        
                        :: Batch can't compare numbers with decimals. We need to get the integer part.
                        for /f "delims=." %%J in ("!DURATION_FLOAT!") do (
                            set "DURATION_INT=%%J"
                        )
                        
                        :: Check if the duration is less than our maximum.
                        if defined DURATION_INT (
                            if !DURATION_INT! LSS %MAX_DURATION_SECONDS% (
                                echo     -> Duration is !DURATION_INT!s. Moving to '%DESTINATION_FOLDER_NAME%'.
                                move "%%F" "%DESTINATION_PATH%" >nul
                            )
                        )
                    )
                )
            )
        )
    )
)

echo.
echo =================================================
echo Operation complete.
echo.
pause
