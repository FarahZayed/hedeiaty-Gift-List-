@echo off

REM Step 1: Start video recording in the background
echo Starting video recording...
start /b adb shell screenrecord /sdcard/testcase01_video.mp4
if %errorlevel% neq 0 (
    echo "Failed to start screen recording. Ensure adb is in your PATH and your emulator/device is connected."
    exit /b
)

REM Step 2: Run Flutter tests concurrently
echo Running Flutter tests...
start /b flutter test integration_tests/testcase01.dart
if %errorlevel% neq 0 (
    echo "Failed to start Flutter tests."
    exit /b
)

REM Step 3: Wait for tests to finish
echo Waiting for tests to complete...
timeout /t 150 >nul

REM Step 4: Stop video recording
echo Stopping video recording...
adb shell pkill -SIGINT screenrecord
if %errorlevel% neq 0 (
    echo "Failed to stop screen recording."
)

REM Step 5: Retrieve the recorded video
echo Retrieving recorded video...
adb pull /sdcard/testcase01_video.mp4 ./testcase01_video.mp4
if %errorlevel% neq 0 (
    echo "Failed to retrieve the recorded video."
    exit /b
)

echo Integration test completed and video saved as testcase01_video.mp4
pause
