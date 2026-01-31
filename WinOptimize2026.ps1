# --- ADMIN AUTO-LAUNCH ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="MAC LABS - MASTER CONSOLE" Height="950" Width="1350" 
        Background="#0A0A0A" WindowStartupLocation="CenterScreen" ResizeMode="NoResize">
    
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#151515"/>
            <Setter Property="Foreground" Value="#BBB"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Height" Value="38"/>
            <Setter Property="Margin" Value="0,4"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="6" BorderBrush="#222" BorderThickness="1">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid Margin="25">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/> <RowDefinition Height="Auto"/> <RowDefinition Height="*"/>    <RowDefinition Height="Auto"/> <RowDefinition Height="Auto"/> </Grid.RowDefinitions>

        <StackPanel Grid.Row="0" Margin="0,0,0,20">
            <TextBlock Text="MAC LABS" FontSize="42" FontWeight="ExtraBold" Foreground="#00FFAA" HorizontalAlignment="Center">
                <TextBlock.Effect><DropShadowEffect Color="#00FFAA" BlurRadius="20" ShadowDepth="0" Opacity="0.6"/></TextBlock.Effect>
            </TextBlock>
            <TextBlock Text="MODULAR AUTOMATION CONSOLE V8.0" FontSize="10" Foreground="#444" HorizontalAlignment="Center" LetterSpacing="3"/>
        </StackPanel>

        <Border Grid.Row="1" Background="#111" CornerRadius="8" Padding="12" Margin="0,0,0,25" BorderBrush="#222" BorderThickness="1">
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                <Button Name="btnToggleEngine" Content="WINGET ENGINE 📦" Width="240" Background="#005A9E" Foreground="White" FontWeight="Bold"/>
            </StackPanel>
        </Border>

        <UniformGrid Grid.Row="2" Columns="5">
            <StackPanel Margin="10">
                <TextBlock Text="SYSTEM" Foreground="#FFCC00" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btnMassgrave" Content="Activate Windows"/>
                <Button Name="btnCTT" Content="CTT Utility"/>
                <Button Name="btnHealth" Content="System Health"/>
                <Button Name="btnNetReset" Content="Reset Network" Background="#331111"/>
            </StackPanel>
            <StackPanel Margin="10">
                <TextBlock Text="UTILITIES" Foreground="#00CCFF" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btnTwinkle" Content="Twinkle Tray"/>
                <Button Name="btnNerdFont" Content="Nerd Fonts"/>
                <Button Name="btnEverything" Content="Everything Search"/>
                <Button Name="btnWizTree" Content="WizTree"/>
                <Button Name="btnAHK" Content="AutoHotkey v2"/>
            </StackPanel>
            <StackPanel Margin="10">
                <TextBlock Text="DEV" Foreground="#A0FE00" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btnVSCode" Content="VS Code"/>
                <Button Name="btnNode" Content="Node.js"/>
                <Button Name="btnPython" Content="Python 3"/>
                <Button Name="btnGit" Content="Git / GitHub"/>
                <Button Name="btnWSL" Content="WSL 2"/>
            </StackPanel>
            <StackPanel Margin="10">
                <TextBlock Text="HOMELAB" Foreground="#FF00FF" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btnTailscale" Content="Tailscale"/>
                <Button Name="btnRustDesk" Content="RustDesk"/>
                <Button Name="btnPingVM" Content="Ping VMLinux"/>
                <Button Name="btnPingGCS" Content="Ping GCSLinux"/>
            </StackPanel>
            <StackPanel Margin="10">
                <TextBlock Text="ACTIONS" Foreground="#FF5500" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btnWorkMode" Content="Work Mode" Background="#003333"/>
                <Button Name="btnBackup" Content="Backup Configs" Background="#221133"/>
                <Button Name="btnUpgradeAll" Content="UPGRADE ALL" FontWeight="Bold" Background="#005A9E" Height="50" Margin="0,15,0,0"/>
            </StackPanel>
        </UniformGrid>

        <Border Grid.Row="3" Background="#111" CornerRadius="10" Padding="15" Margin="0,15,0,10" BorderBrush="#222" BorderThickness="1">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                
                <StackPanel Grid.Column="0" Margin="10,0">
                    <TextBlock Name="lblCPU" Text="CPU LOAD: 0%" Foreground="#00FFAA" FontWeight="Bold" FontSize="11"/>
                    <ProgressBar Name="pbCPU" Height="8" Margin="0,5,0,0" Background="#222" Foreground="#00FFAA" BorderThickness="0"/>
                </StackPanel>
                
                <StackPanel Grid.Column="1" Margin="10,0">
                    <TextBlock Name="lblRAM" Text="RAM USAGE: 0%" Foreground="#00CCFF" FontWeight="Bold" FontSize="11"/>
                    <ProgressBar Name="pbRAM" Height="8" Margin="0,5,0,0" Background="#222" Foreground="#00CCFF" BorderThickness="0"/>
                </StackPanel>
            </Grid>
        </Border>

        <StatusBar Grid.Row="4" Background="Transparent" Foreground="#444" FontSize="10">
            <TextBlock Name="txtStatus" Text="Ready, Sayan."/>
        </StatusBar>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$Form = [Windows.Markup.XamlReader]::Load($reader)
$btn = @{}; $xaml.SelectNodes("//*[@Name]") | ForEach-Object { $btn[$_.Name] = $Form.FindName($_.Name) }
$pbCPU = $Form.FindName("pbCPU"); $lblCPU = $Form.FindName("lblCPU")
$pbRAM = $Form.FindName("pbRAM"); $lblRAM = $Form.FindName("lblRAM")
$txtStatus = $Form.FindName("txtStatus")

# --- STATS UPDATER ---
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(2)
$timer.Add_Tick({
    $cpu = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples.CookedValue
    $ram = Get-CimInstance Win32_OperatingSystem
    $ramUsed = [math]::Round((($ram.TotalVisibleMemorySize - $ram.FreePhysicalMemory) / $ram.TotalVisibleMemorySize) * 100, 1)
    
    $pbCPU.Value = $cpu
    $lblCPU.Text = "CPU LOAD: $([math]::Round($cpu, 1))%"
    $pbRAM.Value = $ramUsed
    $lblRAM.Text = "RAM USAGE: $ramUsed%"
})
$timer.Start()

# --- ENGINE LOGIC ---
$global:CurrentEngine = "Winget"
function Run-Task ($msg, $w, $c) {
    $cmd = if ($global:CurrentEngine -eq "Winget") { $w } else { $c }
    $txtStatus.Text = "Status: Executing $msg..."
    Invoke-Expression $cmd
    $txtStatus.Text = "Status: Done ✅"
}

# --- BUTTONS ---
$btn.btnToggleEngine.Add_Click({
    if ($global:CurrentEngine -eq "Winget") {
        $global:CurrentEngine = "Choco"; $this.Content = "CHOCO ENGINE 🍫"; $this.Background = "#7B3F00"
    } else {
        $global:CurrentEngine = "Winget"; $this.Content = "WINGET ENGINE 📦"; $this.Background = "#005A9E"
    }
})

$btn.btnMassgrave.Add_Click({ Run-Task "Massgrave" "irm https://get.activated.win | iex" "" })
$btn.btnCTT.Add_Click({ Run-Task "CTT" "irm https://christitus.com/win | iex" "" })
$btn.btnUpgradeAll.Add_Click({ Run-Task "Upgrade" "winget upgrade --all" "choco upgrade all -y" })
$btn.btnWorkMode.Add_Click({ Start-Process "https://www.flipkart.com"; Start-Process "wt.exe" })
$btn.btnPingVM.Add_Click({ Invoke-Expression "ping VMLinux -n 5; pause" })
$btn.btnPingGCS.Add_Click({ Invoke-Expression "ping GCSLinux -n 5; pause" })

# [Add other mappings as per v7.0 logic here...]

$Form.ShowDialog() | Out-Null
