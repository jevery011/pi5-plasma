#!/bin/bash -e
# Claude Code from Anthropic's signed apt repo, so it updates with `apt upgrade`
# alongside everything else in the image. Login happens on first run (Pro/Max/API).

install -d -m 755 "${ROOTFS_DIR}/etc/apt/keyrings"
curl -fsSL https://downloads.claude.ai/keys/claude-code.asc \
	-o "${ROOTFS_DIR}/etc/apt/keyrings/claude-code.asc"

# Fail the build if the key is not the one Anthropic publishes
FPR=$(gpg --show-keys --with-colons "${ROOTFS_DIR}/etc/apt/keyrings/claude-code.asc" \
	| awk -F: '/^fpr/{print $10; exit}')
if [ "${FPR}" != "31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE" ]; then
	echo "Claude Code signing key fingerprint mismatch: ${FPR}" >&2
	exit 1
fi

echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/stable stable main" \
	> "${ROOTFS_DIR}/etc/apt/sources.list.d/claude-code.list"

on_chroot <<CHROOT
apt-get update
apt-get install -y claude-code git ripgrep
CHROOT

# Desktop launcher: opens Konsole in ~/Projects and starts Claude Code
install -m 644 files/claude-code.desktop "${ROOTFS_DIR}/usr/share/applications/claude-code.desktop"
install -d -m 755 "${ROOTFS_DIR}/etc/skel/Projects"
