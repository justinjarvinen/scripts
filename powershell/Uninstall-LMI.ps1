$services = "LMIGuardianSvc","LogMeIn","LMIMaint"
$tasks = "LMIGuardian",
         "LMIGuardianSvc",
         "LogMeIn",
         "LogMeInSystray",
         "ramaint"
$regItems = 'HKCU:\Software\LogMeIn',
            'HKCU:\Software\LogMeInInc',
            'HKLM:\Software\LogMeIn',
            'HKLM:\Software\LogMeIn, Inc.'
$dir = $(Get-Location).Path

#Stop Processes
foreach($task in $tasks){
    try {
        Stop-Process -Name $task -Force -ErrorAction Stop
        Write-Output("  Stopping $task")
    }
    catch {
        Write-Output("  **Could not find $task**")
    }
}

#Disable services
foreach($service in $services){
    try {
        Set-Service -Name $service -StartupType Disabled -ErrorAction Stop
        Write-Output("  Disabling service: $service...")
    }
    catch {
        Write-Output("  **Could not find $service...**")
    }
}

#Stop services
foreach($service in $services){
    try {
        Write-Output("  $service found running. Stopping...")
        Stop-Service -Name $service -Force -ErrorAction Stop
    }
    catch {
        Write-Output("  **Could not find $service...**")
    }
}

#Run LogMeIN uninstall option
Write-Output("--Running LMI Uninstall--")
Set-Location "C:\Program Files (x86)\LogMeIn\x86"
.\logmein uninstall -deleteall
Start-Sleep -s 10
Set-Location $dir

#Remove LogMeIn from registry locations
Write-Output("--Removing Registry Items--")

#Iterate through $regItems to remove all registry items.
foreach($item in $regItems){
    Write-Output("  Removing $item from registry...")

    try {
        Remove-Item -Path $item -Recurse -ErrorAction Stop
        Write-Output("  Removed $item")
    }
    catch {
        Write-Output("**Error removing $item from registry**")
    }
}

#Remove LogMeIn from Run in registry
try{
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -name "LogMeIn GUI" -ErrorAction Stop
}
catch {
    Write-Output("**Error removing LogMeIn from registry**")
}

#Remove LogMeIn Services
Write-Output("--Removing services--")
foreach($service in $services){
    Write-Output("  Deleting service $service ...")
    sc.exe delete $service
}

#Remove LMI directory
Write-Output("--Removing LMI directory--")
Remove-Item -Path "C:\Program Files (x86)\LogMeIn" -Force -Recurse

Write-Output("Script complete - LMI removed")