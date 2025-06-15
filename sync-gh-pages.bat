@echo off
echo Syncing GitHub Pages with master branch
echo =======================================
echo.
powershell -ExecutionPolicy Bypass -File .\scripts\sync-gh-pages.ps1
pause
