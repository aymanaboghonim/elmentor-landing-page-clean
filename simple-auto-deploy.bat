@echo off
echo Starting automated GitHub setup and deployment...
powershell -ExecutionPolicy Bypass -File "%~dp0simple-auto-deploy.ps1"

if exist "%~dp0github_setup_success_*.txt" (
    echo.
    echo Deployment successful!
    echo.
    echo Repository: https://github.com/elmentor/elmentor-landing-page-clean
    echo Website: https://elmentor.github.io/elmentor-landing-page-clean/
    echo.
) else (
    echo.
    echo There may have been issues with deployment.
    echo Check github_setup.log for details.
    echo.
)

pause
