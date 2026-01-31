Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Magick Batch Pro v2.0" Height="600" Width="500" Background="#1e1e1e">
    <StackPanel Margin="20">
        <TextBlock Text="Batch Print Resizer" FontSize="22" Foreground="#0078d4" HorizontalAlignment="Center" Margin="0,0,0,15"/>
        
        <Button Name="btnFolder" Content="Step 1: Select Source Folder" Height="35" Background="#333" Foreground="White" 
                ToolTip="Click to choose the folder where your original images are stored."/>
        <TextBlock Name="txtFolderPath" Text="No folder selected..." Foreground="#888" FontSize="10" Margin="0,5,0,10" TextAlignment="Center"/>

        <TextBlock Text="Step 2: Filter/Selection" Foreground="White" Margin="0,5"/>
        <TextBox Name="txtFilter" Text="*.jpg" Height="25" Background="#2d2d2d" Foreground="White" Padding="3"
                 ToolTip="Options:&#x0a;1. Wildcard: *.png or *-a4.jpg&#x0a;2. Range: 1-5, 8, 10-12&#x0a;Works for file names like '1.jpg' or '(1).jpg'"/>

        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,10">
            <TextBlock Text="Engine: " Foreground="White" VerticalAlignment="Center"/>
            <RadioButton Name="rbLegacy" Content="PS 5.1 (Stable)" Foreground="White" IsChecked="True" Margin="10,0" ToolTip="Uses standard sequential processing."/>
            <RadioButton Name="rbParallel" Content="PS 7+ (Parallel)" Foreground="White" ToolTip="Super fast! Uses multiple CPU cores for batching (Requires PowerShell 7)."/>
        </StackPanel>

        <Grid Margin="0,10">
            <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition/></Grid.ColumnDefinitions>
            <StackPanel Margin="5">
                <TextBlock Text="Paper Size:" Foreground="White"/>
                <ComboBox Name="comboSize" ToolTip="Standard paper dimensions in inches.">
                    <ComboBoxItem Content="A4 (210x297mm)" IsSelected="True"/><ComboBoxItem Content="Letter (8.5x11in)"/>
                    <ComboBoxItem Content="Legal (8.5x14in)"/><ComboBoxItem Content="A5 (148x210mm)"/>
                </ComboBox>
            </StackPanel>
            <StackPanel Margin="5" Grid.Column="1">
                <TextBlock Text="DPI (Density):" Foreground="White"/>
                <ComboBox Name="comboDPI" ToolTip="300 is standard for high-quality printing. 72 is for web.">
                    <ComboBoxItem Content="72"/><ComboBoxItem Content="150"/>
                    <ComboBoxItem Content="300" IsSelected="True"/><ComboBoxItem Content="600"/>
                </ComboBox>
            </StackPanel>
        </Grid>

        <Button Name="btnRun" Content="RUN BATCH PROCESS" Height="50" Background="#28a745" Foreground="White" FontWeight="Bold"
                ToolTip="Starts the ImageMagick conversion. Ensure ImageMagick is installed and in your PATH!"/>
        
        <ProgressBar Name="progBar" Height="15" Margin="0,15,0,5" Foreground="#0078d4"/>
        <TextBlock Name="txtStatus" Text="Ready" Foreground="#aaa" HorizontalAlignment="Center"/>
    </StackPanel>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# --- Mapping ---
$btnFolder = $window.FindName("btnFolder"); $txtFolderPath = $window.FindName("txtFolderPath")
$txtFilter = $window.FindName("txtFilter"); $btnRun = $window.FindName("btnRun")
$comboSize = $window.FindName("comboSize"); $comboDPI = $window.FindName("comboDPI")
$progBar = $window.FindName("progBar"); $txtStatus = $window.FindName("txtStatus")
$rbParallel = $window.FindName("rbParallel")

$script:sourceDir = ""

$btnFolder.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dlg.ShowDialog() -eq "OK") { $script:sourceDir = $dlg.SelectedPath; $txtFolderPath.Text = $script:sourceDir }
})

# --- Range Logic Function ---
function Get-FilteredFiles {
    param($dir, $inputStr)
    $allFiles = Get-ChildItem -Path $dir -File
    if ($inputStr -like "*\**" -or $inputStr -like "*.*") { return Get-ChildItem -Path $dir -Filter $inputStr }
    $indices = New-Object System.Collections.Generic.List[int]
    $inputStr.Split(',') | ForEach-Object {
        $part = $_.Trim()
        if ($part -match '(\d+)-(\d+)') { for ($i = [int]$matches[1]; $i -le [int]$matches[2]; $i++) { $indices.Add($i) } }
        elseif ($part -match '^\d+$') { $indices.Add([int]$part) }
    }
    return $allFiles | Where-Object { 
        $nameOnly = $_.BaseName
        if ($nameOnly -match '^\d+$') { $indices -contains [int]$nameOnly }
        elseif ($nameOnly -match '\((\d+)\)') { $indices -contains [int]$matches[1] }
    }
}

# --- Execution ---
$btnRun.Add_Click({
    if (-not $script:sourceDir) { [System.Windows.MessageBox]::Show("Select a folder, bro!"); return }
    $files = Get-FilteredFiles $script:sourceDir $txtFilter.Text
    if ($files.Count -eq 0) { [System.Windows.MessageBox]::Show("No files found!"); return }

    $dpi = $comboDPI.Text
    $size = $comboSize.Text
    switch -wildcard ($size) { "*A4*" { $w=8.27; $h=11.69 } "*Letter*" { $w=8.5; $h=11.0 } "*Legal*" { $w=8.5; $h=14.0 } "*A5*" { $w=5.83; $h=8.27 } }
    $pxW = [int]($w * $dpi); $pxH = [int]($h * $dpi)

    $progBar.Maximum = $files.Count
    $progBar.Value = 0

    if ($rbParallel.IsChecked -and $PSVersionTable.PSVersion.Major -ge 7) {
        $txtStatus.Text = "Running Parallel Processing (PS7)..."
        $files | ForEach-Object -Parallel {
            $outPath = Join-Path $using:script:sourceDir "Processed_$($_.Name)"
            $args = "`"$($_.FullName)`" -resize $($using:pxW)x$($using:pxH) -background white -gravity center -extent $($using:pxW)x$($using:pxH) -density $($using:dpi) -units pixelsperinch `"$outPath`""
            Start-Process magick -ArgumentList $args -Wait -NoNewWindow
        } -ThrottleLimit 6 # Good for your 6-core Ryzen
        $progBar.Value = $files.Count
    } else {
        foreach ($file in $files) {
            $outPath = Join-Path $script:sourceDir "Processed_$($file.Name)"
            $args = "`"$($file.FullName)`" -resize $($pxW)x$($pxH) -background white -gravity center -extent $($pxW)x$($pxH) -density $dpi -units pixelsperinch `"$outPath`""
            Start-Process magick -ArgumentList $args -Wait -NoNewWindow
            $progBar.Value++
            [System.Windows.Forms.Application]::DoEvents()
        }
    }
    $txtStatus.Text = "Finished! All files processed."
})

$window.ShowDialog() | Out-Null
