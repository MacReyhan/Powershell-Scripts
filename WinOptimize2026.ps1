# --- ADMIN AUTO-LAUNCH ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName PresentationFramework

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="ULTIMATE WINDOWS GOD MODE - 2026" Height="880" Width="1250" 
        Background="#0A0A0A" WindowStartupLocation="CenterScreen" ResizeMode="NoResize">
    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <StackPanel Grid.Row="0" Margin="0,0,0,20">
            <TextBlock Text="ULTIMATE WINDOWS GOD MODE" FontSize="32" Foreground="#00ffcc" HorizontalAlignment="Center" FontWeight="Bold"/>
            <TextBlock Text="LIVE CONSOLE MODE ACTIVE ✅" FontSize="12" Foreground="#4CAF50" HorizontalAlignment="Center"/>
        </StackPanel>

        <UniformGrid Grid.Row="1" Columns="5">
            <StackPanel Margin="8">
                <TextBlock Text="🛠️ SYSTEM &amp; NET" Foreground="Yellow" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btn1" Content="Massgrave" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btn2" Content="Chris Titus Utility" Margin="0,2" Padding="4" Background="#005a9e" Foreground="White" FontWeight="Bold"/>
                <Button Name="btn4" Content="SFC + DISM" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btnNetReset" Content="🌐 RESET NETWORK" Margin="0,5,0,2" Padding="6" Background="#8B0000" Foreground="White" FontWeight="Bold"/>
            </StackPanel>

            <StackPanel Margin="8">
                <TextBlock Text="⚡ UTILITIES" Foreground="#00CCFF" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btnTwinkle" Content="Twinkle Tray" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btnNerdFont" Content="Install Nerd Font" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
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
                <TextBlock Text="🏠 HOMELAB" Foreground="#FF00FF" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btnTailscale" Content="Tailscale" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btnRustDesk" Content="RustDesk" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btnPingVM" Content="Ping VMLinux" Margin="0,2" Padding="4" Background="#333" Foreground="#FF00FF"/>
            </StackPanel>

            <StackPanel Margin="8">
                <TextBlock Text="🎮 HARDWARE" Foreground="Orange" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btn21" Content="FanControl" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btn23" Content="MSI Afterburner" Margin="0,2" Padding="4" Background="#252525" Foreground="White"/>
                <Button Name="btn25" Content="UPGRADE ALL" Margin="0,15,0,0" Padding="10" Background="#005a9e" Foreground="White" FontWeight="Bold"/>
            </StackPanel>
        </UniformGrid>

        <StatusBar Grid.Row="2" Background="#1e1e1e" Foreground="White" Height="30">
            <TextBlock Name="txtStatus" Text="Ready, Sayan." VerticalAlignment="Center" Margin="10,0"/>
        </StatusBar>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$Form = [Windows.Markup.XamlReader]::Load($reader)
$btn = @{}; $xaml.SelectNodes("//*[@Name]") | ForEach-Object { $btn[$_.Name] = $Form.FindName($_.Name) }
$txtStatus = $Form.FindName("txtStatus")

# --- IMPROVED RUN LOGIC ---
# This now runs directly in the background terminal so you see the text!
function Run-LiveTask ($msg, $cmd) {
    $txtStatus.Text = "Status: Running $msg (Check Terminal)..."
    Invoke-Expression $cmd
    $txtStatus.Text = "Status: Finished $msg ✅"
}

# --- MAPPINGS ---
$btn.btn2.Add_Click({ Run-LiveTask "Chris Titus Utility" "irm https://christitus.com/win | iex" })
$btn.btn1.Add_Click({ Run-LiveTask "Massgrave" "irm https://get.activated.win | iex" })
$btn.btn4.Add_Click({ Run-LiveTask "Health Check" "sfc /scannow; DISM /Online /Cleanup-Image /RestoreHealth" })
$btn.btnNetReset.Add_Click({ Run-LiveTask "Net Reset" "netsh winsock reset; netsh int ip reset; ipconfig /flushdns" })
$btn.btnNerdFont.Add_Click({ Run-LiveTask "Nerd Font" "winget install --id GitHub.NerdFonts.JetBrainsMono -e" })
$btn.btn25.Add_Click({ Run-LiveTask "Update All" "winget upgrade --all --include-unknown" })
$btn.btnTwinkle.Add_Click({ Run-LiveTask "Twinkle Tray" "winget install --id XanderFrangos.TwinkleTray -e" })

# Add the rest as needed...
$btn.btn14.Add_Click({ Run-LiveTask "VS Code" "winget install --id Microsoft.VisualStudioCode -e" })

$Form.ShowDialog() | Out-Null
