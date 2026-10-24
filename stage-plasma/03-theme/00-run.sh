#!/bin/bash -e
# Phase 3: light + dark global themes with a manual toggle.

# Wallpapers
install -d -m 755 "${ROOTFS_DIR}/usr/share/wallpapers"
install -m 644 files/wallpapers/*.png "${ROOTFS_DIR}/usr/share/wallpapers/"

# Global (look-and-feel) theme packages, system-wide
install -d -m 755 "${ROOTFS_DIR}/usr/share/plasma/look-and-feel"
cp -a files/lookandfeel/. "${ROOTFS_DIR}/usr/share/plasma/look-and-feel/"

# Toggle command + app-menu entry (shortcut Meta+Shift+T set in skel)
install -m 755 files/bin/theme-toggle "${ROOTFS_DIR}/usr/local/bin/theme-toggle"
install -m 644 files/bin/theme-toggle.desktop "${ROOTFS_DIR}/usr/share/applications/theme-toggle.desktop"

# Login screen: Breeze SDDM theme with our dark wallpaper
install -d -m 755 "${ROOTFS_DIR}/etc/sddm.conf.d"
install -m 644 files/sddm/20-theme.conf "${ROOTFS_DIR}/etc/sddm.conf.d/20-theme.conf"
install -d -m 755 "${ROOTFS_DIR}/usr/share/sddm/themes/breeze"
install -m 644 files/sddm/theme.conf.user "${ROOTFS_DIR}/usr/share/sddm/themes/breeze/theme.conf.user"

# Per-user defaults for every account created on the image
cp -a files/skel/. "${ROOTFS_DIR}/etc/skel/"

# The first user already exists by now, so copy the defaults into its home too
on_chroot <<CHROOT
cp -an /etc/skel/.config/. "/home/${FIRST_USER_NAME}/.config/" 2>/dev/null || true
chown -R "${FIRST_USER_NAME}:${FIRST_USER_NAME}" "/home/${FIRST_USER_NAME}/.config"
CHROOT
