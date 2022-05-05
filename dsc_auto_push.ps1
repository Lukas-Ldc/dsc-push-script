#Path of the script
$path = Split-Path -parent $PSCommandPath

#List of Config_* directories by name
$configs = Get-ChildItem $path -Directory -Filter Config_* | Sort-Object
(Get-Date).ToString() | Out-File -FilePath $path\info.log

#Configs' loop
foreach ($conf in $configs) {

    #Configs' path
    $ConfigPath = $path + "\" + $conf
    Set-Location -Path $ConfigPath

    #List of scripts in the config
    $ConfigPS1 = Get-ChildItem $ConfigPath -File -Filter *.ps1 | Sort-Object
    
    #Scripts' loop
    foreach ($script in $ConfigPS1) {
        
        #Getting log file
        $script_name = $script.ToString() -replace ".ps1", ""
        $script_log = $script.ToString() -replace ".ps1", ".log"
        try { $logs_lines = Get-Content $script_log -EA Stop -EV 0 }
        catch { New-Item -Path . -Name $script_log -ItemType "file" -Value "NEW`r`nNEW" }
        finally { $logs_lines = Get-Content $script_log -EA Stop -EV 0 }

        #Script dates
        if ($logs_lines[0] -eq "NEW") {
            $last_execution = Get-Date 01/01/2000
        } else { 
            $last_execution = Get-Date $logs_lines[1]
            $last_verification = $logs_lines[2]
        }

        #Script execution
        if ((Get-Item $script).LastWriteTime -gt $last_execution) {

            #Old folder deletion
            if (Test-Path $script_name) {Remove-Item $script_name -Recurse -Force}

            #Execute script
            . .\$script

            #.mof creation
            & $script_name

            #DSC Configuration
            Start-DscConfiguration -Path $ConfigPath\$script_name -Wait -Force

            $last_execution = Get-Date
        }

        #Log file edit
        $last_verification = Get-Date
        "DO NOT MODIFY THIS FILE" | Out-File -FilePath $script_log
        ($last_execution).ToString() | Out-File -FilePath $script_log -Append
        ($last_verification).ToString() | Out-File -FilePath $script_log -Append

        #DSC Verification
        $computers_count = 0
        $computers_valid = 0
        $Conf_Computers = Get-ChildItem $ConfigPath\$script_name -File -Filter *.mof | Sort-Object
        foreach ($computer in $Conf_Computers) {
            $dsc_state = $false
            $computers_count ++
            $computer = $computer -replace ".mof", ""
            $cim_session = New-CimSession -ComputerName $computer
            $dsc_state = Test-DscConfiguration -CimSession $cim_session

            #Apply DSC if necessary
            if ($dsc_state -eq $false) {
                Start-DscConfiguration -Path $ConfigPath\$script_name -Wait -Force
                $dsc_state = Test-DscConfiguration -CimSession $cim_session
            }

            if($dsc_state -eq $true) {$computers_valid++}

            $computer + " [" + $dsc_state + "]" | Out-File -FilePath $script_log -Append
            Get-CimSession -ComputerName $computer | Remove-CimSession
        }

        $conf.ToString() + " (" + $script.ToString() + ") : " + [Math]::Floor(($computers_valid/$computers_count)*100).ToString() + "% (" + $computers_valid.ToString() + "/" + $computers_count.ToString() + ")" | Out-File -FilePath $path\info.log -Append
    }
}
Set-Location $path