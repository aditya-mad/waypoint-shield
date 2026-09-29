#!/usr/bin/env bash
# ESP32 NAT Router - 1-Click Flasher for Linux / macOS
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================================"
echo "       ESP32 Hardware Shield - Portable Flasher        "
echo "========================================================"
echo ""

# 1. Check Python
if ! command -v python3 &>/dev/null; then
    echo "ERROR: python3 not found. Please install Python 3."
    exit 1
fi

# 2. Check / Install esptool
if ! python3 -m esptool version &>/dev/null; then
    echo "[!] esptool not found. Installing via pip..."
    python3 -m pip install --upgrade esptool
fi

# 3. Detect Port
PORT="${1:-}"
if [ -z "$PORT" ]; then
    # Try finding typical Linux / Mac ports
    PORT=$(ls /dev/ttyUSB* /dev/ttyACM* /dev/cu.usbserial* /dev/cu.SLAB_USBtoUART* 2>/dev/null | head -n 1 || true)
fi

if [ -z "$PORT" ]; then
    echo "Could not auto-detect ESP32 serial port."
    read -p "Please enter serial port path (e.g. /dev/ttyUSB0 or /dev/cu.usbserial-0001): " PORT
fi

echo "[+] Using port: $PORT"
echo ""

# 4. Erase & Flash
echo "[+] Step 1: Erasing flash memory (Full Factory Wipe)..."
python3 -m esptool --chip esp32 --port "$PORT" --baud 921600 erase-flash

echo "[+] Step 2: Writing fresh binaries..."
python3 -m esptool --chip esp32 --port "$PORT" --baud 921600 \
    --before default-reset --after hard-reset write-flash \
    -z --flash-mode dio --flash-freq 40m --flash-size detect \
    0x1000 "$SCRIPT_DIR/bootloader.bin" \
    0x8000 "$SCRIPT_DIR/partition-table.bin" \
    0xf000 "$SCRIPT_DIR/ota_data_initial.bin" \
    0x20000 "$SCRIPT_DIR/esp32_nat_router.bin"

echo ""
echo "========================================================"
echo "       SUCCESS: ESP32 NAT Router Flashed Cleanly!       "
echo "========================================================"
echo ""
echo "Quick Setup:"
echo " 1. Connect phone to Wi-Fi: ESP32_NAT_Router"
echo " 2. Open browser: http://192.168.4.1"
echo " 3. Lock Web UI: Set Admin Password at bottom of home screen"
echo " 4. Go to Configuration -> Set your Wi-Fi Name + WPA2 Password"
echo " 5. Tap WiFi Scan -> Connect to upstream Wi-Fi"
echo ""
