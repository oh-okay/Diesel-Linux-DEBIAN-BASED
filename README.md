# Diesel Linux 1.0 "Ignition"

## (Download)[https://github.com/oh-okay/Diesel-Linux-DEBIAN-BASED/releases/tag/Debian-DL-1.0]


![Diesel Linux Logo](https://raw.githubusercontent.com/oh-okay/Diesel-Linux/main/diesel_linux_logo.png)

Diesel Linux is a lightweight, developer-focused Linux distribution unlike the old Ubuntu based version, this one is based on Debian 12 (Bookworm). It ships with GNOME, sensible performance tweaks, and a collection of development tools so you can get to work immediately.

This release is the first public version of Diesel Linux.

---

## Download

**File**

`diesel-linux-1.0-ignition-debian-gnome-amd64.iso`

**Size**

778 MB

### Checksums

**MD5**

```
45f85d9b0c82ef3c6ea58c41bd27bfff
```

**SHA-256**

```
c0a6a14c658e45de67709f3d30367a79473ebafbc6afc54e75ddb6b4afd60d57
```

---

## What's Included

### Base System

* Debian 12 "Bookworm"
* Built using a minimal `debootstrap` installation
* 64-bit (AMD64)

### Desktop Environment

* GNOME Shell
* GDM3 display manager
* Adwaita Dark enabled by default
* Custom Diesel Linux wallpaper

### Customizations

* Custom Bash prompt
* Customized `/etc/os-release`
* Diesel Linux branding

### Development Tools

The following tools are installed by default:

* Git
* Build Essentials (GCC, Make, etc.)
* Python 3
* Node.js
* npm
* Docker
* Docker Compose
* Vim
* Curl

---

## Performance Tweaks

Diesel Linux includes a few small changes to improve responsiveness without sacrificing stability.

* `vm.swappiness` set to `10`
* System journal limited to 50 MB
* GRUB boot timeout reduced to 2 seconds
* Bluetooth disabled by default
* CUPS disabled by default
* Avahi disabled by default
* ZRAM enabled

---

## Boot Support

The ISO supports both modern and older systems.

* UEFI
* Legacy BIOS
* Hybrid boot image

---

## Live Session

Username:

```
diesel
```

Password:

```
diesel
```

The default user has access to both the `sudo` and `docker` groups.

---

## Writing the ISO to a USB Drive

### Linux

```bash
sudo dd if=diesel-linux-1.0-ignition-debian-gnome-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Replace `/dev/sdX` with the correct USB device before running the command.

### Windows

You can flash the ISO using:

* Rufus
* balenaEtcher

If prompted, choose **DD Mode**.

---

## Testing with QEMU

```bash
qemu-system-x86_64 -m 4G -cdrom diesel-linux-1.0-ignition-debian-gnome-amd64.iso -boot d
```

---

## System Information

| Component       | Version              |
| --------------- | -------------------- |
| Distribution    | Debian 12 Bookworm   |
| Kernel          | Linux 6.1.0-50-amd64 |
| Desktop         | GNOME Shell          |
| Display Manager | GDM3                 |
| Theme           | Adwaita Dark         |
| Architecture    | AMD64                |
| Boot            | UEFI + Legacy BIOS   |
| ISO Size        | 778 MB               |

---

## About the Project

Diesel Linux aims to provide a clean Debian-based desktop that is lightweight, practical, and ready for development out of the box. Instead of adding unnecessary software, the focus is on providing a solid base with useful developer tools and a polished GNOME experience.

As the project grows, future releases will continue to improve performance, usability, and hardware support while keeping the system simple and reliable.
