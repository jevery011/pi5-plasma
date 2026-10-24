#!/bin/bash -e
# Phase 4: make the image idle lighter and boot quicker than stock Pi OS Desktop.
# Everything here is a file drop or a systemctl call, so it is reproducible.

# --- Memory: zram swap instead of Pi OS's swap file on the SSD ---
install -m 644 files/zram-generator.conf "${ROOTFS_DIR}/etc/systemd/zram-generator.conf"
install -m 644 files/90-pi5-tune.conf "${ROOTFS_DIR}/etc/sysctl.d/90-pi5-tune.conf"
on_chroot <<CHROOT
if dpkg -s dphys-swapfile >/dev/null 2>&1; then
	systemctl disable dphys-swapfile.service || true
	apt-get purge -y dphys-swapfile
fi
CHROOT

# --- Logging: cap the journal so it never balloons on a small root ---
install -d -m 755 "${ROOTFS_DIR}/etc/systemd/journald.conf.d"
install -m 644 files/journald-size.conf "${ROOTFS_DIR}/etc/systemd/journald.conf.d/size.conf"

# --- Services we do not need on a desktop Pi ---
on_chroot <<CHROOT
for s in ModemManager.service triggerhappy.service avahi-daemon.service apt-daily.timer apt-daily-upgrade.timer; do
	systemctl disable "\$s" 2>/dev/null || true
done
# Plasma pulls these in via recommends; they only matter on laptops / with PIM apps
apt-get purge -y akonadi-server kwalletmanager 2>/dev/null || true
apt-get autoremove -y
CHROOT

# --- Quiet, fast boot ---
sed -i 's/ console=tty1//; s/$/ quiet loglevel=3/' "${ROOTFS_DIR}/boot/firmware/cmdline.txt"

# --- Firmware config: uncomment the pciex1_gen line to test NVMe Gen 3 (unofficial) ---
cat >> "${ROOTFS_DIR}/boot/firmware/config.txt" <<'CFG'

# --- pi5-plasma tuning ---
# Faster NVMe (PCIe Gen 3). Unofficial; comment out if you see I/O errors.
#dtparam=pciex1_gen=3
# GPU memory for 4K desktop
gpu_mem=256
CFG

# --- Benchmark helper for before/after numbers ---
install -m 755 files/pi5-bench "${ROOTFS_DIR}/usr/local/bin/pi5-bench"
