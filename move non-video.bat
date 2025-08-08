@echo off
setlocal enabledelayedexpansion

:: ============================================================================
::  Recursive File Organizer
::  Moves all files that are not videos or subtitles into a "non-video" folder.
::  Place this .bat file in the root directory you want to organize.
:: ============================================================================

:: --- CONFIGURATION ---
:: Add or remove file extensions as needed.
:: Ensure there is a space between each extension.
set "VIDEO_EXTENSIONS=.mkv .mp4 .avi .mov .wmv .flv .webm .mpg .mpeg"
set "SUBTITLE_EXTENSIONS=.srt .sub .ass .ssa .vtt .idx"
set "DESTINATION_FOLDER_NAME=non-video"

:: --- SCRIPT LOGIC (Do not edit below this line) ---

:: Get the directory where this script is located.
set "ROOT_FOLDER=%~dp0"
set "DESTINATION_PATH=%ROOT_FOLDER%%DESTINATION_FOLDER_NAME%"

:: Create the destination folder if it doesn't already exist.
if not exist "%DESTINATION_PATH%" (
    echo Creating destination folder: %DESTINATION_FOLDER_NAME%
    mkdir "%DESTINATION_PATH%"
)

echo.
echo Starting file search in: %ROOT_FOLDER%
echo =================================================

:: Use a for /r loop to recursively go through all files (*.*) in the ROOT_FOLDER.
for /r "%ROOT_FOLDER%" %%F in (*.*) do (
    
    set "IS_MEDIA=false"
    set "CURRENT_FILE_PATH=%%F"
    set "CURRENT_FILE_EXT=%%~xF"
    set "CURRENT_FILE_DIR=%%~dpF"

    :: Check if the file has a video extension.
    for %%E in (%VIDEO_EXTENSIONS%) do (
        if /i "%%~xF"=="%%E" set "IS_MEDIA=true"
    )

    :: Check if the file has a subtitle extension.
    for %%E in (%SUBTITLE_EXTENSIONS%) do (
        if /i "%%~xF"=="%%E" set "IS_MEDIA=true"
    )

    :: We must ensure we are not trying to move files from the destination folder itself,
    :: or the script itself.
    if /i "!CURRENT_FILE_DIR!" neq "%DESTINATION_PATH%\" (
        if /i "!CURRENT_FILE_PATH!" neq "%~f0" (
            
            :: If the IS_MEDIA flag was never set to true, move the file.
            if !IS_MEDIA!==false (
                echo Moving "%%~nxF"
                move "%%F" "%DESTINATION_PATH%" >nul
            )
        )
    )
)

echo.
echo =================================================
echo Operation complete.
echo All non-video and non-subtitle files have been moved.
echo.
pause
