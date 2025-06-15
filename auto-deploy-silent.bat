@echo off
REM Silent GitHub repository setup and deployment
REM No user interaction required

echo Starting automated deployment...

REM Run the PowerShell script silently
powershell -ExecutionPolicy Bypass -File "%~dp0auto-deploy-silent.ps1"

REM Check if deployment was successful
if exist "%~dp0github_setup_success_*.txt" (
  echo Deployment completed successfully.
  echo Repository URL: https://github.com/elmentor/elmentor-landing-page-clean
  echo GitHub Pages: https://elmentor.github.io/elmentor-landing-page-clean/
) else (
  echo There might have been issues with deployment.
  echo Check github_setup.log for details.
)

REM Keep log file open if there were errors
if not exist "%~dp0github_setup_success_*.txt" (
  echo Opening log file...
  start notepad "%~dp0github_setup.log"
)
