# Let's initialize some variables

$computername=$env:computername
$sidecar_installer = "collector_sidecar_installer_0.0.9_x64.exe"
$sidecar_prefix = "\\msufiles.admsu.montclair.edu\winserverdeploy\isim\graylog\"
$sidecar_filename = "C:\Program Files\Graylog\collector-sidecar\collector_sidecar.yml"
$drive_letter = "P"
$install_command = "$($drive_letter):\$($sidecar_installer)"
$install_args = "/S"

if (Test-Path "C:\Program Files\graylog\collector-sidecar\") {
    & "C:\Program Files\graylog\collector-sidecar\graylog-collector-sidecar.exe" "-service" "stop" | Out-Null
    & "C:\Program Files\graylog\collector-sidecar\graylog-collector-sidecar.exe" "-service" "uninstall" | Out-Null
    & "C:\Program Files\graylog\collector-sidecar\uninstall.exe" "/S" | Out-Null
}

# Determine if the IP address of the host is public or private
# And select the collector_sidecar.yml file based on that

Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'True'" -ComputerName $computername |
Select IPAddress |
ForEach-Object {
   if ($_.IPAddress -like "130.68.*") {
        $sidecar_conf = "collector_sidecar_windows.yml"
   }
   elseif ($_.IPAddress -like "10.*"){
        $sidecar_conf = "collector_sidecar_windowsdc.yml"
   }
}

# Mount the remote file share where our installers are

New-PSDrive -Name $drive_letter -PSProvider FileSystem -Root $sidecar_prefix

& $install_command $install_args | Out-Null

Copy-Item -Path "$($drive_letter):\$($sidecar_conf)" -Destination "$($sidecar_filename)"

& "C:\Program Files\graylog\collector-sidecar\graylog-collector-sidecar.exe" "-service" "install" | Out-Null
& "C:\Program Files\graylog\collector-sidecar\graylog-collector-sidecar.exe" "-service" "start" | Out-Null

Get-PSDrive $drive_letter | Remove-PSDrive
