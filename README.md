![Platform](https://img.shields.io/badge/platform-EndeavourOS-blueviolet)

# My EndeavourOS Setup (KDE + Hyprland)

Notes: This repo contains my personal configuration files for KDE Plasma and Hyprland on EndeavourOS. It’s primarily for backup, but feel free to use it if it’s helpful!

**Important:** The Hyprland configuration is *heavily inspired by* the [Hyde Project](https://github.com/HyDE-Project/HyDE). I’ve made minimal customizations so far.

---

# 🚀 QUICK START

### Install AUR Helper (Must)
```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si --noconfirm
cd ..
rm -rf paru-bin
```

### Clone the repo
```bash
git clone https://github.com/afif25fradana/personal-dual-de-ricing-endeavouros.git
cd personal-dual-de-ricing-endeavouros
```
### Activate Install
```bash
chmod +x Install-KDE.sh
```

---

### My KDE Ricing

### (optional) preview what will happen
```bash
./Install-KDE.sh --dry
```

### Run the installer
```bash
./Install-KDE.sh
```

---

## Screenshots

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/afif25fradana/dump-screenshot/blob/1688bdedbff7dc3a353633b5c605b54530b5452c/Login/GRUB.jpg" alt="GRUB Screenshot" width="100%">
      <br>
      <a href="https://github.com/vinceliuice/Elegant-grub2-themes" target="_blank">GRUB Theme</a>
    </td>
    <td align="center">
      <img src="https://github.com/afif25fradana/dump-screenshot/blob/1688bdedbff7dc3a353633b5c605b54530b5452c/Login/sddm_screenshot.png" alt="SDDM Screenshot" width="100%">
      <br>
      SDDM
    </td>
  </tr>
</table>

### Hyprland [Adaptation of the Hyde Project](https://github.com/HyDE-Project/HyDE)

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/afif25fradana/dump-screenshot/blob/1688bdedbff7dc3a353633b5c605b54530b5452c/Hyprland/250727_12h50m03s_screenshot.png" alt="Hyprland Screenshot 1" width="100%">
      <br>
      </td>
    <td align="center">
      <img src="https://github.com/afif25fradana/dump-screenshot/blob/1688bdedbff7dc3a353633b5c605b54530b5452c/Hyprland/250727_12h51m24s_screenshot.png" alt="Hyprland Screenshot 2" width="100%">
      <br>
      </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/afif25fradana/dump-screenshot/blob/1688bdedbff7dc3a353633b5c605b54530b5452c/Hyprland/250727_12h52m22s_screenshot.png" alt="Hyprland Screenshot 3" width="100%">
      <br>
      </td>
    <td align="center">
      <img src="https://github.com/afif25fradana/dump-screenshot/blob/1688bdedbff7dc3a353633b5c605b54530b5452c/Hyprland/250726_17h53m50s_screenshot.png" alt="Hyprland Screenshot 4" width="100%">
      <br>
      </td>
  </tr>
</table>

### KDE Plasma

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/afif25fradana/dump-screenshot/blob/1688bdedbff7dc3a353633b5c605b54530b5452c/KDE/Screenshot_20250729_222620.png" alt="KDE Screenshot 1" width="100%">
      <br>
      </td>
    <td align="center">
      <img src="https://github.com/afif25fradana/dump-screenshot/blob/1688bdedbff7dc3a353633b5c605b54530b5452c/KDE/Screenshot_20250731_092322.png" alt="KDE Screenshot 2" width="100%">
      <br>
      </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/afif25fradana/dump-screenshot/blob/1688bdedbff7dc3a353633b5c605b54530b5452c/KDE/Screenshot_20250731_093054.png" alt="KDE Screenshot 3" width="100%">
      <br>
      </td>
    <td align="center">
      <img src="https://github.com/afif25fradana/dump-screenshot/blob/1688bdedbff7dc3a353633b5c605b54530b5452c/KDE/Screenshot_20250731_093156.png" alt="KDE Screenshot 4" width="100%">
      <br>
      </td>
  </tr>
</table>

---

## 📖 Configuration Details
| Components        | Specifications        |
|-------------------|----------------------|
| **Distro**        | EndeavourOS          |
| **Kernel**        | Linux Zen            |
| **Main Desktop**  | KDE Plasma 6         |
| **Window Manager**| Hyprland             |
| **Login Manager** | SDDM                 |
| **Terminal**      | Kitty (Hyprland) & Konsole (KDE) |
| **Shell**         | Fish                 |

<br>

| Ricing       | KDE            | Hyprland                |
|--------------|----------------|-------------------------|
| **Theme**    | Sweet-Dark     | Hyde Project (default)  |
| **Icon**     | Papyrus        | Papyrus                 |
| **Bar**      | -              | Waybar (default from Hyde Project) |
| **Launcher** | -              | Wofi (default from Hyde Project)   |
| **Wallpaper**| [PURPLE NIGHT SKY 4K](https://steamcommunity.com/sharedfiles/filedetails/?id=3020093729) | [Wallhaven](https://wallhaven.cc) |
| **Additional Hyprland Notes** | - | The configuration still largely follows the *defaults from Hyde Project*. Personal customization may be minimal or not yet significant. |

---

## 💻 System Specifications (LENOVO V14-IIL Laptop)

This configuration was tested and ran optimally on my laptop with the following details:

| Components      | Specifications                      |
|-----------------|------------------------------------|
| **Laptop Model**| LENOVO V14-IIL (82C4)              |
| **CPU**         | Intel Core i5-1035G1 (Ice Lake-U, 4 Cores, 8 Threads) |
| **Graphics**    | Intel UHD Graphics (Ice Lake-U GT2)|
| **RAM**         | 12 GB DDR4 (8 GB SODIMM + 4 GB On-board) |
| **Storage**     | 512 GB NVMe SSD SKHynix            |
| **Screen**      | 14.0 inches, Full HD (1920x1080)   |
| **OS**          | Windows 11 (Dual-boot with EndeavourOS) |

## 🖥️ Dual Boot & Drive Info

This configuration works on a single 512 GB NVMe SSD drive used to dual-boot Windows 11 and EndeavourOS, plus dual desktop environments (KDE + Hyprland) on the Linux side.

It's safe to say that it's still possible to run a complex setup like this on a single drive, as long as the partitions are carefully organized from the start.

---

### 📦 Why I Make This Shit?

I constantly distro-hop or nuke my system while testing kernels.  
One `git clone` + `./Install-KDE.sh` gets me back to:
- Plasma 6 with Sweet-Dark, Papyrus icons, my transparent toolbar Kvantum theme  
- The exact same 4K night-sky live wallpaper (Smart-Video-Wallpaper-Reborn)
- Hyprland configs in under 30 seconds  
All without remembering 47 manual steps.

---

## 📜 Credits
- KDE theme: [Sweet](https://github.com/EliverLara/Sweet) by EliverLara
- Hyprland dotfiles: [Hyde Project](https://github.com/Hyde-project/hyde)
- GRUB theme: [Elegant](https://github.com/vinceliuice/Elegant-grub2-themes) by vinceliuice

No need to fork or star—this is just my personal backup! But if you find it useful, go for it! 😊
