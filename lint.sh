#!/bin/bash -e
# Fast checks that run before any 60-minute build: shell syntax, shellcheck,
# pi-gen stage layout, package list hygiene.
cd "$(dirname "$0")"
fail=0
echo ">> shell syntax"
for f in build.sh stage-plasma/prerun.sh stage-plasma/*/*.sh stage-plasma/*/files/pi5-bench stage-plasma/*/files/bin/theme-toggle; do
	[ -f "$f" ] && bash -n "$f"
done
if command -v shellcheck >/dev/null; then
	echo ">> shellcheck"
	shellcheck -S warning build.sh stage-plasma/*/*.sh || fail=1
fi
echo ">> stage layout"
[ -f stage-plasma/prerun.sh ] || { echo "missing prerun.sh"; fail=1; }
[ -f stage-plasma/EXPORT_IMAGE ] || { echo "missing EXPORT_IMAGE"; fail=1; }
for d in stage-plasma/[0-9][0-9]-*/; do
	ls "$d" | grep -qE '^(00-packages|00-packages-nr|[0-9]{2}-run(-chroot)?\.sh)$' \
		|| { echo "$d has no packages file or run script"; fail=1; }
done
echo ">> package lists: no blank/duplicate lines"
for p in stage-plasma/*/00-packages; do
	sort "$p" | uniq -d | grep . && { echo "duplicates in $p"; fail=1; } || true
	grep -n '^\s*$' "$p" && { echo "blank line in $p"; fail=1; } || true
done
grep -q '^STAGE_LIST=.*stage-plasma' config || { echo "config STAGE_LIST lacks stage-plasma"; fail=1; }
[ $fail -eq 0 ] && echo "lint ok"
exit $fail
