#echo "Disable Service Notification"
#reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d 0 /f

#reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d 1 /f

#echo "Disable Windows Defender"

#reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 0 /f



echo "Install Linux Subsystem"


# Create AppModelUnlock if it doesn't exist, required for enabling Developer Mode
$RegistryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
if (-not(Test-Path -Path $RegistryKeyPath)) {
    New-Item -Path $RegistryKeyPath -ItemType Directory -Force
}

# Add registry value to enable Developer Mode
New-ItemProperty -Path $RegistryKeyPath -Name AllowDevelopmentWithoutDevLicense -PropertyType DWORD -Value 1
# install Linux subsystem
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

echo "Disable embeded app"
Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage