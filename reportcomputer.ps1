#Author - Prasant Chettri
#This script will extract servername, domainjoinstatus, disk sizes in GB, RAM size in GB, network ping status, Windows version, windows license status 
$UserPath = "$($env:USERPROFILE)\Documents\report.txt"
$domainStat = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain

$domainname = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem | Select Domain

$prefix = " Domain join status = "
$head = "Computername = "
$h=hostname

$head,$h,$domainname,$prefix,$domainStat | out-file $UserPath

$Name = "Computer name = "
$WinEd = "Windows Editiona = "
$Prod = "Windows Product = "


Get-Computerinfo -Property WindowsEditionId, WindowsProductName, WindowsVersion, CsDNSHostName,LogonServer,OsTotalVisibleMemorySize | Select CsDNSHostName, WindowsEditionId, WindowsProductName, WindowsVersion, LogonServer,@{Name="RAMinGB";Expression={$_.OsTotalVisibleMemorySize/1MB}} | Add-Content $UserPath

get-wmiobject -class win32_logicaldisk |select DeviceID, @{Name="SizeinGB";Expression={$_.size/1GB}} | Add-Content $UserPath

Test-NetConnection -ComputerName obmgrcxazw1wp03 | Select Computername,RemoteAddress, PingSucceeded | Add-Content $UserPath

Get-CimInstance SoftwareLicensingProduct | where licensestatus -eq 1  | Select name, description, @{Label='computer'; Expression = {$_.PscomputerName}} |ft  name, description, computer >> $UserPath
