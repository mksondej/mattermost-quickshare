function Show-Picker([string]$title, [array]$options, $idMember, $nameMember, [scriptblock]$onSelect) {
    #Created in POSHGUI
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $Form                            = New-Object system.Windows.Forms.Form
    $Form.ClientSize                 = '319,87'
    $Form.text                       = $title
    $Form.TopMost                    = $true
    $Form.SizeGripStyle = [System.Windows.Forms.SizeGripStyle]::Hide
    $Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle;
    $Form.MaximizeBox = $false; 
    $Form.StartPosition = "CenterScreen";

    $ComboBox1                       = New-Object system.Windows.Forms.ComboBox
    $ComboBox1.width                 = 291
    $ComboBox1.height                = 15
    $ComboBox1.location              = New-Object System.Drawing.Point(11,14)
    $ComboBox1.DataSource = [collections.arraylist]$options
    $ComboBox1.ValueMember = $idMember;
    $ComboBox1.DisplayMember = $nameMember;

    $Button1                         = New-Object system.Windows.Forms.Button
    $Button1.text                    = "Wyślij"
    $Button1.width                   = 60
    $Button1.height                  = 30
    $Button1.location                = New-Object System.Drawing.Point(242,43)
    $Button1.add_Click({ 
        &$onSelect $ComboBox1.SelectedItem 
        $Form.Close()
    })

    $Form.controls.AddRange(@($ComboBox1,$Button1))
    [void]$Form.showdialog()
}
function Show-Error([string]$msg) {
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    [System.Windows.MessageBox]::Show($msg, "Błąd", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
}
    
function Show-Notification([string]$title, [string]$msg) {
    Add-Type -AssemblyName  System.Windows.Forms 
    $balloon = New-Object System.Windows.Forms.NotifyIcon 
    $balloon.Icon  = [System.Drawing.Icon]::ExtractAssociatedIcon($PSCommandPath) 
    $balloon.BalloonTipText  = $msg
    $balloon.BalloonTipTitle  = $title
    $balloon.Visible  = $true
    $balloon.ShowBalloonTip(3000) 
}

function Write-Shortcut([string]$shortcutDir, [string]$mainExe, [string]$arguments, $name, $windowMode) {
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$shortcutDir\$name.lnk")
    $Shortcut.TargetPath = $mainExe
    $Shortcut.Arguments = $arguments
    $Shortcut.Save()
}