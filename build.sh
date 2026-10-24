#!/bin/bash -e
# Build the pi5-plasma image. Same script for laptop and CI.
#
#   ./build.sh            incremental build (reuses earlier stages)
#   ./build.sh --clean    wipe pi-gen work dir and start over
#   VERSION=v0.2.0 ./build.sh   tag the output file name
cd "$(dirname "$0")"
PIGEN=pi-gen
VERSION=${VERSION:-$(git describe --tags --always --dirty 2>/dev/null || echo dev)}

if [ ! -f "$PIGEN/build-docker.sh" ]; then
	echo "pi-gen submodule missing. Run: git submodule update --init" >&2
	exit 1
fi

if [ "${1:-}" = "--clean" ]; then
	echo ">> cleaning pi-gen work and deploy dirs"
	docker rm -v pigen_work >/dev/null 2>&1 || true
	rm -rf "$PIGEN/work" "$PIGEN/deploy"
fi

echo ">> syncing stage-plasma and config into pi-gen"
rsync -a --delete stage-plasma/ "$PIGEN/stage-plasma/"
cp config "$PIGEN/config"
touch "$PIGEN/stage2/SKIP_IMAGES"      # export only our image, not Lite

echo ">> building ($VERSION)"
( cd "$PIGEN" && CONTINUE=1 PRESERVE_CONTAINER=1 ./build-docker.sh )

echo ">> collecting output"
mkdir -p out
for f in "$PIGEN"/deploy/*.img.xz; do
	cp "$f" "out/pi5-plasma-${VERSION}.img.xz"
done
sha256sum out/pi5-plasma-${VERSION}.img.xz | tee "out/pi5-plasma-${VERSION}.img.xz.sha256"
echo ">> done: out/pi5-plasma-${VERSION}.img.xz"
