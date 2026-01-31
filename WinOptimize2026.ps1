# --- ADMIN AUTO-LAUNCH ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "No Admin? No problem, bro. Relaunching..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName PresentationFramework

# --- XAML UI DESIGN ---
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="ULTIMATE WINDOWS GOD MODE - 2026" Height="750" Width="900" 
        Background="#121212" WindowStartupLocation="CenterScreen" ResizeMode="NoResize">
    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <StackPanel Grid.Row="0" Margin="0,0,0,20">
            <TextBlock Text="ULTIMATE WINDOWS GOD MODE" FontSize="28" Foreground="#00ffcc" HorizontalAlignment="Center" FontWeight="Bold"/>
            <TextBlock Text="ADMIN PRIVILEGES GRANTED ✅" FontSize="11" Foreground="#4CAF50" HorizontalAlignment="Center"/>
        </StackPanel>

        <UniformGrid Grid.Row="1" Columns="3">
            <StackPanel Margin="10">
                <TextBlock Text="🛠️ SYSTEM CORE" Foreground="Yellow" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btnMassgrave" Content="Massgrave (Activate)" Margin="0,5" Padding="5" Background="#333" Foreground="White"/>
                <Button Name="btnChrisTitus" Content="Chris Titus Utility" Margin="0,5" Padding="5" Background="#333" Foreground="White"/>
                <Button Name="btnHealthCheck" Content="System Health Check" Margin="0,5" Padding="5" Background="#333" Foreground="White"/>
            </StackPanel>

            <StackPanel Margin="10">
                <TextBlock Text="👨‍💻 MCA DEV TOOLS" Foreground="Cyan" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btnVSCode" Content="VS Code" Margin="0,5" Padding="5" Background="#333" Foreground="White"/>
                <Button Name="btnNode" Content="Node.js LTS" Margin="0,5" Padding="5" Background="#333" Foreground="White"/>
                <Button Name="btnWSL" Content="WSL 2" Margin="0,5" Padding="5" Background="#333" Foreground="White"/>
            </StackPanel>

            <StackPanel Margin="10">
                <TextBlock Text="🚀 UPDATES" Foreground="Orange" FontWeight="Bold" Margin="0,0,0,10"/>
                <Button Name="btnUpdateAll" Content="UPGRADE ALL APPS" Margin="0,5" Padding="10" Background="#005a9e" Foreground="White" FontWeight="Bold"/>
            </StackPanel>
        </UniformGrid>

        <StatusBar Grid.Row="2" Background="#1e1e1e" Foreground="White" Height="30">
            <StatusBarItem>
                <TextBlock Name="txtStatus" Text="Ready for action, bro."/>
            </StatusBarItem>
        </StatusBar>
    </Grid>
</Window>
"@

# --- LOAD XAML ---
$reader = New-Object System.Xml.XmlNodeReader $xaml
$Form = [Windows.Markup.XamlReader]::Load($reader)

# --- MAP UI ELEMENTS ---
$btn = @{}
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { $btn[$_.Name] = $Form.FindName($_.Name) }
$txtStatus = $Form.FindName("txtStatus")

# --- LOGIC FUNCTION ---
function Run-Task ($name, $script) {
    $txtStatus.Text = "Running: $name..."
    # Run in a separate process to keep the GUI from freezing
    Start-Process powershell -ArgumentList "-NoProfile -Command $script" -Wait
    $txtStatus.Text = "Finished: $name ✅"
}

# --- BUTTON MAPPINGS ---
$btn.btnMassgrave.Add_Click({ Run-Task "Massgrave" "irm https://get.activated.win | iex" })
$btn.btnChrisTitus.Add_Click({ Run-Task "Chris Titus Tech" "irm https://christitus.com/win | iex" })
$btn.btnHealthCheck.Add_Click({ Run-Task "SFC & DISM" "sfc /scannow; DISM /Online /Cleanup-Image /RestoreHealth" })
$btn.btnVSCode.Add_Click({ Run-Task "VS Code" "winget install --id Microsoft.VisualStudioCode -e" })
$btn.btnUpdateAll.Add_Click({ Run-Task "Winget Upgrade" "winget upgrade --all --include-unknown" })

$Form.ShowDialog() | Out-Null
