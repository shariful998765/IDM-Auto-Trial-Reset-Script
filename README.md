<h1 align="center">idm_auto_trial_reset</h1>

<p align="center">
<!-- 	<a href="https://github.com/shariful998765/IDM-Auto-Trial-Reset-Script/releases"><img src="https://img.shields.io/github/v/release/shariful998765/IDM-Auto-Trial-Reset-Script?style=flat-square&include_prereleases&label=version" /></a> -->
<!-- 	<a href="https://github.com/shariful998765/IDM-Auto-Trial-Reset-Script/releases"><img src="https://img.shields.io/github/downloads/shariful998765/IDM-Auto-Trial-Reset-Script/total.svg?style=flat-square" /></a> -->
	<a href="https://github.com/shariful998765/IDM-Auto-Trial-Reset-Script/issues"><img src="https://img.shields.io/github/issues-raw/shariful998765/IDM-Auto-Trial-Reset-Script.svg?style=flat-square&label=issues" /></a>
	<a href="https://github.com/shariful998765/IDM-Auto-Trial-Reset-Script/graphs/contributors"><img src="https://img.shields.io/github/contributors/shariful998765/IDM-Auto-Trial-Reset-Script?style=flat-square" /></a>
	<a href="https://github.com/shariful998765/IDM-Auto-Trial-Reset-Script/blob/master/LICENSE"><img src="https://img.shields.io/github/license/shariful998765/IDM-Auto-Trial-Reset-Script?style=flat-square" /></a>
</p>

# IDM Script Suite

This repository contains batch scripts designed to interact with **Internet Download Manager (IDM)** for testing and learning purposes only.

---

## 🔧 Script Included

### 1. **IDM Auto Reset Script**
Automatically resets the trial period of Internet Download Manager by:
- Deleting registry entries related to license/trial tracking
- Removing AppData configurations
- Running silently in the background
- Adding itself to startup for persistent execution

### 2. **IDM Remover Script**
A simple cleanup tool that:
- Stops any running IDM process
- Deletes registry keys associated with IDM
- Removes IDM folders from AppData
- Helps fully uninstall IDM without leftovers

> ⚠️ These tools are meant for educational use, such as understanding how software licensing and system configuration work. They are not intended for bypassing software licenses or violating EULAs.

---

## 🧪 How to Use

### ✅ For `idm_auto_trial_reset.bat`

1. Double-click on `idm_auto_trial_reset.bat`
2. The script will:
   - Run in the background silently
   - Automatically reset IDM trial when needed
   - Add itself to Windows startup (only once)
3. That's it — no further action required!

> 🕒 The script resets the trial every 5 minutes if IDM is closed. Just let it run and IDM will always start as a fresh trial version.

---

### 🧹 For `idm_auto_trial_reset_remover.bat`

If you no longer want the auto-reset behavior:

1. Run `idm_auto_trial_reset_remover.bat` as Administrator
2. It will:
   - Stop the IDM process
   - Remove all traces of IDM (registry + files)
   - Remove the auto-reset script from startup

> 💡 This is useful if you decide to buy IDM and want to clean up before installing the licensed version.

---

## ⚠️ Disclaimer

These scripts are provided **"as is"**, without warranty of any kind, express or implied. Use them at your own risk.

### 🛑 Do NOT use these scripts to:
- Circumvent software licensing systems
- Bypass time-limited trials for commercial use
- Distribute or share cracked versions of IDM

The authors are not responsible for any misuse or damage caused by this software.

---

## 💡 Educational Purposes Only

This project was created strictly for **educational and testing purposes**, to understand:
- How Windows registry and batch scripting work
- How applications like IDM store license data
- How to automate basic system tasks using `.bat` files

---

## ✅ Official Recommendation

If you find **Internet Download Manager useful**, please support its development by purchasing a legitimate license from the official website:

🔗 [Internet Download Manager ](https://www.internetdownloadmanager.com )

Buying the software ensures:
- You receive updates and support
- The developers get proper credit and compensation
- You remain compliant with the software’s End User License Agreement (EULA)

---

## 📁 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
