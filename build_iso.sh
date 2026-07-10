#!/bin/bash
# Diesel Linux (Debian Edition) - ISO Build Script
# Builds a bootable ~800MB live ISO with GNOME desktop
set -e

# ── Configuration ─────────────────────────────────────────────────────────────
PROJECT_DIR="/home/ubuntu/diesel-linux-gnome"
CHROOT_DIR="${PROJECT_DIR}/chroot"
IMAGE_DIR="${PROJECT_DIR}/image"
ISO_NAME="diesel-linux-1.0-ignition-debian-gnome-amd64.iso"
DEBIAN_MIRROR="http://deb.debian.org/debian"
DEBIAN_RELEASE="bookworm"

log() { echo -e "\e[32m[BUILD]\e[0m $1"; }
warn() { echo -e "\e[33m[WARN]\e[0m $1"; }
err()  { echo -e "\e[31m[ERROR]\e[0m $1"; exit 1; }

# Must run as root
[ "$EUID" -eq 0 ] || err "Run as root: sudo bash build_iso.sh"

log "=== Diesel Linux (Debian + GNOME) ISO Builder ==="
log "Target: ~800 MB live ISO | Base: Debian 12 Bookworm | DE: GNOME"

# ── Step 1: Bootstrap Debian ──────────────────────────────────────────────────
if [ -d "${CHROOT_DIR}/bin" ]; then
    log "Chroot already exists, skipping debootstrap..."
else
    log "Step 1/8: Bootstrapping Debian ${DEBIAN_RELEASE} (minbase)..."
    mkdir -p "${CHROOT_DIR}"
    debootstrap --arch=amd64 --variant=minbase \
        "${DEBIAN_RELEASE}" "${CHROOT_DIR}" "${DEBIAN_MIRROR}"
    log "Debootstrap complete."
fi

# ── Step 2: Bind mounts ───────────────────────────────────────────────────────
log "Step 2/8: Mounting bind filesystems..."
mount --bind /dev "${CHROOT_DIR}/dev"
mount --bind /run "${CHROOT_DIR}/run"

# ── Step 3: Copy assets into chroot ──────────────────────────────────────────
log "Step 3/8: Copying assets and scripts into chroot..."
cp "${PROJECT_DIR}/assets/diesel_wallpaper.png" "${CHROOT_DIR}/tmp/diesel_wallpaper.png"
cp "${PROJECT_DIR}/scripts/chroot_customize.sh" "${CHROOT_DIR}/tmp/chroot_customize.sh"
chmod +x "${CHROOT_DIR}/tmp/chroot_customize.sh"

# ── Step 4: Run customization inside chroot ───────────────────────────────────
log "Step 4/8: Running chroot customization (this takes ~10-20 min)..."
chroot "${CHROOT_DIR}" /bin/bash /tmp/chroot_customize.sh

# ── Step 5: Unmount bind mounts ───────────────────────────────────────────────
log "Step 5/8: Unmounting bind filesystems..."
umount "${CHROOT_DIR}/dev" || true
umount "${CHROOT_DIR}/run" || true

# ── Step 6: Prepare image directory ──────────────────────────────────────────
log "Step 6/8: Preparing ISO image directory..."
rm -rf "${IMAGE_DIR}"
mkdir -p "${IMAGE_DIR}"/{casper,boot/grub,isolinux,.disk}

# Copy kernel and initrd
VMLINUZ=$(ls "${CHROOT_DIR}/boot/vmlinuz-"* 2>/dev/null | sort -V | tail -n1)
INITRD=$(ls  "${CHROOT_DIR}/boot/initrd.img-"* 2>/dev/null | sort -V | tail -n1)

[ -n "${VMLINUZ}" ] || err "No kernel found in chroot/boot/"
[ -n "${INITRD}"  ] || err "No initrd found in chroot/boot/"

log "  Kernel : ${VMLINUZ}"
log "  Initrd : ${INITRD}"
cp "${VMLINUZ}" "${IMAGE_DIR}/casper/vmlinuz"
cp "${INITRD}"  "${IMAGE_DIR}/casper/initrd"

# Disk info
echo "Diesel Linux 1.0 Ignition (Debian Edition)" > "${IMAGE_DIR}/.disk/info"
touch "${IMAGE_DIR}/.disk/base_installable"

# ── Step 7: Create SquashFS ───────────────────────────────────────────────────
log "Step 7/8: Creating SquashFS (xz compression — may take 10-30 min)..."
mksquashfs "${CHROOT_DIR}" "${IMAGE_DIR}/casper/filesystem.squashfs" \
    -comp xz -Xbcj x86 \
    -e boot \
    -noappend \
    -wildcards \
    -ef /dev/null

SQUASH_SIZE=$(du -sh "${IMAGE_DIR}/casper/filesystem.squashfs" | cut -f1)
log "  SquashFS size: ${SQUASH_SIZE}"

# Filesystem size manifest
printf $(du -sx --block-size=1 "${CHROOT_DIR}" | cut -f1) > "${IMAGE_DIR}/casper/filesystem.size"

# ── Step 8: GRUB bootloader config ───────────────────────────────────────────
log "Step 8/8: Writing GRUB configuration..."
cat > "${IMAGE_DIR}/boot/grub/grub.cfg" <<'GRUBEOF'
set default="0"
set timeout=5

insmod all_video
insmod gfxterm
set gfxmode=auto
terminal_output gfxterm

menuentry "Diesel Linux 1.0 Ignition (Live)" --class diesel --class gnu-linux {
    linux  /casper/vmlinuz boot=live quiet splash ---
    initrd /casper/initrd
}

menuentry "Diesel Linux 1.0 Ignition (Safe Graphics)" --class diesel {
    linux  /casper/vmlinuz boot=live nomodeset quiet splash ---
    initrd /casper/initrd
}

menuentry "Diesel Linux 1.0 Ignition (Debug / noquiet)" --class diesel {
    linux  /casper/vmlinuz boot=live ---
    initrd /casper/initrd
}
GRUBEOF

# ── Generate ISO ──────────────────────────────────────────────────────────────
log "Generating bootable ISO: ${ISO_NAME}..."
grub-mkrescue \
    --output="${PROJECT_DIR}/${ISO_NAME}" \
    "${IMAGE_DIR}" \
    -- -V "DIESEL_LINUX" \
    2>&1 | grep -v "^$" || true

ISO_PATH="${PROJECT_DIR}/${ISO_NAME}"
if [ -f "${ISO_PATH}" ]; then
    ISO_SIZE=$(du -sh "${ISO_PATH}" | cut -f1)
    log "======================================================"
    log "  ISO created successfully!"
    log "  Path : ${ISO_PATH}"
    log "  Size : ${ISO_SIZE}"
    log "======================================================"
else
    err "ISO generation failed — file not found at ${ISO_PATH}"
fi
