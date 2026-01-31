# --- ADMIN AUTO-LAUNCH ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName PresentationFramework

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="ULTIMATE WINDOWS GOD MODE - 2026" Height="900" Width="1300" 
        Background="#080808" WindowStartupLocation="CenterScreen" ResizeMode="NoResize">
    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <StackPanel Grid.Row="0" Margin="0,0,0,10">
            <TextBlock Text="ULTIMATE WINDOWS GOD MODE" FontSize="32" Foreground="#00ffcc" HorizontalAlignment="Center" FontWeight="Bold"/>
        </StackPanel>

        <StackPanel Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,0,0,20">
            <TextBlock Text="ENGINE:" Foreground="White" VerticalAlignment="Center" Margin="0,0,10,0" FontWeight="Bold"/>
            <Button Name="btnToggleEngine" Content="SWITCH TO CHOCOLATEY 🍫" Width="220" Padding="8" Background="#005a9e" Foreground="White" FontWeight="Bold"/>
        </StackPanel>

        <UniformGrid Grid.Row="2" Columns="5">
            <StackPanel Margin="8">
                <TextBlock Text="🛠️ SYSTEM" Foreground="Yellow" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btn1" Content="Massgrave" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btn2" Content="Chris Titus" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btn4" Content="SFC + DISM" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btnNetReset" Content="NET RESET" Margin="0,5,0,2" Padding="6" Background="#8B0000" Foreground="White"/>
            </StackPanel>

            <StackPanel Margin="8">
                <TextBlock Text="⚡ UTILS" Foreground="#00CCFF" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btnTwinkle" Content="Twinkle Tray" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btnNerdFont" Content="Nerd Font" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btn9" Content="Everything" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btn13" Content="AutoHotkey v2" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
            </StackPanel>

            <StackPanel Margin="8">
                <TextBlock Text="👨‍💻 MCA DEV" Foreground="#A0FE00" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btn14" Content="VS Code" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btn17" Content="Node.js LTS" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btn19" Content="WSL 2" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
            </StackPanel>

            <StackPanel Margin="8">
                <TextBlock Text="🏠 HOME" Foreground="#FF00FF" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btnTailscale" Content="Tailscale" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btnRustDesk" Content="RustDesk" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btnPingVM" Content="Ping VM" Margin="0,2" Padding="4" Background="#333" Foreground="#FF00FF"/>
            </StackPanel>

            <StackPanel Margin="8">
                <TextBlock Text="🚀 ACTIONS" Foreground="Orange" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btn25" Content="UPGRADE ALL" Margin="0,2" Padding="10" Background="#005a9e" Foreground="White" FontWeight="Bold"/>
                <Button Name="btnSearch" Content="🔍 SEARCH PACKS" Margin="0,5,0,2" Padding="6" Background="#252525" Foreground="White"/>
            </StackPanel>
        </UniformGrid>

        <StatusBar Grid.Row="3" Background="#1e1e1e" Foreground="White" Height="30">
            <TextBlock Name="txtStatus" Text="Engine: WINGET | Ready, Sayan." VerticalAlignment="Center" Margin="10,0"/>
        </StatusBar>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$Form = [Windows.Markup.XamlReader]::Load($reader)
$btn = @{}; $xaml.SelectNodes("//*[@Name]") | ForEach-Object { $btn[$_.Name] = $Form.FindName($_.Name) }
$txtStatus = $Form.FindName("txtStatus")

# --- ENGINE STATE ---
$global:CurrentEngine = "Winget"

function Run-Task ($msg, $wingetCmd, $chocoCmd) {
    $cmd = if ($global:CurrentEngine -eq "Winget") { $wingetCmd } else { $chocoCmd }
    $txtStatus.Text = "Status: Running via $($global:CurrentEngine)..."
    Invoke-Expression $cmd
    $txtStatus.Text = "Status: Finished $msg ✅"
}

# --- TOGGLE LOGIC ---
$btn.btnToggleEngine.Add_Click({
    if ($global:CurrentEngine -eq "Winget") {
        $global:CurrentEngine = "Choco"
        $this.Content = "SWITCH TO WINGET 📦"
        $this.Background = "#7b3f00" # Chocolate Brown
        $btn.btn25.Background = "#7b3f00"
        $txtStatus.Text = "Engine: CHOCOLATEY | Ready, Sayan."
    } else {
        $global:CurrentEngine = "Winget"
        $this.Content = "SWITCH TO CHOCOLATEY 🍫"
        $this.Background = "#005a9e" # Winget Blue
        $btn.btn25.Background = "#005a9e"
        $txtStatus.Text = "Engine: WINGET | Ready, Sayan."
    }
})

# --- DUAL-COMMAND MAPPINGS ---
$btn.btn14.Add_Click({ Run-Task "VS Code" "winget install Microsoft.VisualStudioCode -e" "choco install vscode -y" })
$btn.btn17.Add_Click({ Run-Task "Node.js" "winget install OpenJS.NodeJS.LTS -e" "choco install nodejs-lts -y" })
$btn.btn25.Add_Click({ Run-Task "Upgrade All" "winget upgrade --all" "choco upgrade all -y" })
$btn.btnTwinkle.Add_Click({ Run-Task "Twinkle Tray" "winget install XanderFrangos.TwinkleTray -e" "choco install twinkle-tray -y" })
$btn.btnNerdFont.Add_Click({ Run-Task "Nerd Font" "winget install GitHub.NerdFonts.JetBrainsMono -e" "choco install jetbrainsmono-nerdfont -y" })
$btn.btn9.Add_Click({ Run-Task "Everything" "winget install voidtools.Everything -e" "choco install everything -y" })
$btn.btn13.Add_Click({ Run-Task "AHK" "winget install AutoHotkey.AutoHotkey -e" "choco install autohotkey -y" })
$btn.btnTailscale.Add_Click({ Run-Task "Tailscale" "winget install Tailscale.Tailscale -e" "choco install tailscale -y" })
$btn.btnRustDesk.Add_Click({ Run-Task "RustDesk" "winget install RustDesk.RustDesk -e" "choco install rustdesk -y" })

# Native/Script Commands (Same for both)
$btn.btn1.Add_Click({ Invoke-Expression "irm https://get.activated.win | iex" })
$btn.btn2.Add_Click({ Invoke-Expression "irm https://christitus.com/win | iex" })
$btn.btn4.Add_Click({ Invoke-Expression "sfc /scannow; DISM /Online /Cleanup-Image /RestoreHealth" })
$btn.btnNetReset.Add_Click({ Invoke-Expression "netsh winsock reset; netsh int ip reset; ipconfig /flushdns" })
$btn.btnPingVM.Add_Click({ Invoke-Expression "ping VMLinux -n 5; pause" })

$Form.ShowDialog() | Out-Null
