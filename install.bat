@echo off
REM RADICAL SEA BUNNY - Windows Installation Script
setlocal enabledelayedexpansion

echo [36m🐇 RADICAL SEA BUNNY v2.0.0 - Installation[0m
echo [34m🌊 Ultimate Cybersecurity Command & Control Platform[0m
echo.

REM Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [33m⚠️  Not running as administrator. Some features may not work.[0m
    echo [33m   Right-click and select "Run as administrator" for full functionality.[0m
    echo.
)

REM Check for Python
echo [34m📦 Checking Python installation...[0m
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [31m❌ Python not found![0m
    echo [33mPlease install Python 3.8+ from https://python.org[0m
    pause
    exit /b 1
)

python -c "import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)"
if %errorLevel% neq 0 (
    echo [31m❌ Python 3.8+ required![0m
    echo [33mPlease upgrade Python from https://python.org[0m
    pause
    exit /b 1
)

echo [32m✅ Python found[0m

REM Check for pip
echo [34m📦 Checking pip...[0m
python -m pip --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [33mInstalling pip...[0m
    python -m ensurepip --upgrade
)

REM Upgrade pip
echo [34m📦 Upgrading pip...[0m
python -m pip install --upgrade pip setuptools wheel

REM Install system dependencies (Chocolatey)
echo [34m📦 Checking for system dependencies...[0m
choco --version >nul 2>&1
if %errorLevel% equ 0 (
    echo [32m✅ Chocolatey found[0m
    choco install -y nmap curl netcat traceroute whois openssh
) else (
    echo [33m⚠️  Chocolatey not found[0m
    echo [33m   For full functionality, install Chocolatey and run:[0m
    echo [33m   choco install nmap curl netcat traceroute whois openssh[0m
)

REM Create virtual environment
echo [34m📦 Creating Python virtual environment...[0m
if not exist "venv" (
    python -m venv venv
)

REM Activate virtual environment
echo [34m📦 Activating virtual environment...[0m
call venv\Scripts\activate.bat

REM Install requirements
echo [34m📦 Installing Python dependencies...[0m
if exist "requirements.txt" (
    pip install -r requirements.txt
) else (
    echo [33mrequirements.txt not found, installing default packages...[0m
    pip install requests psutil colorama python-dotenv paramiko scapy whois cryptography discord.py slack-sdk telethon flask flask-socketio flask-cors numpy matplotlib seaborn reportlab qrcode pyshorteners tabulate tqdm
)

REM Create directories
echo [34m📁 Creating directories...[0m
if not exist ".radical_sea_bunny" mkdir .radical_sea_bunny
if not exist "radical_sea_bunny_reports" mkdir radical_sea_bunny_reports
if not exist ".radical_sea_bunny\payloads" mkdir .radical_sea_bunny\payloads
if not exist ".radical_sea_bunny\workspaces" mkdir .radical_sea_bunny\workspaces
if not exist ".radical_sea_bunny\scans" mkdir .radical_sea_bunny\scans
if not exist ".radical_sea_bunny\phishing_pages" mkdir .radical_sea_bunny\phishing_pages
if not exist ".radical_sea_bunny\phishing_templates" mkdir .radical_sea_bunny\phishing_templates
if not exist ".radical_sea_bunny\captured_credentials" mkdir .radical_sea_bunny\captured_credentials
if not exist ".radical_sea_bunny\ssh_keys" mkdir .radical_sea_bunny\ssh_keys
if not exist ".radical_sea_bunny\traffic_logs" mkdir .radical_sea_bunny\traffic_logs
if not exist ".radical_sea_bunny\nikto_results" mkdir .radical_sea_bunny\nikto_results
if not exist ".radical_sea_bunny\web_templates" mkdir .radical_sea_bunny\web_templates
if not exist ".radical_sea_bunny\sessions" mkdir .radical_sea_bunny\sessions
if not exist "radical_sea_bunny_reports\graphics" mkdir radical_sea_bunny_reports\graphics
if not exist "temp" mkdir temp

REM Create default config
if not exist ".radical_sea_bunny\config.json" (
    echo [32mCreating default configuration...[0m
    (
        echo {
        echo     "version": "2.0.0",
        echo     "auto_start": false,
        echo     "auto_block_enabled": false,
        echo     "auto_block_threshold": 5,
        echo     "scan_timeout": 30,
        echo     "report_format": "html",
        echo     "generate_graphics": true,
        echo     "web": {
        echo         "enabled": true,
        echo         "port": 5000,
        echo         "host": "0.0.0.0",
        echo         "secret_key": "",
        echo         "require_auth": false,
        echo         "username": "admin",
        echo         "password_hash": ""
        echo     },
        echo     "monitoring": {
        echo         "enabled": true,
        echo         "port_scan_threshold": 10,
        echo         "syn_flood_threshold": 100,
        echo         "http_flood_threshold": 200
        echo     },
        echo     "social_engineering": {
        echo         "enabled": true,
        echo         "default_port": 8080,
        echo         "capture_credentials": true,
        echo         "auto_shorten_urls": true
        echo     },
        echo     "ssh": {
        echo         "enabled": true,
        echo         "default_timeout": 30,
        echo         "max_connections": 5
        echo     }
        echo }
    ) > .radical_sea_bunny\config.json
)

REM Create launcher script
echo [34m📝 Creating launcher...[0m
(
    echo @echo off
    echo setlocal
    echo cd "%~dp0"
    echo call venv\Scripts\activate.bat
    echo python radical_sea_bunny.py %%*
    echo if %%errorlevel%% neq 0 pause
) > launch.bat

echo.
echo [32m✅ RADICAL SEA BUNNY installation complete![0m
echo.
echo [36m🐇 To start RADICAL SEA BUNNY:[0m
echo    [34mlaunch.bat[0m
echo.
echo [36m🐳 Docker installation:[0m
echo    [34mdocker build -t radical_sea_bunny .[0m
echo    [34mdocker run -it --network host radical_sea_bunny[0m
echo.
echo [33m⚠️  For full functionality, run launch.bat as administrator[0m
echo.
pause