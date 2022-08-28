# ref https://rzander.azurewebsites.net/download-files-from-azure-blob-storage-with-powershell/
# ref https://www.udemy.com/course/advanced-scripting-tool-making-using-windows-powershell/learn/lecture/9488316#overview
<#
$head = @"
<style>
h1, h5, th { text-align: center; }
table { margin: auto; font-family: Segoe UI;  box-shadow: 10px 10px 5px #888; border:thin ride grey; }
th { background: #00463: color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20 px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) {background: #b8d1f3; }
</style>
"@

$head
$body ="<h1>Host config and test repport</h1> n<h5>updated: on $(get-date) </h5>"#>

#Author - Prasant Chettri
#This script will extract servername, domainjoinstatus, disk sizes in GB, RAM size in GB, network ping status, Windows version, windows license status 
$h=hostname
$UserPath = "$($env:USERPROFILE)\Documents\$h.txt"
$UserP = "$($env:USERPROFILE)\Documents\$h.html"
$UserC = "$($env:USERPROFILE)\Documents\$h.csv"
$domainStat = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain

$domainname = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem | Select Domain

$prefix = " Domain join status = "
$headerer = "Computername = "


$header,$h,$domainname,$prefix,$domainStat | out-file $UserPath

$Name = "Computer name = "
$WinEd = "Windows Editiona = "
$Prod = "Windows Product = "
$domainDetail = $h + "is joined to "+$domainname
if ($domainStat = "True")
{
Write-Output $header + "is joined to "+$dom
echo $domainDetail| Add-content $UserPath
$domainif=  $header + "is joined to "+$dom
}
else
{
Write-Output "Ths computer has not joined to the domain"
echo "Ths computer has not joined to the domain" |Add-content $UserPath
donainif= $header + "is joined to "+$dom
}

Get-Computerinfo -Property WindowsEditionId, WindowsProductName, WindowsVersion, CsDNSHostName,LogonServer,OsTotalVisibleMemorySize |  Select CsDNSHostName, WindowsEditionId, WindowsProductName, WindowsVersion, LogonServer,@{Name="RAMinGB";Expression={$_.OsTotalVisibleMemorySize/1MB}} | ft | Add-Content $UserPath

get-wmiobject -class win32_logicaldisk  | select DeviceID, @{Name="SizeinGB";Expression={$_.size/1GB}} |Add-Content $UserPath

Test-NetConnection -ComputerName obmgrcxazw1wp03 | Select Computername,RemoteAddress, PingSucceeded |  Add-Content $UserPath

Get-CimInstance SoftwareLicensingProduct | where licensestatus -eq 1  | Select name, description, @{Label='computer'; Expression = {$_.PscomputerName}} |ft  name, description, computer >> $UserPath

echo $UserPath

$content = Get-Content "$($env:USERPROFILE)\Documents\$h.txt" -raw 
$html =  @"
<style>
h1, h5, th { text-align: center; }
table { margin: auto; font-family: Segoe UI;  box-shadow: 10px 10px 5px #888; border:thin ride grey; }
th { background: #00463: color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20 px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) {background: #b8d1f3; }
</style>
<body>"<h1>Host config and test report</h1> n<h5>updated: on $(get-date) </h5> <pre>$($content) </pre> "<body>
<body><pre>$($content.PSProvider)</pre></body>
"@
#$body
$html | Out-File $UserP


# Get-Computerinfo | convertto-Html -Property WindowsEditionId, WindowsProductName, WindowsVersion, CsDNSHostName,LogonServer,OsTotalVisibleMemorySize | Select CsDNSHostName, WindowsEditionId, WindowsProductName, WindowsVersion, LogonServer,@{Name="RAMinGB";Expression={$_.OsTotalVisibleMemorySize/1MB}} | Add-Content $UserC

$body="<h3>Domain join status</h3>'n<h3>Updated: on $(Get-date)</h3>"
# $userC | convertto-Html -Property WindowsEditionId, WindowsProductName, WindowsVersion, CsDNSHostName,LogonServer,OsTotalVisibleMemorySize -head $header -Body $body | out-fule userP

#$body="<h3>Domain join status</h3>'n<h3>Updated: on $(Get-date)</h3>"
# $UserPath | ConvertTo-html -property WindowsEditionId, WindowsProductName, WindowsVersion, CsDNSHostName,LogonServer,OsTotalVisibleMemorySize -Head $header -Body $body | out-file $UserP

# (get-item $userp).name 
# $headerers= @{'x-ms-blob-type' = 'Blockblob'
# Invoke-restmethod -uri $uri -Method put -Headers $headerers -InFile $file