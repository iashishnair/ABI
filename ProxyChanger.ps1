# Load Assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
# Create new Objects
$objForm = New-Object System.Windows.Forms.Form
$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon
$objContextMenu = New-Object System.Windows.Forms.ContextMenu
$ExitMenuItem = New-Object System.Windows.Forms.MenuItem
$ToggleMenuItem1 = New-Object System.Windows.Forms.MenuItem
$ToggleMenuItem2 = New-Object System.Windows.Forms.MenuItem
$StateMenuItem = New-Object System.Windows.Forms.MenuItem
# $regKey="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
$regKey="http://pac.zscalertwo.net/ab-inbev.com/Europe_New.pac"
$AutoConfig = "http://pac.zscalertwo.net/anheuser-busch.com/GHQ_NYO.pac"

Function UsePACFile {
# Modify proxy settings to "Use Config File"
	CD HKCU:\"Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections"
	Set-Itemproperty . DefaultConnectionSettings -Value ([byte[]](0x46,0x00,0x00,0x00,0x22,0x00,0x00,0x00,0x05,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x07,0x00,0x00,0x00,0x3C,0x6C,0x6F,0x63,0x61,0x6C,0x3E,0x1C,0x00,0x00,0x00,0x68,0x74,0x74,0x70,0x3A,0x2F,0x2F,0x77,0x70,0x61,0x64,0x2E,0x6E,0x73,0x73,0x2E,0x73,0x63,0x6F,0x74,0x2E,0x6E,0x68,0x73,0x2E,0x75,0x6B,0x2F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00))
}
Function UseNoPACFile {
# Set Proxy to empty
CD HKCU:\"Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections"
Set-Itemproperty . DefaultConnectionSettings -Value ([byte[]](0x46,0x00,0x00,0x00,0x22,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x07,0x00,0x00,0x00,0x3C,0x6C,0x6F,0x63,0x61,0x6C,0x3E,0x1C,0x00,0x00,0x00,0x68,0x74,0x74,0x70,0x3A,0x2F,0x2F,0x77,0x70,0x61,0x64,0x2E,0x6E,0x73,0x73,0x2E,0x73,0x63,0x6F,0x74,0x2E,0x6E,0x68,0x73,0x2E,0x75,0x6B,0x2F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00))
}
Function Build-Config {
# Create Menu Item
    $ToggleMenuItem1.Index = 1
    $ToggleMenuItem1.Text = "Disable Proxy PAC file"
    $ToggleMenuItem1.add_Click({
		Set-ItemProperty -path $regKey AutoConfigURL -Value ""
		UseNoPACFile
        Invoke-BalloonTip "Proxy PAC file disabled" "Proxy Changer"
    })
# Create Menu Item
    $ToggleMenuItem2.Index = 2
    $ToggleMenuItem2.Text = "Enable PAC: $AutoConfig "
    $ToggleMenuItem2.add_Click({
		Set-ItemProperty -path $regKey AutoConfigURL -Value $AutoConfig
		UsePACFile
        Invoke-BalloonTip "Proxy PAC enabled: $AutoConfig" "Proxy Tray"
    })
# Create State Item
    $StateMenuItem.Index = 3
    $StateMenuItem.Text = "Show Current Proxy Setting"
    $StateMenuItem.add_Click({
		$CurrentSetting = (Get-ItemProperty -path $regKey AutoConfigURL).AutoConfigURL
		If ($CurrentSetting) {
        	Invoke-BalloonTip "Current Proxy Setting: $CurrentSetting" "Proxy Tray"
		}
		Else {
			Invoke-BalloonTip "Current Proxy Setting: PAC Disabled" "Proxy Tray"
		}
    })

# Do not show Exit menu item for VP Users, will showdown on logoff/shutdown
# Create an Exit Menu Item
 #   $ExitMenuItem.Index = 4
  #  $ExitMenuItem.Text = "E&xit"
  #  $ExitMenuItem.add_Click({
  #      $objForm.Close()
  #      $objNotifyIcon.visible = $false
  #  })

# Add the Exit and Add Content Menu Items to the Context Menu
    $objContextMenu.MenuItems.Add($ToggleMenuItem1) | Out-Null
	$objContextMenu.MenuItems.Add($ToggleMenuItem2) | Out-Null
	$objContextMenu.MenuItems.Add($StateMenuItem) | Out-Null
# Do not show for VP Users
#   $objContextMenu.MenuItems.Add($ExitMenuItem) | Out-Null
}
Function Invoke-BalloonTip {
    Param (
        [Parameter(Mandatory=$True,HelpMessage="The message text to display. Keep it short and simple.")]
        [string]$Message,
        [Parameter(HelpMessage="The message title")]
         [string]$Title="Attention $env:username"
	)
	$MessageType="Info"
	$Duration = 1000
    #Can only use certain TipIcons: [System.Windows.Forms.ToolTipIcon] | Get-Member -Static -Type Property
    $objNotifyIcon.BalloonTipIcon  = [System.Windows.Forms.ToolTipIcon]$MessageType
    $objNotifyIcon.BalloonTipText  = $Message
    $objNotifyIcon.BalloonTipTitle = $Title
    #Display the tip and specify in milliseconds on how long balloon will stay visible
    $objNotifyIcon.ShowBalloonTip($Duration)
    Write-Verbose "Ending function"
}
# Build the context menu
Build-Config
# Assign an Icon to the Notify Icon object
# $objNotifyIcon.Icon = "C:\ProxyToggle\ico244.ico"
$objNotifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\System32\iscsicpl.exe")
$objNotifyIcon.Text = "Proxy Changer"
# Assign the Context Menu
$objNotifyIcon.ContextMenu = $objContextMenu
$objForm.ContextMenu = $objContextMenu
# Control Visibility and state of things
$objNotifyIcon.Visible = $true
$objForm.Visible = $false
$objForm.WindowState = "minimized"
$objForm.ShowInTaskbar = $false
$objForm.add_Closing({ $objForm.ShowInTaskBar = $False })
# Show the Form - Keep it open
# This Line must be Last
$objForm.ShowDialog()
