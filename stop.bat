@echo off
REM Shutdown script for mstdn.ca maintenance page (Windows)

echo Stopping mstdn.ca maintenance page...
echo.

docker-compose down

if errorlevel 1 (
    echo Error: Failed to stop container.
    pause
    exit /b 1
)

echo.
echo Maintenance page has been stopped.
echo.
echo To start again, run:
echo   start.bat
echo.

pause
