@echo off
echo Starting asset copy process...

REM Create directories if they don't exist
if not exist "public" mkdir "public"
if not exist "src\assets\images" mkdir "src\assets\images"

REM Copy logo files
copy "d:\Github_personal\elmentor-landing-page\src\assets\images\elmentor-logo.png" "src\assets\images\elmentor-logo.png"
if %errorlevel%==0 echo ✅ Copied elmentor-logo.png

REM Copy founder image
copy "d:\Github_personal\elmentor-landing-page\src\assets\images\mohamed-radwan.png" "src\assets\images\mohamed-radwan.png"
if %errorlevel%==0 echo ✅ Copied mohamed-radwan.png

REM Copy circles diagram
copy "d:\Github_personal\elmentor-landing-page\public\elmentor-circles.png" "public\elmentor-circles.png"
if %errorlevel%==0 echo ✅ Copied elmentor-circles.png

REM Copy DevOps Visions logos
copy "d:\Github_personal\elmentor-landing-page\src\assets\images\DevOps-Visions.png" "src\assets\images\DevOps-Visions.png"
if %errorlevel%==0 echo ✅ Copied DevOps-Visions.png

copy "d:\Github_personal\elmentor-landing-page\src\assets\images\DevOps-Visions_Horizontal_Green.png" "src\assets\images\DevOps-Visions_Horizontal_Green.png"
if %errorlevel%==0 echo ✅ Copied DevOps-Visions_Horizontal_Green.png

echo.
echo 🎉 Asset copying completed!
echo You can now run: npm run dev
pause
