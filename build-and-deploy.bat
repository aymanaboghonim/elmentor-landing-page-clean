@echo off
echo =====================================================
echo Elmentor/DevOps Visions Landing Page - Build Process
echo =====================================================
echo.
echo This script will build the project and verify that all
echo necessary components are present before deployment.
echo.
echo Before continuing, please ensure you have:
echo   1. Node.js installed (v16+ recommended)
echo   2. All assets copied (see ASSET_MIGRATION_GUIDE.md)
echo.
set /p CONTINUE=Do you want to continue? (Y/N): 

if /i "%CONTINUE%"=="Y" (    echo.
    echo Installing required dependencies for the verification script...
    npm install chalk --no-save
    
    echo.
    echo Running build and verification process...
    node build-and-verify.js
    
    echo.
    if %ERRORLEVEL% EQU 0 (
        echo Build completed successfully!
        echo You can now deploy the site following the instructions in DEPLOYMENT_GUIDE.md
    ) else (
        echo Build encountered issues. Please fix them before deployment.
    )
) else (
    echo.
    echo Build process canceled.
)

echo.
pause
