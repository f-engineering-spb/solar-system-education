@echo off
chcp 65001 >nul
color 0A
title 🪐 Настройка Solar System Education

echo ================================================================
echo       🪐 ДОБРО ПОЖАЛОВАТЬ В ПРОЕКТ SOLAR SYSTEM EDUCATION!
echo ================================================================
echo.
echo [1/4] Проверка установленного ПО...

where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Git не обнаружен на вашем компьютере.
    echo Начинаю автоматическую установку Git for Windows...
    echo Пожалуйста, подождите 1-2 минуты...
    winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo [ВНИМАНИЕ] Не удалось установить через winget.
        echo Скачиваю официальный установщик Git...
        powershell -Command "Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe' -OutFile '%TEMP%\git-installer.exe'"
        echo Запуск тихой установки Git...
        "%TEMP%\git-installer.exe" /VERYSILENT /NORESTART
    )
    echo Git успешно установлен!
    set "PATH=%PATH%;C:\Program Files\Git\cmd"
) else (
    echo Git уже установлен и готов к работе.
)

echo.
echo [2/4] Проверка подключения к GitHub...
cd /d "%~dp0"
git remote -v >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    git init -b main
    git remote add origin https://github.com/f-engineering-spb/solar-system-education.git
)
echo Проект подключен к: https://github.com/f-engineering-spb/solar-system-education

echo.
echo [3/4] Создание ярлыков на Рабочем столе...
set "SCRIPT_DIR=%~dp0"
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut([System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), '🪐 Solar System Education.url')); $s.TargetPath = 'file:///' + '%SCRIPT_DIR%index.html'.Replace('\', '/'); $s.Save()"
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut([System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), '🚀 Отправить изменения на GitHub.lnk')); $s.TargetPath = '%SCRIPT_DIR%2_ОТПРАВИТЬ_ИЗМЕНЕНИЯ_НА_GITHUB.bat'; $s.WorkingDirectory = '%SCRIPT_DIR%'; $s.Save()"

echo Ярлыки созданы на вашем Рабочем столе!
echo.
echo [4/4] Запуск планетария в браузере...
start "" "%SCRIPT_DIR%index.html"

echo.
echo ================================================================
echo   ✅ Настройка завершена! Можете открывать index.html и творить!
echo ================================================================
echo.
pause
