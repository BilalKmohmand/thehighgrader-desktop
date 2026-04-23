@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Academia Link - AI Setup & Launcher

:: Colors for Windows 10+
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "BLUE=[94m"
set "NC=[0m"

echo %BLUE%==========================================%NC%
echo   Academia Link Desktop App
echo   Complete Setup ^& Launcher
echo %BLUE%==========================================%NC%
echo.

:: Check if Node.js is installed
echo [1/5] Checking Node.js installation...
node --version >nul 2>&1
if errorlevel 1 (
    echo %RED%❌ Node.js is NOT installed%NC%
    echo.
    echo %YELLOW%Please download and install Node.js:%NC%
    echo %BLUE%https://nodejs.org%NC%
    echo.
    echo %YELLOW%After installation, run this script again.%NC%
    pause
    exit /b 1
)
for /f "tokens=*" %%a in ('node --version') do set NODE_VERSION=%%a
echo %GREEN%✅ Node.js found: %NODE_VERSION%%NC%
echo.

:: Check if Ollama is installed
echo [2/5] Checking Ollama installation...
ollama --version >nul 2>&1
if errorlevel 1 (
    echo %RED%⚠️  Ollama is NOT installed%NC%
    echo.
    echo %YELLOW%Ollama is required for the AI features.%NC%
    echo.
    echo %BLUE%Please follow these steps:%NC%
    echo 1. Visit: https://ollama.com/download
    echo 2. Download for Windows
    echo 3. Run the installer (OllamaSetup.exe)
    echo 4. Click "Yes" to install
    echo 5. Return here and run this script again
    echo.
    echo %YELLOW%Note: Ollama runs AI locally on your computer.%NC%
    echo %YELLOW%It's free and works offline after setup.%NC%
    echo.
    start https://ollama.com/download
    pause
    exit /b 1
)
echo %GREEN%✅ Ollama is installed%NC%
echo.

:: Check if llama3.2 model is downloaded
echo [3/5] Checking AI model (llama3.2)...
ollama list | findstr "llama3.2" >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%⚠️  AI model not found. Downloading now...%NC%
    echo %YELLOW%This is a one-time download (~2GB). May take 5-10 minutes.%NC%
    echo %YELLOW%Please wait...%NC%
    echo.
    ollama pull llama3.2
    if errorlevel 1 (
        echo %RED%❌ Failed to download AI model.%NC%
        echo %YELLOW%Please check your internet connection and try again.%NC%
        pause
        exit /b 1
    )
    echo %GREEN%✅ AI model downloaded successfully!%NC%
) else (
    echo %GREEN%✅ AI model (llama3.2) is ready%NC%
)
echo.

:: Install dependencies if needed
echo [4/5] Installing app dependencies...

if not exist "node_modules" (
    echo %YELLOW%Installing backend dependencies... (2-3 minutes)%NC%
    call npm install
    if errorlevel 1 (
        echo %RED%❌ Failed to install backend dependencies%NC%
        pause
        exit /b 1
    )
    echo %GREEN%✅ Backend dependencies installed%NC%
) else (
    echo %GREEN%✅ Backend dependencies already installed%NC%
)

if not exist "welcome-hub-main\node_modules" (
    echo %YELLOW%Installing frontend dependencies... (2-3 minutes)%NC%
    cd welcome-hub-main
    call npm install
    if errorlevel 1 (
        echo %RED%❌ Failed to install frontend dependencies%NC%
        cd ..
        pause
        exit /b 1
    )
    cd ..
    echo %GREEN%✅ Frontend dependencies installed%NC%
) else (
    echo %GREEN%✅ Frontend dependencies already installed%NC%
)
echo.

:: Start the application
echo [5/5] Starting Academia Link Desktop App...
echo %GREEN%✅ All checks passed!%NC%
echo.
echo %YELLOW%Starting backend server...%NC%
start "Academia Backend" cmd /k "npx tsx -r dotenv/config server/index.ts"

echo %YELLOW%Waiting for server to start (10 seconds)...%NC%
timeout /t 10 /nobreak >nul

echo %GREEN%Starting desktop app...%NC%
cd welcome-hub-main
npm run desktop:dev

:: After desktop closes
cd ..
echo.
echo %BLUE%==========================================%NC%
echo Desktop app closed.
echo Backend server is still running.
echo Close the backend window to fully stop.
echo %BLUE%==========================================%NC%
pause
