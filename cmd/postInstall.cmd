@echo OFF&SETLOCAL ENABLEDELAYEDEXPANSION
title Initial System Firewall & Safe Settings
mode con: cols=100 lines=30
cls

:setup
set value=1
REG ADD "HKLM\System\ControlSet001\Control\Terminal Server" /v fSingleSessionPerUser /t REG_DWORD /d %value% /f
@echo Set user single session success!
@echo --------------------------------

@echo Start add 139,445 deny firewall rule
netsh advfirewall firewall add rule name="deny tcp 445" dir=in protocol=tcp localport=445 action=block
netsh advfirewall firewall add rule name="deny udp 139" dir=in protocol=udp localport=139 action=block
netsh advfirewall firewall add rule name="deny tcp 139" dir=in protocol=tcp localport=139 action=block
@echo Deny 139,445 success!
@echo --------------------------------

@echo Start modify remote port

:setup
set port=3389
set /p port=Please input new remote port and press Enter key:
REG ADD "HKLM\System\CurrentControlSet\Control\Terminal Server\Wds\Rdpwd\Tds\Tcp" /v PortNumber /t REG_DWORD /d %port% /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d %port% /f

@echo Adding Remote Port firewall rule...
set firewallrulename=Remote
netsh advfirewall firewall show rule name="%firewallrulename%" >nul
if not ERRORLEVEL 1 (
	@echo Sorry, firewall rule %firewallrulename% exist, will delete the same name firewall rule and renew firewall rule for remote port
netsh advfirewall firewall delete rule name="%firewallrulename%"
netsh advfirewall firewall add rule name="%firewallrulename%" dir=in protocol=tcp localport=%port% action=allow
) else (
	@echo Add new remote firewall rule %firewallrulename%
netsh advfirewall firewall add rule name="%firewallrulename%" dir=in protocol=tcp localport=%port% action=allow
)

@echo There will be restart remote service 5 minitues later, use new remote port to login
>nul ping 127.0.0.1 /n 5
net stop termservice /y && net start termservice >nul
@echo Remote port modify success
pause

