@echo off
echo Automated PR Merge Tool
echo ==============================================

set /p branch="Enter source branch name (leave empty for feature/docs-organization): "
if "%branch%"=="" set branch=feature/docs-organization

set /p targetBranch="Enter target branch name (leave empty for master): "
if "%targetBranch%"=="" set targetBranch=master

set /p autoResolve="Attempt to auto-resolve conflicts? (y/n, default: n): "
if /i "%autoResolve%"=="y" (
  set autoResolveParam=-AutoResolve
) else (
  set autoResolveParam=
)

echo.
echo Will merge %branch% into %targetBranch%
echo.

powershell -ExecutionPolicy Bypass -File .\scripts\auto-merge-pr.ps1 -Branch %branch% -TargetBranch %targetBranch% %autoResolveParam%

pause
