#!/bin/bash -e
# Runs on the build host with ${ROOTFS_DIR} = the image root.
# Anything that must run *inside* the image goes through on_chroot.

# Make SDDM the display manager and force the Wayland session
on_chroot <<CHROOT
systemctl set-default graphical.target
systemctl enable sddm
CHROOT

install -d -m 755 "${ROOTFS_DIR}/etc/sddm.conf.d"
cat > "${ROOTFS_DIR}/etc/sddm.conf.d/10-wayland.conf" <<'CONF'
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1
SessionDir=/usr/share/wayland-sessions
CONF

# Pi OS Lite installs a text-mode autologin unit; remove it so SDDM owns tty1
rm -f "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/autologin.conf"

# First user gets the groups a desktop session needs
on_chroot <<CHROOT
for g in video render input audio bluetooth netdev plugdev; do
	getent group \$g >/dev/null && adduser "${FIRST_USER_NAME}" \$g || true
done
CHROOT
