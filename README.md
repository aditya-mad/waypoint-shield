# WaypointShield 🛡️

> **Turn any $4 ESP32 into a pocket hardware firewall and isolated NAT router.**  
> Keep your smartphone and laptop completely invisible and unreachable on untrusted public Wi-Fi (cafes, airports, hotels).

---

## ⚡ How It Works

```text
[ Untrusted Public Wi-Fi ] (Cafe / Airport / Hotel)
             │
             ▼
   [ WaypointShield (ESP32) ]  <--- Hackers only see this microchip
             │ (Private WPA2 Channel)
             ▼
      [ Your Devices ]         <--- 100% Invisible on the public network
```

* **Invisible Identity:** The public network only sees the ESP32's MAC address. Your personal devices never send radio packets to the public router.
* **Hardware NAT Firewall:** The ESP32 creates an isolated subnet (`192.168.4.x`). Inbound network scans and unsolicited connection attempts are physically dropped.
* **Zero Broadcast Leaks:** Device names, AirDrop, and OS broadcast traffic stay contained inside your private network.

---

## 🚀 1-Click Installation (Zero Setup)

Everything needed to flash a fresh ESP32 is pre-packaged in this repository.

### Windows:
1. Connect your ESP32 via a **Micro-USB Data Cable**.
2. **Double-click `flash.bat`**.  
   *(The script auto-detects your COM port, wipes the flash, and installs the clean firmware in ~15 seconds).*

### macOS & Linux:
1. Connect your ESP32.
2. Run:
   ```bash
   chmod +x flash.sh && ./flash.sh
   ```

---

## ⚙️ Initial Setup (First Time Only)

1. **Connect:** Join the open Wi-Fi network: **`ESP32_NAT_Router`**
2. **Open Dashboard:** Open your browser and go to: **`http://192.168.4.1`**
3. **Lock the UI:** Scroll down to **"🔑 Set Password"** and set an **Admin Password**.  
   *(This locks the dashboard so no one else on the Wi-Fi can view or change your settings).*
4. **Secure Your Wi-Fi:** Tap **`⚙️ Configuration`** and under **Access Point Settings**:
   * Set your custom network name (e.g. `Waypoint-Aditya`).
   * Set your private password (min 8 characters).
   * Ensure **"Open (no password)"** is **un-checked** and security is set to **WPA2**.
   * Click **[ Save & Reboot ]**.
5. **Connect to Internet:** Reconnect your phone to your new encrypted network, go back to `192.168.4.1`, tap **`📡 WiFi Scan`**, and connect to your upstream Wi-Fi.

---

## ☕ Cafe Routine (15 Seconds)

Your private Wi-Fi name, WPA2 password, and Admin password are **permanently saved in hardware memory (NVS)**. When you visit a new cafe:

1. Power the ESP32 from a power bank or laptop.
2. Your phone connects to your private shield automatically.
3. Open `http://192.168.4.1` ➔ tap **`📡 WiFi Scan`** ➔ select the cafe Wi-Fi ➔ tap **Connect**.

---

### 📦 Repository Contents
* `flash.bat` / `flash.ps1` — 1-click Windows installer.
* `flash.sh` — 1-click macOS/Linux installer.
* `bootloader.bin`, `partition-table.bin`, `ota_data_initial.bin`, `esp32_nat_router.bin` — Pre-compiled, verified release binaries.

### Credits
Based on the open-source [martin-ger/esp32_nat_router](https://github.com/martin-ger/esp32_nat_router) project.
