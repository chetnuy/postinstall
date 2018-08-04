echo "Post install script"
echo "author:nevernew"
echo "version: 0.1"
echo " "

echo "Бэкапим реестр"
reg export HKLM hklm_backup.reg
reg export HKCU hkcu_backup.reg
reg export HKCR hkcr_backup.reg

echo "Create backup pointer"
cmd /c "Wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "%DATE%", 100, 1"


#делаем юзера владельцем ключа автологера (для разблокировки реестра)
.\setacl.exe -on "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\WMI\AutoLogger" -ot reg -actn setowner -ownr "n:root"
# предоставляем полный доступ к ресурсу данной учетке
.\setacl.exe -on "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\WMI\AutoLogger" -ot reg -actn ace -ace "n:root;p:full"


#Отключаем кортану
echo "cortana"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowCortana" /v "value" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CanCortanaBeEnabled" /t REG_DWORD /d 0 /f
echo "end cortana"


#правим реестр
echo "Regedit"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\diagnosticshub.standardcollector.service" /v "Start" /t REG_DWORD /d 4 /f
reg add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger‐Diagtrack‐Listener" /v "Start" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger‐Diagtrack‐Listener" /v "Start" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" /v "Start" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d 1
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient" /v "CorporateSQMURL" /t REG_SZ /d "0.0.0.0" /f
reg add "HKCU\SOFTWARE\Policies\Microsoft\Office\16.0\osm" /v "Enablelogging" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Policies\Microsoft\Office\16.0\osm" /v "EnableUpload" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\MediaPlayer\Preferences" /v "UsageTracking" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds"/t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0" /v "NoExplicitFeedback" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f
echo "End Regedit"


#Останавливаем и отключаем службы
$Process= "DiagTrack", "dmwappushservice", "diagnosticshub.standardcollector.service", "DcpSvc", "WerSvc", "PcaSvc", "DoSvc", "WMPNetworkSvc","RemoteRegistry", "TermService", "TrkWks", "DPS", "SensorDataService", "SensorService", "SensrSvc", "XblAuthManager", "XblGameSave", "XboxNetApiSvc"

foreach ($item in $Process) {

cmd /c "net stop $item"
cmd /c "sc config $item start=disabled"

}

#отключам удаленного помощника
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d 0 /f

#отключаем административные шары
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "AutoShareWks" /t REG_DWORD /d 0 /f

#очистка файла подкачки
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown " /t REG_DWORD /d 1 /f

#ОТКЛЮЧАЕМ АВТОЗАПУСК СО СМЕННЫХ НОСИТЕЛЕЙ
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDriveTypeAutoRun" /t REG_DWORD /d 255 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoAutorun" /t REG_DWORD /d 1 /f

#Стираем историю открытых файлов, поиска, приложений
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\FileHistory" /v "Disabled" /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "DeviceHistoryEnabled" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessCallHistory" /t REG_DWORD /d 0 /f

echo oтключаем people
<<<<<<< HEAD
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /t REG_DWORD /d 0 /f
=======
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /t REG_DWORD /d 0 /f

>>>>>>> 8ef339fcf54d9f26ccbbe329d20a9b888c8e8bec

#onedrive delete
taskkill /f /im OneDrive.exe
cmd /c %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall

#создаем папку с настройками
cmd /c "mkdir c:\Users\root\Desktop\settings.{ED7BA470-8E54-465E-825C-99712043E01C}"

#отключаем автообновление и влючаем ручной запуск
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v " AUOptions" /t REG_DWORD /d 2 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownloadMode" /t REG_DWORD /d 0 /f



echo "Отключение запланированных задач"

$Task = "\Microsoft\Windows\FileHistory\File History (maintenance mode)", "\Microsoft\Windows\AppID\SmartScreenSpecific",`
"\Microsoft\Windows\Application Experience\AitAgent", "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",` 
"\Microsoft\Windows\Application Experience\ProgramDataUpdater", "\Microsoft\Windows\Application Experience\StartupAppTask",`
"Microsoft\Windows\Autochk\Proxy", "Microsoft\Windows\CloudExperienceHost\CreateObjectTask",`
 "Microsoft\Windows\Customer Experience Improvement Program\Consolidator", "Microsoft\Windows\Customer Experience Improvement Program\BthSQM",`
 "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask","Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",`
  "Microsoft\Windows\Customer Experience Improvement Program\Uploader", "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector", `
  "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver", "Microsoft\Windows\DiskFootprint\Diagnostics", `
  "Microsoft\Windows\FileHistory\File History (maintenance mode)", "Microsoft\Windows\Maintenance\WinSAT", "Microsoft\Windows\NetTrace\GatherNetworkInfo", `
  "Microsoft\Windows\PI\Sqm-Tasks", "Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem", "Microsoft\Windows\Shell\FamilySafetyMonitor", `
  "Microsoft\Windows\Shell\FamilySafetyRefresh", "Microsoft\Windows\Shell\FamilySafetyUpload", "Microsoft\Windows\Windows Error Reporting\QueueReporting"


foreach ($index in $Task){
schtasks /end /tn "$index"
schtasks /change /tn "$index" /disable
}

echo "install chocolatey.."
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco upgrade chocolatey
choco install googlechrome putty.install -y 

