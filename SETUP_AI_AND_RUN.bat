@echo off
setlocal EnableDelayedExpansion
title Academia Link Setup and Launcher

:: Check for admin privileges
net session >nul 2>&1
set "ADMIN=%errorlevel%"

echo ==========================================
echo    Academia Link Desktop App
echo    Complete Setup and Launcher
echo ==========================================
echo.

:: Check if Node.js is installed
echo [1/5] Checking Node.js installation...
node --version >nul 2>&1
if errorlevel 1 (
    echo Node.js is NOT installed
    echo.
    if %ADMIN% == 0 (
        echo Attempting to auto-install Node.js...
        echo Downloading Node.js installer...
        
        :: Download Node.js LTS
        powershell -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi' -OutFile '%TEMP%\nodejs.msi'" >nul 2>&1
        
        if exist "%TEMP%\nodejs.msi" (
            echo Installing Node.js silently...
            msiexec /i "%TEMP%\nodejs.msi" /qn /norestart
            if errorlevel 1 (
                echo Failed to auto-install Node.js.
                del "%TEMP%\nodejs.msi" 2>nul
                goto :manual_node
            )
            del "%TEMP%\nodejs.msi" 2>nul
            echo Node.js installed successfully.
            echo Please RESTART this script to continue.
            pause
            exit /b 0
        ) else (
            goto :manual_node
        )
    ) else (
        :manual_node
        echo.
        echo Please download and install Node.js:
        echo https://nodejs.org
        echo.
        echo OR run this script as Administrator for auto-install.
        echo.
        echo After installation, run this script again.
        start https://nodejs.org
        pause
        exit /b 1
    )
)
for /f "tokens=*" %%a in ('node --version') do set NODE_VERSION=%%a
echo OK - Node.js found: %NODE_VERSION%
echo.

:: Check if Ollama is installed
echo [2/5] Checking Ollama installation...
ollama --version >nul 2>&1
if errorlevel 1 (
    echo Ollama is NOT installed
    echo.
    if %ADMIN% == 0 (
        echo Attempting to auto-install Ollama...
        echo Downloading Ollama installer...
        
        :: Download Ollama for Windows
        powershell -Command "Invoke-WebRequest -Uri 'https://ollama.com/download/OllamaSetup.exe' -OutFile '%TEMP%\OllamaSetup.exe'" >nul 2>&1
        
        if exist "%TEMP%\OllamaSetup.exe" (
            echo Installing Ollama silently...
            "%TEMP%\OllamaSetup.exe" /S
            timeout /t 5 /nobreak >nul
            
            :: Verify installation
            ollama --version >nul 2>&1
            if errorlevel 1 (
                echo Failed to auto-install Ollama.
                del "%TEMP%\OllamaSetup.exe" 2>nul
                goto :manual_ollama
            )
            del "%TEMP%\OllamaSetup.exe" 2>nul
            echo Ollama installed successfully.
        ) else (
            goto :manual_ollama
        )
    ) else (
        :manual_ollama
        echo.
        echo Please download and install Ollama:
        echo https://ollama.com/download
        echo.
        echo OR right-click this script and select
        echo "Run as administrator" for auto-install.
        echo.
        echo Note: Ollama runs AI locally on your computer.
        echo It is free and works offline after setup.
        start https://ollama.com/download
        pause
        exit /b 1
    )
)
echo OK - Ollama is installed
echo.

:: Check if llama3.2 model is downloaded
echo [3/5] Checking AI model (llama3.2)...
ollama list 2>nul | findstr "llama3.2" >nul
if errorlevel 1 (
    echo WARNING: AI model not found. Downloading now...
    echo This is a one-time download (~2GB). May take 5-10 minutes.
    echo Please wait...
    echo.
    ollama pull llama3.2
    if errorlevel 1 (
        echo ERROR: Failed to download AI model.
        echo Please check your internet connection and try again.
        pause
        exit /b 1
    )
    echo OK - AI model downloaded successfully
) else (
    echo OK - AI model (llama3.2) is ready
)
echo.

:: Install dependencies if needed
echo [4/5] Installing app dependencies...

if not exist "node_modules" (
    echo Installing backend dependencies... (2-3 minutes)
    call npm install
    if errorlevel 1 (
        echo ERROR: Failed to install backend dependencies
        pause
        exit /b 1
    )
    echo OK - Backend dependencies installed
) else (
    echo OK - Backend dependencies already installed
)

if not exist "welcome-hub-main\node_modules" (
    echo Installing frontend dependencies... (2-3 minutes)
    cd welcome-hub-main
    call npm install
    if errorlevel 1 (
        echo ERROR: Failed to install frontend dependencies
        cd ..
        pause
        exit /b 1
    )
    cd ..
    echo OK - Frontend dependencies installed
) else (
    echo OK - Frontend dependencies already installed
)
echo.

:: Start the application
echo [5/5] Starting Academia Link Desktop App...
echo OK - All checks passed
echo.
echo Starting backend server...
start "Academia Backend" cmd /k "npx tsx -r dotenv/config server/index.ts"

echo Waiting for server to start (10 seconds)...
timeout /t 10 /nobreak >nul

echo Starting desktop app...
cd welcome-hub-main
npm run desktop:dev

:: After desktop closes
cd ..
echo.
echo ==========================================
echo Desktop app closed.
echo Backend server is still running.
echo Close the backend window to fully stop.
echo ==========================================
pause
