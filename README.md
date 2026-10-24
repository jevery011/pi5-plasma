# pi5-plasma

Custom Raspberry Pi 5 desktop image: Debian Trixie + KDE Plasma 6 (Wayland), built with pi-gen.

## Layout

```
pi-gen/          git submodule, pinned (arm64 branch)
stage-plasma/    everything we add on top of Pi OS Lite
config           pi-gen settings
build.sh         builds the image, locally or in CI
lint.sh          fast checks, runs before every build
.github/         Actions workflow: lint on PRs, build on main/tags, release on tags
```

## First-time setup

```bash
git clone <your-repo-url> pi5-plasma
cd pi5-plasma
git submodule add -b arm64 https://github.com/RPi-Distro/pi-gen.git pi-gen
git submodule update --init
```

Edit `config`: set `FIRST_USER_PASS`, `TIMEZONE_DEFAULT`.

## Build locally

Needs Docker (rootful) and, on x86 hosts, `qemu-user-static binfmt-support`.

```bash
./lint.sh
./build.sh              # ~45-90 min first time, faster afterwards
./build.sh --clean      # start from scratch
ls out/
```

## Build in GitHub Actions

Push to `main` → lint + build, image attached as a workflow artifact (14 days).
Push a tag → same, plus a GitHub Release with the `.img.xz` and checksum:

```bash
git tag v0.1.0 && git push --tags
```

## Flash

Raspberry Pi Imager → Use custom → `out/pi5-plasma-*.img.xz` → NVMe.
Set EEPROM boot order to NVMe first: `sudo rpi-eeprom-config --edit` → `BOOT_ORDER=0xf416`.

## First boot checks

`pi5-bench` logs boot time, idle RAM and service count. `Meta+Shift+T` flips light/dark. `claude` starts Claude Code (needs a Pro/Max/Team plan or API key).
