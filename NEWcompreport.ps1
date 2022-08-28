<# Generate System report with name, disk, CPU, RAM, DomainJoin stat, Network ping status in HTML
Author - Prasant Chettri #>
# PluralSight Powershell HTML and CBE nugget youtube references and tech forums (https://community.spiceworks.com/topic/2313144-add-a-variable-to-an-html-report-with-table-view) for header block
# Ref1 https://devblogs.microsoft.com/scripting/working-with-html-fragments-and-files/
# Ref2 https://community.spiceworks.com/topic/2313144-add-a-variable-to-an-html-report-with-table-view

Set-Location $PSScriptRoot
# Creating label
$form = New-Object Windows.Forms.Form


$form.width = 500
$form.height = 300
$form.text = "Input to test network ping"
$form.BackColor="Blue"

# create label 
$label = new-object Windows.Forms.Label
$label.text = "Paste the computername to ping"

$label.Width=220
$label.height=20

$label.Location = New-Object Drawing.Point 100,30
$label.Backcolor='Orange'

$form.controls.add($label)
$form.ShowDialog

# create a text box
$textfield = new-object Windows.Forms.TextBox
$textfield.location = New-object Drawing.Point 100,80
$textfield.Width=220
$textfield.height=20

# Create command buttons
$btn = New-Object Windows.Forms.Button
$btn.location = New-Object Drawing.Point 100,120
$btn.Width=200
$btn.height=40
$btn.BackColor="Orange"
$btn.Text="OK";


 $eventHandler = [System.EventHandler]{
         $form.Close();
 };

 $btn.Add_Click($eventHandler) ;
 $DestC=$textfield.Text
<#$btn.Add_Click(
{
$DestC=$textfield.Text;
Write-host $DestC
[System.Windows.Forms.MessageBox]::show("Details acccepted.", "Admin Says")
$form.close()
}
)#>
$DestC=$textfield.Text
$form.controls.add($label)
$form.controls.add($textfield)
$form.controls.add($btn)
$form.ShowDialog()


#Style Sheet for HTML Report including Title
$header = @"
<style>
      h1 {

        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;

    }

    h2 {

        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;

    }

   table {
		font-size: 12px;
		border: 0px; 
		font-family: Arial, Helvetica, sans-serif;
	} 
	
    td {
		padding: 4px;
		margin: 0px;
		border: 0;
	}
	
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
	}

    tbody tr:nth-child(even) {
        background: #f0f0f2;
    }

        CreationDate {

        font-family: Arial, Helvetica, sans-serif;
        color: #ff3300;
        font-size: 12px;

    }
   
    </style>
"@

$computerName = hostname
$DestC=$textfield.Text
$UserPath = "$($env:USERPROFILE)\Documents\$computerName.html"  # Create a file with the host name on current user documents path

#Getting Computer Info
$computerInfo = Get-ComputerInfo | `
    #Selecting what data to show up in report with specifc header
    select-object @{n = 'Computername'; e = { $env:computername } },
@{n = 'OS Version'; e = { $_.WindowsProductName } },
@{n = 'Language'; e = { $_.OsLocale } },
@{n = 'CPU'; e = { $_.CsNumberOfProcessors } } ,
@{n = 'CPUCores'; e = { $_.CsNumberOfLogicalProcessors } } ,
@{n = 'RAM'; e = { [math]::round($_.OsTotalVisibleMemorySize / 1MB, 0) } } | `
    ConvertTo-Html -Fragment

#WindowsOS licensing details

$Licenseinfo= Get-CimInstance SoftwareLicensingProduct | where licensestatus -eq 1  | `
 Select-Object @{n = 'Windows Edition'; e = { $_.name} },
 @{n= 'Windows License Channel'; e = {$_.Description} } ` |
    ConvertTo-html -Fragment

#network test

$networkstat= Test-NetConnection -ComputerName $Destc |`
 Select-Object @{n = 'Network ping  '; e = { $_.PingSucceeded} }| ConvertTo-Html -Fragment

# Windows domain join status - Validating Domain status and generating HTML statement

$domainStat = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
if ($domainStat = "True")
{
$domainSuffix = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem | Select Domain

#Heading 
$cnn
$headinfo = [PSCustomObject]@{
"Summary of VM test information for "= $computerName
}| ConvertTo-Html -Property "Summary of VM test information for " -Fragment

# oPTIONAL
<#$domainname = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem |`
 Select-Object @{n= "DomainName"; e = {$_.domain} },
 @{n = 'This computer is joined to '; e = { $_.domain } }  | ConvertTo-Html -Fragment#>


 $DJstat = "$computerName is joined to domain $domainsuffix"
 }
 else{
 $DJstat = "$computerName failed to join domain $domainsuffix"
 }

 $DJdetail = [PSCustomObject]@{
 'Domain join status' = $DJstat
 } | convertto-html -Property  'Domain join status' -Fragment


#To get the logical disk information first drive letter which has logcal OS value of 3 and shows the remaining drive based on OS disk assignment
$diskInfo = Get-CimInstance Win32_LogicalDisk | `
    Where-Object { $_.DriveType -eq '3' } | `
    #Selecting what data to show up in report with specifc header
    Select-Object `
    DeviceID, @{N = 'Total Size(GB)'; E = { [math]::Round($_.Size / 1GB, 2) } }, @{N = 'Free size(GB)'; E = { [math]::Round($_.Freespace / 1GB) } } | `
    ConvertTo-Html -Fragment



# Validating network status and generating HTML statement

If ($netstat = "True")
{
$netrep = "The network test was successful"
}
 else {
 $netrep = "The network test was successful"
    }

#ConvertTo-Html requires an object let's create an object with network test status
$netdetail = [PSCustomObject]@{
 'Network Ping status' = $netrep
 } | convertto-html -Property  'Network Ping status' -Fragment # REF https://social.technet.microsoft.com/Forums/windowsserver/en-US/588275ba-1b3a-42af-b59c-20264b25ff99/converttohtml-shows-quotquot-in-html-table-column-header?forum=winserverpowershell
$htmlParams = @{
    #Title = $netrep
    Head = $header
    #we use 'Body' parameter instead of 'PostContent'.  'PostContent' is more of a 'footer' area.
    Body = "$headinfo $computerInfo $diskInfo $Licenseinfo $netdetail $DJdetail"
   
}


$netstat = Test-NetConnection -ComputerName google.com |select PingSucceeded 

#Generate HTML Report
ConvertTo-Html  `
               @htmlParams | Out-File $userpath -Force   #-Title "Network ping was successful"

#Opens the resulting report.html file using the system's default HTML viewer.
$fP="file://"
$fpath= $fp+$userpath
# Invoke-Item $UserPath (use this command if the Invoke command is supported
Start $fpath  # user this command if invoke cmdlet is blocked

#Copy to Blog SAS URL and container location - ISSUE change content type to fix browsing


$fname = (get-item $userpath).name 
$uri = "https://pctestsandreports.blob.core.windows.net/report/$($fname)?si=report&spr=https&sv=2021-06-08&sr=c&sig=XiFUSwxUblRn%2FAbCEKTiXjkNyvByLUPyr8L4jxMJanA%3D"
$headers = @{
    'x-ms-blob-type' = 'BlockBlob'
}
Invoke-restmethod -uri $uri -Method put -Headers $headers -InFile $Userpath -ContentType "text/html"