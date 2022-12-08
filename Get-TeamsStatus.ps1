<#
.NOTES
    Name: Get-TeamsStatus.ps1
    Author: Danny de Vries
    Requires: PowerShell v2 or higher
    Version History: https://github.com/EBOOZ/TeamsStatus/commits/main
.SYNOPSIS
    Sets the status of the Microsoft Teams client to Home Assistant.
.DESCRIPTION
    This script is monitoring the Teams client logfile for certain changes. It
    makes use of two sensors that are created in Home Assistant up front.
    The status entity (sensor.teams_status by default) displays that availability 
    status of your Teams client based on the icon overlay in the taskbar on Windows. 
    The activity entity (sensor.teams_activity by default) shows if you
    are in a call or not based on the App updates deamon, which is paused as soon as 
    you join a call.
.PARAMETER SetStatus
    Run the script with the SetStatus-parameter to set the status of Microsoft Teams
    directly from the commandline.
.EXAMPLE
    .\Get-TeamsStatus.ps1 -SetStatus "Offline"
#>
# Configuring parameter for interactive run
Param($SetStatus)

# Set language variables below
$lgAvailable = "Available"
$lgBusy = "Busy"
$lgOnThePhone = "On the phone"
$lgAway = "Away"
$lgBeRightBack = "Be right back"
$lgDoNotDisturb = "Do not disturb"
$lgPresenting = "Presenting"
$lgFocusing = "Focusing"
$lgInAMeeting = "In a meeting"
$lgOffline = "Offline"
$lgNotInACall = "Not in a call"
$lgInACall = "In a call"

# Set icons to use for call activity
$iconInACall = "mdi:phone-in-talk-outline"
$iconNotInACall = "mdi:phone-off"
$iconMonitoring = "mdi:api"

# Set entities to post to
$entityStatus = "sensor.teams_status"
$entityStatusName = "Microsoft Teams status"
$entityActivity = "sensor.teams_activity"
$entityActivityName = "Microsoft Teams activity"
$entityHeartbeat = "binary_sensor.teams_monitoring"
$entityHeartbeatName = "Microsoft Teams monitoring"

$Enable = 1

$webhookUrl = "http://192.168.1.34:8000/webhook"

# Run the script when a parameter is used and stop when done
If($null -ne $SetStatus){
    Write-Host ("Setting Microsoft Teams status to "+$SetStatus+":")
    $params = @{
     "state"="$SetStatus";
     "attributes"= @{
        "friendly_name"="$entityStatusName";
        "icon"="mdi:microsoft-teams";
        }
     }
	 
    $params = $params | ConvertTo-Json
    Invoke-RestMethod -Uri "$HAUrl/api/states/$entityStatus" -Method POST -Body ([System.Text.Encoding]::UTF8.GetBytes($params)) -ContentType "application/json"
    break
}

# Start monitoring the Teams logfile when no parameter is used to run the script
Write-EventLog -LogName "Application" -Source "TeamsStatus" -EventID 3001 -EntryType Information -Message "Teams Status started" -Category 1 -RawData 10,20

DO {
# Get Teams Logfile and last icon overlay status
$TeamsStatus = Get-Content -Path $env:APPDATA"\Microsoft\Teams\logs.txt" -Tail 1000 | Select-String -Pattern `
  'Setting the taskbar overlay icon -',`
  'StatusIndicatorStateService: Added' | Select-Object -Last 1

# Get Teams Logfile and last app update deamon status
$TeamsActivity = Get-Content -Path $env:APPDATA"\Microsoft\Teams\logs.txt" -Tail 1000 | Select-String -Pattern `
  'Resuming daemon App updates',`
  'Pausing daemon App updates',`
  'SfB:TeamsNoCall',`
  'SfB:TeamsPendingCall',`
  'SfB:TeamsActiveCall',`
  'name: desktop_call_state_change_send, isOngoing' | Select-Object -Last 1

# Get Teams application process
$TeamsProcess = Get-Process -Name Teams -ErrorAction SilentlyContinue

# Check if Teams is running and start monitoring the log if it is
If ($null -ne $TeamsProcess) {
    If($TeamsStatus -eq $null){ }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgAvailable*" -or `
        $TeamsStatus -like "*StatusIndicatorStateService: Added Available*" -or `
        $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: Available -> NewActivity*") {
        $Status = $lgAvailable
        # Write-Host "$(Get-Date) - Status: $Status"
        # Add-Content $logFilePath "$(Get-Date) - Status: $Status"
    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgBusy*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added Busy*" -or `
            $TeamsStatus -like "*Setting the taskbar overlay icon - $lgOnThePhone*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added OnThePhone*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: Busy -> NewActivity*") {
        $Status = $lgBusy
        # Write-Host "$(Get-Date) - Status: $Status"
        # Add-Content $logFilePath "$(Get-Date) - Status: $Status"
    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgAway*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added Away*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: Away -> NewActivity*") {
        $Status = $lgAway
        # Write-Host "$(Get-Date) - Status: $Status"
        # Add-Content $logFilePath "$(Get-Date) - Status: $Status"
    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgBeRightBack*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added BeRightBack*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: BeRightBack -> NewActivity*") {
        $Status = $lgBeRightBack
        # Write-Host "$(Get-Date) - Status: $Status"
        # Add-Content $logFilePath "$(Get-Date) - Status: $Status"
    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgDoNotDisturb *" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added DoNotDisturb*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: DoNotDisturb -> NewActivity*") {
        $Status = $lgDoNotDisturb
        # Write-Host "$(Get-Date) - Status: $Status"
        # Add-Content $logFilePath "$(Get-Date) - Status: $Status"
    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgFocusing*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added Focusing*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: Focusing -> NewActivity*") {
        $Status = $lgFocusing
        # Write-Host "$(Get-Date) - Status: $Status"
        # Add-Content $logFilePath "$(Get-Date) - Status: $Status"
    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgPresenting*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added Presenting*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: Presenting -> NewActivity*") {
        $Status = $lgPresenting
        # Write-Host "$(Get-Date) - Status: $Status"
        # Add-Content $logFilePath "$(Get-Date) - Status: $Status"
    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgInAMeeting*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added InAMeeting*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: InAMeeting -> NewActivity*") {
        $Status = $lgInAMeeting
        # Write-Host "$(Get-Date) - Status: $Status"
        # Add-Content $logFilePath "$(Get-Date) - Status: $Status"
    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgOffline*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added Offline*") {
        $Status = $lgOffline
        # Write-Host "$(Get-Date) - Status: $Status"
        # Add-Content $logFilePath "$(Get-Date) - Status: $Status"
    }

    If($TeamsActivity -eq $null){ }
    ElseIf ($TeamsActivity -like "*Resuming daemon App updates*" -or `
        $TeamsActivity -like "*SfB:TeamsNoCall*" -or `
        $TeamsActivity -like "*name: desktop_call_state_change_send, isOngoing: false*") {
        $Activity = $lgNotInACall
        $ActivityIcon = $iconNotInACall
        # Write-Host "$(Get-Date) - Activity: $Activity"
        # Add-Content $logFilePath "$(Get-Date) - Activity: $Activity"
    }
    ElseIf ($TeamsActivity -like "*Pausing daemon App updates*" -or `
        $TeamsActivity -like "*SfB:TeamsActiveCall*" -or `
        $TeamsActivity -like "*name: desktop_call_state_change_send, isOngoing: true*") {
        $Activity = $lgInACall
        $ActivityIcon = $iconInACall
        # Write-Host "$(Get-Date) - Activity: $Activity"
        # Add-Content $logFilePath "$(Get-Date) - Activity: $Activity"
    }
}
# Set status to Offline when the Teams application is not running
Else {
        $Status = $lgOffline
        $Activity = $lgNotInACall
        $ActivityIcon = $iconNotInACall
        # Write-Host "$(Get-Date) - Status: $Status"
        # Add-Content $logFilePath "$(Get-Date) - Status: $Status"
        # Write-Host "$(Get-Date) - Activity: $Activity"
        # Add-Content $logFilePath "$(Get-Date) - Activity: $Activity"
}

# Call Home Assistant API to set the status and activity sensors
If ($CurrentStatus -ne $Status -and $Status -ne $null) {
    $CurrentStatus = $Status
	
    if ($Activity -eq "In a call") {
		$color = "red"
	}

    if ($Activity -eq "Not in a call") {
		$color = "green"
	}

    if ($Status -eq "Do not disturb") {
		$color = "red"
	}

    if ($Status -eq "Away") {
		$color = "off"
	}

    if ($Status -eq "Available" -and $Activity -eq "Not in a call"){
		$color = "green"
	}

    $params = @{
     "color"="$color";
     }
	 
    $params = $params | ConvertTo-Json
    $result  = Invoke-RestMethod -Uri "http://192.168.1.34:8000/webhook" -Method POST -Body ([System.Text.Encoding]::UTF8.GetBytes($params)) -ContentType "application/json" 
    Write-EventLog -LogName "Application" -Source "TeamsStatus" -EventID 3001 -EntryType Information -Message "Teams Status called webhook, result: $result" -Category 1 -RawData 10,20
    Write-Host "$(Get-Date) - Wehook result: $result"
}


If ($CurrentActivity -ne $Activity) {

    $CurrentActivity = $Activity

    if ($Activity -eq "In a call") {
		$color = "red"
	}

    if ($Activity -eq "Not in a call") {
		$color = "green"
	}
	
    if ($Status -eq "Do not disturb") {
		$color = "red"
	}

    if ($Status -eq "Available" -and $Activity -eq "Not in a call"){
		$color = "green"
	}

    if ($Status -eq "Away") {
		$color = "off"
	}

    $params = @{
     "color"="$color";
     }
	 
    $params = $params | ConvertTo-Json
    $result = Invoke-RestMethod -Uri "http://192.168.1.34:8000/webhook" -Method POST -Body ([System.Text.Encoding]::UTF8.GetBytes($params)) -ContentType "application/json" 
    Write-EventLog -LogName "Application" -Source "TeamsStatus" -EventID 3001 -EntryType Information -Message "Teams Status called webhook, result: $result" -Category 1 -RawData 10,20
    Write-Host "$(Get-Date) - Wehook result: $result"
}
    Start-Sleep 5
} Until ($Enable -eq 0)