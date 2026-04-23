@echo off
REM Quick Start Script for Academia Link Desktop App (Windows)
REM Run this script to start both backend and desktop app

cd /d "%~dp0"

echo ==========================================
echo   Academia Link Desktop App Launcher
echo ==========================================
echo.

REM Check and install root dependencies
if not exist "node_modules" (
    echo [1/4] Installing backend dependencies...
    echo This may take 2-3 minutes on first run...
    call npm install
    if errorlevel 1 (
        echo ERROR: Failed to install backend dependencies
        pause
        exit /b 1
    )
    echo [OK] Backend dependencies installed
) else (
    echo [1/4] Backend dependencies already installed
)

REM Check and install frontend dependencies
if not exist "welcome-hub-main\node_modules" (
    echo [2/4] Installing frontend dependencies...
    echo This may take 2-3 minutes on first run...
    cd welcome-hub-main
    call npm install
    if errorlevel 1 (
        echo ERROR: Failed to install frontend dependencies
        pause
        exit /b 1
    )
    cd ..
    echo [OK] Frontend dependencies installed
) else (
    echo [2/4] Frontend dependencies already installed
)

echo [3/4] Starting Backend Server...
start "Academia Backend" cmd /k "npx tsx -r dotenv/config server/index.ts"

echo Waiting for backend to start (10 seconds)...
timeout /t 10 /nobreak >nul

echo [4/4] Starting Desktop App...
cd welcome-hub-main
npm run desktop:dev

echo.
echo ==========================================
echo  Desktop app closed.
echo  Backend is still running in other window.
echo  Close that window to fully stop the app.
echo ==========================================
pause
