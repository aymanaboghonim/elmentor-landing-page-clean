@echo off
echo Starting GitHub Pages deployment...
powershell -ExecutionPolicy Bypass -File "%~dp0deploy-github-pages.ps1"
pause
