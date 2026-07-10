# Diesel Linux 1.0 "Ignition" — Debian Edition (GNOME)

![Diesel Linux](https://raw.githubusercontent.com/oh-okay/Diesel-Linux/main/diesel_linux_logo.png)

## Overview

**Diesel Linux 1.0 "Ignition" — Debian Edition** is a custom live OS image built from the [oh-okay/diesel-linux](https://github.com/oh-okay/diesel-linux) project, ported from its original Ubuntu/XFCE base to a pure **Debian 12 Bookworm** foundation with the **GNOME** desktop environment.

It retains all diesel-linux branding, performance optimizations, and developer tooling while targeting a compact ~800 MB ISO footprint.

---

## ISO Details

| Property         | Value                                                       |
|------------------|-------------------------------------------------------------|
| **Filename**     | `diesel-linux-1.0-ignition-debian-gnome-amd64.iso`         |
| **Size**         | ~778 MB                                                     |
| **Base OS**      | Debian 12 Bookworm (amd64)                                  |
| **Desktop**      | GNOME (gnome-shell + GDM3)                                  |
| **Kernel**       | Linux 6.1.0-50-amd64                                        |
| **Boot type**    | BIOS + UEFI hybrid (grub-mkrescue)                          |
| **MD5**          | `45f85d9b0c82ef3c6ea58c41bd27bfff`                          |
| **SHA-256**      | `c0a6a14c658e45de67709f3d30367a79473ebafbc6afc54e75ddb6b4afd60d57` |

---

## What's Included

### Desktop Environment
- **GNOME Shell** with GDM3 display manager
- Dark mode enabled by default (`prefer-dark` color scheme)
- Adwaita-dark GTK theme
- Nautilus file manager, GNOME Terminal, GNOME Text Editor, GNOME Control Center, GNOME Tweaks
- PipeWire + PulseAudio for audio
- Wayland + XWayland support

### Diesel Linux Branding
- Custom wallpaper from the diesel-linux repo set as GNOME default background
- Custom bash prompt: `diesel:/path/to/dir$` (blue/green)
- `/etc/os-release` identifies as **Diesel Linux 1.0 Ignition**
- Boot message: "Diesel Linux - Ignition"

### Developer Tools (from `core_packages.list`)
- `git`, `build-essential`, `curl`, `wget`
- `vim`, `nano`, `less`
- `python3`, `python3-pip`
- `nodejs`, `npm`
- `docker.io`, `docker-compose`
- `htop`, `unzip`, `zip`

### Performance Optimizations (from `optboot.sh`)
- `vm.swappiness=10`, `vm.vfs_cache_pressure=50`
- `net.core.rmem_max` / `wmem_max` = 16 MB
- `systemd-journald` capped at 50 MB
- GRUB timeout = 2 seconds
- Disabled: `bluetooth`, `cups`, `avahi-daemon`, `NetworkManager-wait-online`
- zRAM tools installed

---

## Live Session Credentials

| Account  | Password |
|----------|----------|
| `diesel` | `diesel` |
| `root`   | `diesel` |

The `diesel` user is a member of `sudo` and `docker` groups.

---

## How to Use

### Write to USB (Linux)
```bash
sudo dd if=diesel-linux-1.0-ignition-debian-gnome-amd64.iso \
         of=/dev/sdX bs=4M status=progress oflag=sync
```
Replace `/dev/sdX` with your USB drive (e.g. `/dev/sdb`).

### Write to USB (Windows)
Use [Rufus](https://rufus.ie) or [balenaEtcher](https://etcher.balena.io) in **DD mode**.

### Run in a VM
Compatible with QEMU/KVM, VirtualBox, and VMware. Select the ISO as a bootable CD-ROM. Allocate at least:
- **RAM:** 2 GB (4 GB recommended for GNOME)
- **Disk:** 20 GB (for persistent install)
- **CPU:** 2 cores

### QEMU quick test
```bash
qemu-system-x86_64 \
  -m 4G \
  -cdrom diesel-linux-1.0-ignition-debian-gnome-amd64.iso \
  -boot d \
  -enable-kvm \
  -vga virtio
```

---

## Boot Menu Options

| Entry | Description |
|-------|-------------|
| **Diesel Linux 1.0 Ignition (Live)** | Normal live boot with splash |
| **Diesel Linux 1.0 Ignition (Safe Graphics)** | `nomodeset` for compatibility with older GPUs |
| **Diesel Linux 1.0 Ignition (Debug)** | Verbose boot, no splash |

---

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 64-bit (x86_64) | 2+ cores |
| RAM | 2 GB | 4 GB |
| Disk | 20 GB | 50 GB |
| GPU | Any with KMS | Mesa/virtio |

---

## Source & Credits

- **Original project:** [oh-okay/diesel-linux](https://github.com/oh-okay/diesel-linux)
- **Base OS:** [Debian 12 Bookworm](https://www.debian.org)
- **Desktop:** [GNOME](https://www.gnome.org)
- Build scripts and configuration adapted from the upstream diesel-linux repository.
