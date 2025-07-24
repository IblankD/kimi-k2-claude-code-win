@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ========== Kimi Claude Code Windows 安装脚本 ==========
echo.

REM 1. 检查 Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Node.js，请先从 https://nodejs.org/ 下载并安装 Node.js 18 或更高版本。
    pause
    exit /b
)

for /f "delims=" %%v in ('node -v') do set NODE_VER=%%v
set NODE_VER=%NODE_VER:v=%
for /f "tokens=1 delims=." %%m in ("%NODE_VER%") do set NODE_MAJOR=%%m

if %NODE_MAJOR% LSS 18 (
    echo [错误] 检测到 Node.js 版本为 %NODE_VER%，请升级到 18 或更高版本。
    pause
    exit /b
)
echo [OK] Node.js 版本 %NODE_VER% 检查通过。
echo.
pause

REM 2. 检查 npm
where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未检测到 npm，请确认 Node.js 安装完整。
    pause
    exit /b
)
echo [OK] npm 检查通过。
echo.
pause

REM 3. 安装 Claude Code CLI
where claude >nul 2>nul
if %errorlevel% neq 0 (
    echo [信息] 正在全局安装 Claude Code CLI...
    npm install -g @anthropic-ai/claude-code
    if %errorlevel% neq 0 (
        echo [错误] Claude Code CLI 安装失败，请检查网络或权限。
        pause
        exit /b
    )
    where claude >nul 2>nul
    if %errorlevel% neq 0 (
        echo [错误] 安装后未检测到 claude 命令，请重启终端或检查 npm 全局路径。
        pause
        exit /b
    )
    echo [信息] Claude Code CLI 安装成功。
) else (
    echo [信息] 已检测到 Claude Code CLI，版本如下：
    call claude --version
    if %errorlevel% neq 0 (
        echo [警告] claude --version 执行失败，可能需要重启终端或检查 npm 全局路径。
        echo [警告] 你可以重启命令行窗口后手动执行 claude --version 检查。
    )
)
echo.
pause

REM 4. 跳过 Claude Code 首次引导
echo [信息] 正在配置 Claude Code...
node -e "const fs=require('fs'),os=require('os'),path=require('path');const f=path.join(os.homedir(),'.claude.json');let c={};if(fs.existsSync(f)){try{c=JSON.parse(fs.readFileSync(f,'utf-8'));}catch{}}c.hasCompletedOnboarding=true;fs.writeFileSync(f,JSON.stringify(c,null,2),'utf-8');"
if %errorlevel% neq 0 (
    echo [警告] 跳过首次引导配置失败，可忽略。
)
echo.
pause

REM 5. 配置 API Key
set APIKEY=
:inputkey
set /p APIKEY=请输入你的 Moonshot API Key（输入内容不会隐藏）:
if "%APIKEY%"=="" (
    echo [错误] API Key 不能为空，请重新输入。
    goto inputkey
)

REM 6. 设置环境变量
setx ANTHROPIC_BASE_URL "https://api.moonshot.cn/anthropic/"
if %errorlevel% neq 0 (
    echo [警告] ANTHROPIC_BASE_URL 写入失败，请手动设置。
)
setx ANTHROPIC_API_KEY "%APIKEY%"
if %errorlevel% neq 0 (
    echo [警告] ANTHROPIC_API_KEY 写入失败，请手动设置。
)

echo.
echo [完成] 环境变量已写入。请关闭并重新打开命令行窗口以生效。
echo.
echo 你现在可以通过命令 claude 启动 Claude Code。
echo.
pause
endlocal