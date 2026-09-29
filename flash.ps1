<#
.SYNOPSIS
    ESP32 NAT Router - Automated 1-Click Flasher
.DESCRIPTION
    Detects the connected ESP32, ensures esptool is installed, and cleanly
    erases and flashes the firmware binaries.
#>

$ErrorActionPreference = "Stop"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "       ESP32 Hardware Shield - Portable Flasher        " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check Python
Write-Host "[1/4] Checking Python environment..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "      Found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Python is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install Python from https://www.python.org/downloads/ and check 'Add to PATH'." -ForegroundColor Yellow
    exit 1
}

# 2. Check / Install esptool
Write-Host "[2/4] Verifying esptool..." -ForegroundColor Yellow
$esptoolInstalled = $false
try {
    python -m esptool version 2>&1 | Out-Null
    $esptoolInstalled = $true
    Write-Host "      esptool is ready." -ForegroundColor Green
} catch {
    Write-Host "      esptool not found. Installing via pip..." -ForegroundColor Yellow
    python -m pip install --upgrade pip esptool | Out-Null
    Write-Host "      esptool installed successfully." -ForegroundColor Green
}

# 3. Detect COM Port
Write-Host "[3/4] Detecting connected ESP32..." -ForegroundColor Yellow
$ports = Get-CimInstance Win32_PnPEntity | Where-Object { 
    $_.PNPClass -eq 'Ports' -and $_.Name -match 'COM\d+' -and $_.Name -notmatch 'Bluetooth'
}

$targetPort = $null

if ($ports.Count -eq 1) {
    if ($ports.Name -match '\((COM\d+)\)') {
        $targetPort = $matches[1]
    }
} elseif ($ports.Count -gt 1) {
    Write-Host "Multiple serial ports found:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $ports.Count; $i++) {
        Write-Host "  [$i] $($ports[$i].Name)"
    }
    $selection = Read-Host "Select port number (0-$($ports.Count - 1))"
    if ($ports[$selection].Name -match '\((COM\d+)\)') {
        $targetPort = $matches[1]
    }
}

if (-not $targetPort) {
    # Fallback to manual entry or serial port query
    $allPorts = [System.IO.Ports.SerialPort]::GetPortNames()
    if ($allPorts.Count -eq 1) {
        $targetPort = $allPorts[0]
    } else {
        Write-Host "Available COM ports: $($allPorts -join ', ')" -ForegroundColor Yellow
        $targetPort = Read-Host "Please enter your ESP32 COM port (e.g. COM16)"
    }
}

Write-Host "      Target Port: $targetPort" -ForegroundColor Green
Write-Host ""

# 4. Confirm and Flash
$bootloader = Join-Path $PSScriptRoot "bootloader.bin"
$partitions = Join-Path $PSScriptRoot "partition-table.bin"
$otaData    = Join-Path $PSScriptRoot "ota_data_initial.bin"
$firmware   = Join-Path $PSScriptRoot "esp32_nat_router.bin"

if (-not (Test-Path $firmware)) {
    Write-Host "ERROR: Firmware binaries not found in $PSScriptRoot!" -ForegroundColor Red
    exit 1
}

Write-Host "[4/4] Flashing Firmware..." -ForegroundColor Yellow
Write-Host "      1. Erasing flash memory (Full Factory Wipe)..." -ForegroundColor Gray
python -m esptool --chip esp32 --port $targetPort --baud 921600 erase-flash

Write-Host "      2. Writing fresh binaries..." -ForegroundColor Gray
python -m esptool --chip esp32 --port $targetPort --baud 921600 `
    --before default-reset --after hard-reset write-flash `
    -z --flash-mode dio --flash-freq 40m --flash-size detect `
    0x1000 "$bootloader" `
    0x8000 "$partitions" `
    0xf000 "$otaData" `
    0x20000 "$firmware"

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "       SUCCESS: ESP32 NAT Router Flashed Cleanly!       " -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Quick Setup:" -ForegroundColor Cyan
Write-Host " 1. Connect phone to Wi-Fi: ESP32_NAT_Router" -ForegroundColor White
Write-Host " 2. Open browser: http://192.168.4.1" -ForegroundColor White
Write-Host " 3. Lock Web UI: Set Admin Password at bottom of home screen" -ForegroundColor White
Write-Host " 4. Go to Configuration -> Set your Wi-Fi Name + WPA2 Password" -ForegroundColor White
Write-Host " 5. Tap WiFi Scan -> Connect to upstream Wi-Fi" -ForegroundColor White
Write-Host ""
