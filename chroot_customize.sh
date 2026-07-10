#!/bin/bash
# Diesel Linux (Debian Edition) - Chroot Customization Script
# Runs INSIDE the chroot environment
set -e

# ── Basic mounts ──────────────────────────────────────────────────────────────
mount -t proc  none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts
export HOME=/root
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

echo "==> [diesel] Configuring APT sources (Debian 12 Bookworm)..."
cat > /etc/apt/sources.list <<'EOT'
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOT

apt-get update

# ── Core system ───────────────────────────────────────────────────────────────
echo "==> [diesel] Installing core system packages..."
apt-get install -y --no-install-recommends \
    systemd systemd-sysv dbus dbus-x11 \
    sudo locales tzdata \
    linux-image-amd64 \
    live-boot live-boot-initramfs-tools \
    initramfs-tools \
    network-manager \
    net-tools wireless-tools wpasupplicant \
    grub-common grub-pc grub-pc-bin grub2-common \
    grub-efi-amd64-signed shim-signed \
    mtools binutils \
    os-prober

# ── GNOME Desktop (lean selection for ~800 MB target) ─────────────────────────
echo "==> [diesel] Installing GNOME desktop environment..."
apt-get install -y --no-install-recommends \
    gnome-shell \
    gnome-session \
    gnome-terminal \
    gnome-control-center \
    gnome-tweaks \
    gnome-backgrounds \
    gnome-text-editor \
    nautilus \
    gdm3 \
    gvfs gvfs-backends \
    adwaita-icon-theme \
    fonts-dejavu-core \
    fonts-liberation \
    xdg-utils \
    xdg-user-dirs \
    pulseaudio \
    pipewire pipewire-pulse \
    libgl1 libgles2 libglx-mesa0 \
    mesa-utils \
    x11-xserver-utils \
    xwayland

# ── Developer tools (from diesel-linux core_packages.list) ───────────────────
echo "==> [diesel] Installing developer tools..."
apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    wget \
    vim \
    nano \
    less \
    python3 \
    python3-pip \
    nodejs \
    npm \
    docker.io \
    docker-compose \
    zram-tools \
    htop \
    unzip \
    zip \
    ca-certificates \
    gnupg \
    lsb-release

# ── Locale & timezone ─────────────────────────────────────────────────────────
echo "==> [diesel] Configuring locale..."
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8

# ── Hostname ──────────────────────────────────────────────────────────────────
echo "diesel-linux" > /etc/hostname
cat > /etc/hosts <<'EOT'
127.0.0.1   localhost
127.0.1.1   diesel-linux
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOT

# ── Default live user ─────────────────────────────────────────────────────────
echo "==> [diesel] Creating live user..."
useradd -m -s /bin/bash -G sudo,docker diesel || true
echo "diesel:diesel" | chpasswd
echo "root:diesel" | chpasswd

# ── Diesel Linux Branding & Theming ──────────────────────────────────────────
echo "==> [diesel] Applying Diesel Linux branding..."

# Wallpaper
mkdir -p /usr/share/backgrounds/diesel-linux
cp /tmp/diesel_wallpaper.png /usr/share/backgrounds/diesel-linux/default_wallpaper.png

# Set GNOME default wallpaper via dconf profile
mkdir -p /etc/dconf/db/local.d
cat > /etc/dconf/db/local.d/00-diesel-branding <<'EOT'
[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/diesel-linux/default_wallpaper.png'
picture-uri-dark='file:///usr/share/backgrounds/diesel-linux/default_wallpaper.png'
picture-options='zoom'

[org/gnome/desktop/interface]
color-scheme='prefer-dark'
gtk-theme='Adwaita-dark'
icon-theme='Adwaita'

[org/gnome/desktop/screensaver]
picture-uri='file:///usr/share/backgrounds/diesel-linux/default_wallpaper.png'
EOT

mkdir -p /etc/dconf/profile
cat > /etc/dconf/profile/user <<'EOT'
user-db:user
system-db:local
EOT

# Apply dconf
dconf update || true

# Plymouth boot message
echo "Diesel Linux - Ignition" > /etc/issue
echo "Diesel Linux 1.0 Ignition (Debian Edition)" > /etc/issue.net

# OS release branding
cat > /etc/os-release <<'EOT'
PRETTY_NAME="Diesel Linux 1.0 Ignition (Debian Edition)"
NAME="Diesel Linux"
VERSION_ID="1.0"
VERSION="1.0 (Ignition)"
ID=diesel
ID_LIKE=debian
HOME_URL="https://github.com/oh-okay/diesel-linux"
SUPPORT_URL="https://github.com/oh-okay/diesel-linux/issues"
BUG_REPORT_URL="https://github.com/oh-okay/diesel-linux/issues"
EOT

# Custom terminal prompt for all new users
cat >> /etc/skel/.bashrc <<'EOT'

# Diesel Linux Custom Prompt
export PS1="\[\033[01;34m\]diesel\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]\$ "
EOT

# Also apply to root
cat >> /root/.bashrc <<'EOT'

# Diesel Linux Custom Prompt
export PS1="\[\033[01;31m\]diesel-root\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]# "
EOT

# ── Performance Optimizations (from diesel-linux optboot.sh) ─────────────────
echo "==> [diesel] Applying boot and performance optimizations..."

# Kernel parameter tweaks
cat >> /etc/sysctl.conf <<'EOT'

# Diesel Linux Performance Tweaks
vm.swappiness=10
vm.vfs_cache_pressure=50
net.core.rmem_max=16777216
net.core.wmem_max=16777216
EOT

# Journald cap
sed -i 's/#SystemMaxUse=/SystemMaxUse=50M/' /etc/systemd/journald.conf || \
    echo "SystemMaxUse=50M" >> /etc/systemd/journald.conf

# GRUB timeout
mkdir -p /etc/default
cat > /etc/default/grub <<'EOT'
GRUB_DEFAULT=0
GRUB_TIMEOUT=2
GRUB_DISTRIBUTOR="Diesel Linux"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
EOT

# Disable unnecessary services (best-effort, may not exist in live env)
for svc in bluetooth.service cups.service avahi-daemon.service NetworkManager-wait-online.service; do
    systemctl disable "$svc" 2>/dev/null || true
done

# Enable GDM (GNOME display manager)
systemctl enable gdm3 || systemctl enable gdm || true
systemctl enable NetworkManager || true

# ── Machine ID ────────────────────────────────────────────────────────────────
dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id

# ── Cleanup ───────────────────────────────────────────────────────────────────
echo "==> [diesel] Cleaning up..."
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*

# ── Unmount ───────────────────────────────────────────────────────────────────
umount /proc    || true
umount /sys     || true
umount /dev/pts || true

echo "==> [diesel] Chroot customization complete!"
