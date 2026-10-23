#!/bin/sh
# Build and install the GNOME 51 stack from the gnome51 branch on a
# runit Void Linux system.
#
# Usage: ./install-gnome51.sh [-n] [-e] [-d dir]
#   -n      dry run: print the commands instead of running them
#   -e      enable gdm in /var/service, removing other display managers
#   -d dir  void-packages checkout to use or create (default: current
#           directory if it is one, else ./void-packages)
#
# Builds run as the calling user; installing uses sudo or doas.

set -eu

REPO=https://github.com/mendescotta/void-packages.git
BRANCH=gnome51

# Build order: each package only needs the ones before it.
PKGS="gsettings-desktop-schemas gnome-desktop gnome-settings-daemon mutter
 gnome-shell gnome-control-center gnome-session gdm xdg-desktop-portal-gnome
 gnome-shell-extensions adwaita-fonts adwaita-icon-theme gnome-backgrounds
 gnome-initial-setup gnome-keyring gnome-online-accounts gnome-core"

# Rebuilt for libgnome-desktop-3.so.21; built and updated only when installed.
# removed-packages uninstalls the packages that still need .so.20.
REBUILDS="cheese eog evince evolution gnome-panel totem libtotem
 xdg-desktop-portal-gtk openbox removed-packages"

DMS="lightdm sddm lxdm slim xdm emptty greetd"

dry=
enable=
dir=

while getopts ned: opt; do
	case $opt in
	n) dry=1 ;;
	e) enable=1 ;;
	d) dir=$OPTARG ;;
	*) sed -n '5,10s/^# \{0,1\}//p' "$0"; exit 1 ;;
	esac
done

run() {
	echo "+ $*"
	[ -n "$dry" ] || "$@"
}

if [ "$(id -u)" -eq 0 ]; then
	echo "Run this as a normal user; xbps-src refuses to build as root." >&2
	exit 1
fi

if command -v sudo >/dev/null; then
	asroot=sudo
elif command -v doas >/dev/null; then
	asroot=doas
else
	echo "Need sudo or doas to install packages." >&2
	exit 1
fi

for cmd in git xbps-install; do
	command -v "$cmd" >/dev/null || { echo "Missing $cmd." >&2; exit 1; }
done

if [ -z "$dir" ]; then
	if [ -x ./xbps-src ]; then dir=.; else dir=./void-packages; fi
fi

if [ -d "$dir/.git" ]; then
	run git -C "$dir" fetch "$REPO" "$BRANCH"
	run git -C "$dir" switch "$BRANCH" ||
		run git -C "$dir" switch -c "$BRANCH" FETCH_HEAD
	run git -C "$dir" merge --ff-only FETCH_HEAD
else
	run git clone --branch "$BRANCH" "$REPO" "$dir"
fi

run cd "$dir"
# xbps-src puts packages built on a branch other than master in their own repo.
repo=$PWD/hostdir/binpkgs/$BRANCH

[ -d masterdir ] || [ -d masterdir-x86_64 ] || run ./xbps-src binary-bootstrap
for pkg in $PKGS; do
	run ./xbps-src pkg "$pkg"
done
for pkg in $REBUILDS; do
	xbps-query "$pkg" >/dev/null 2>&1 && run ./xbps-src pkg "$pkg"
done

# gnome-core pulls in the rest; also update the packages already installed.
install="gnome-core gdm"
for pkg in $PKGS $REBUILDS; do
	case " $install " in *" $pkg "*) continue ;; esac
	xbps-query "$pkg" >/dev/null 2>&1 && install="$install $pkg"
done
# shellcheck disable=SC2086
run $asroot xbps-install -S --repository="$repo" $install

if [ -n "$enable" ]; then
	for dm in $DMS; do
		[ -L "/var/service/$dm" ] && run $asroot rm "/var/service/$dm"
	done
	[ -L /var/service/dbus ] || run $asroot ln -s /etc/sv/dbus /var/service/
	[ -L /var/service/gdm ] || run $asroot ln -s /etc/sv/gdm /var/service/
else
	cat <<-EOF

	Installed. To start GNOME at boot (the display manager starts at once):
	  $asroot ln -s /etc/sv/dbus /var/service/   # if not enabled yet
	  $asroot rm /var/service/<other display manager>
	  $asroot ln -s /etc/sv/gdm /var/service/
	EOF
fi
