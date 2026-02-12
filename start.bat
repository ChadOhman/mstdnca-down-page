@echo off
REM Startup script for mstdn.ca maintenance page (Windows)

echo Starting mstdn.ca maintenance page...
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo Error: Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

REM Build and start the container
echo Building Docker image...
docker-compose build
if errorlevel 1 (
    echo Error: Failed to build Docker image.
    pause
    exit /b 1
)

echo Starting container...
docker-compose up -d
if errorlevel 1 (
    echo Error: Failed to start container.
    pause
    exit /b 1
)

REM Wait a moment for container to start
timeout /t 3 /nobreak >nul

echo.
echo Maintenance page is now running!
echo.
echo Access the page at:
echo   http://localhost:8080
echo.
echo View logs:
echo   docker-compose logs -f
echo.
echo Stop the page:
echo   stop.bat
echo   or
echo   docker-compose down
echo.

pause
