@echo off
:: =============================================================
::  Istaria: Chronicles of the Gifted — Performance Optimizer
::  Windows Native Version
::  Author: Marlon Alex Andrade
:: =============================================================

chcp 65001 >nul
setlocal enabledelayedexpansion
title Istaria Performance Optimizer

cls
echo.
echo ========================================
echo  Istaria Performance Optimizer
echo  by Marlon Alex Andrade
echo ========================================
echo.
echo  Optimizes Istaria for better performance on Windows.
echo  Otimiza o Istaria para melhor desempenho no Windows.
echo.
pause

set "SCRIPT_DIR=%~dp0"

:: =============================================================
::  ENCONTRAR ISTARIA
:: =============================================================
echo.
echo [Istaria Optimizer] Searching for Istaria / Procurando Istaria...

set "ISTARIA_DIR="

if exist "C:\Program Files (x86)\Istaria\istaria.exe" (
    set "ISTARIA_DIR=C:\Program Files (x86)\Istaria"
    goto :found
)
if exist "C:\Program Files\Istaria\istaria.exe" (
    set "ISTARIA_DIR=C:\Program Files\Istaria"
    goto :found
)

:: Tentar no registro
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v "InstallLocation" 2^>nul ^| findstr /i "istaria"') do (
    if exist "%%b\istaria.exe" (
        set "ISTARIA_DIR=%%b"
        goto :found
    )
)

:: Steam
for /f "tokens=2*" %%a in ('reg query "HKCU\SOFTWARE\Valve\Steam" /v "SteamPath" 2^>nul') do (
    set "STEAM_PATH=%%b"
)
if exist "%STEAM_PATH%\steamapps\common\Istaria\istaria.exe" (
    set "ISTARIA_DIR=%STEAM_PATH%\steamapps\common\Istaria"
    goto :found
)

echo.
echo [WARN] Istaria not found automatically / Istaria nao encontrado automaticamente.
echo.
set /p "ISTARIA_DIR=Enter Istaria path / Informe o caminho do Istaria: "

if not exist "!ISTARIA_DIR!\istaria.exe" (
    echo [ERROR] Invalid path / Caminho invalido: !ISTARIA_DIR!
    pause
    exit /b 1
)

:found
echo [Istaria Optimizer] Found / Encontrado: %ISTARIA_DIR%

:: =============================================================
::  INSTALAR DXVK
:: =============================================================
echo.
echo [Istaria Optimizer] Installing DXVK / Instalando DXVK...

if exist "%SCRIPT_DIR%dxvk\x32\d3d9.dll" (
    copy /y "%SCRIPT_DIR%dxvk\x32\d3d9.dll" "%ISTARIA_DIR%\" >nul
    if exist "%SCRIPT_DIR%dxvk\x32\d3d8.dll" copy /y "%SCRIPT_DIR%dxvk\x32\d3d8.dll" "%ISTARIA_DIR%\" >nul && echo [Istaria Optimizer] d3d8.dll installed / instalado
    echo [Istaria Optimizer] DXVK d3d9.dll installed / instalado!
) else (
    echo [WARN] DXVK not found in script folder / DXVK nao encontrado na pasta.
    echo [WARN] Download from / Baixe em: https://github.com/doitsujin/dxvk/releases
    echo [WARN] Copy x32/d3d9.dll to dxvk/x32/ folder and run again.
    pause
    exit /b 1
)

:: =============================================================
::  CONFIGURAR THREADS DXVK
:: =============================================================
echo.
echo [Istaria Optimizer] Configuring DXVK threads / Configurando threads DXVK...

:: Pegar numero de nucleos logicos
for /f "tokens=2 delims==" %%a in ('wmic cpu get NumberOfLogicalProcessors /value 2^>nul ^| findstr "="') do (
    set "TOTAL_THREADS=%%a"
)

:: Remover espacos
set "TOTAL_THREADS=%TOTAL_THREADS: =%"

:: Calcular 75% dos nucleos para Windows nativo
set /a "DXVK_THREADS=(%TOTAL_THREADS% * 3) / 4"
if %DXVK_THREADS% LSS 1 set "DXVK_THREADS=1"

echo [Istaria Optimizer] CPU threads: %TOTAL_THREADS% -- DXVK threads: %DXVK_THREADS% (CPU x 75%%)

:: Criar ou atualizar dxvk.conf
set "DXVK_CONF=%ISTARIA_DIR%\dxvk.conf"

:: Remover linha antiga se existir
if exist "%DXVK_CONF%" (
    findstr /v "numAsyncThreads" "%DXVK_CONF%" > "%DXVK_CONF%.tmp"
    move /y "%DXVK_CONF%.tmp" "%DXVK_CONF%" >nul
)

echo dxvk.numAsyncThreads = %DXVK_THREADS%>> "%DXVK_CONF%"
echo [Istaria Optimizer] dxvk.conf updated / atualizado: numAsyncThreads = %DXVK_THREADS%

:: =============================================================
::  CONCLUIDO
:: =============================================================
echo.
echo ========================================
echo  Done / Concluido!
echo ========================================
echo.
echo  DXVK installed with %DXVK_THREADS% async threads.
echo  DXVK instalado com %DXVK_THREADS% threads assincronas.
echo.
echo  Restart Istaria to apply changes.
echo  Reinicie o Istaria para aplicar as mudancas.
echo.
pause
