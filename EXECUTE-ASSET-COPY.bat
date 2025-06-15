@echo off
echo 🚀 STARTING AUTOMATED ASSET COPY PROCESS...
echo.

REM Check if source files exist
echo 🔍 Verifying source files exist...
if not exist "d:\Github_personal\elmentor-landing-page\src\assets\images\elmentor-logo.png" (
    echo ❌ Source elmentor-logo.png not found
    goto :error
)
if not exist "d:\Github_personal\elmentor-landing-page\src\assets\images\mohamed-radwan.png" (
    echo ❌ Source mohamed-radwan.png not found
    goto :error
)
if not exist "d:\Github_personal\elmentor-landing-page\public\elmentor-circles.png" (
    echo ❌ Source elmentor-circles.png not found
    goto :error
)
echo ✅ All source files verified!
echo.

REM Create destination directories
echo 📁 Creating destination directories...
if not exist "public" mkdir "public"
if not exist "src\assets\images" mkdir "src\assets\images"
echo ✅ Directories ready!
echo.

REM Copy files with verification
echo 📋 Copying assets...

copy /Y "d:\Github_personal\elmentor-landing-page\src\assets\images\elmentor-logo.png" "src\assets\images\elmentor-logo.png" >nul 2>&1
if %errorlevel%==0 (
    echo ✅ elmentor-logo.png copied successfully
) else (
    echo ❌ Failed to copy elmentor-logo.png
)

copy /Y "d:\Github_personal\elmentor-landing-page\src\assets\images\mohamed-radwan.png" "src\assets\images\mohamed-radwan.png" >nul 2>&1
if %errorlevel%==0 (
    echo ✅ mohamed-radwan.png copied successfully
) else (
    echo ❌ Failed to copy mohamed-radwan.png
)

copy /Y "d:\Github_personal\elmentor-landing-page\public\elmentor-circles.png" "public\elmentor-circles.png" >nul 2>&1
if %errorlevel%==0 (
    echo ✅ elmentor-circles.png copied successfully
) else (
    echo ❌ Failed to copy elmentor-circles.png
)

copy /Y "d:\Github_personal\elmentor-landing-page\src\assets\images\DevOps-Visions.png" "src\assets\images\DevOps-Visions.png" >nul 2>&1
if %errorlevel%==0 (
    echo ✅ DevOps-Visions.png copied successfully
) else (
    echo ❌ Failed to copy DevOps-Visions.png
)

copy /Y "d:\Github_personal\elmentor-landing-page\src\assets\images\DevOps-Visions_Horizontal_Green.png" "src\assets\images\DevOps-Visions_Horizontal_Green.png" >nul 2>&1
if %errorlevel%==0 (
    echo ✅ DevOps-Visions_Horizontal_Green.png copied successfully
) else (
    echo ❌ Failed to copy DevOps-Visions_Horizontal_Green.png
)

echo.
echo 🎉 ASSET COPY PROCESS COMPLETED!
echo.
echo 📊 NEXT STEPS:
echo    1. All real assets are now in place
echo    2. Run: npm run dev
echo    3. Open browser to see the complete website
echo    4. All logos and images should display correctly
echo.
echo ✅ Ready to launch! The website now has all original assets.
echo.
pause
goto :end

:error
echo.
echo ❌ ERROR: Source files not found. Please check the original project path.
echo.
pause

:end
