@echo off
echo ======================================================
echo    GitHub Repository Setup and Code Push Automation
echo ======================================================
echo.

set /p username=Enter your GitHub username: 

powershell -ExecutionPolicy Bypass -File "%~dp0setup-github-repo.ps1" -GithubUsername "%username%"

pause
