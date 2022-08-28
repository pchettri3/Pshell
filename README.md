# Pshell
<h1>Prasant Powershell repo</h1>

<h2>Powershell scripts for automation and testing</h2> 

<body><font-size: 12px> Updated - Newcompreport powershell file accepts the destination computer to ping in a text box and subsiquently stores to a variable to run later.
This powershell generates the report in HTML with each report extracted from the computer tagged with header description in blue background and white text.
The report extract computer and resource information in a table format and redirects to the Document folder of the user profile who is running it.

Remember it is not the default Document folder for the publc profile. Therefore, you may have to manually browse documents folder on your profile instead.
The report also gets redirected to publicly accessible blob storage container. Please generate your own SAS URI and replace the $URI content at line 230 for now
Duriing the redirection rest method also channges ContentType "text/html" from default "application/octet-stream" it changes the download report behaviour to show directly on the browser.</body>