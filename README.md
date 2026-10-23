# GNOME 51 on Void Linux (runit)

This is the `gnome51` branch of
[mendescotta/void-packages](https://github.com/mendescotta/void-packages). It
brings GNOME 51 to stock Void Linux, which runs runit and elogind and has no
systemd. The goal is a minimal patchset against Void's `master` that can go
upstream. There are no personal changes: no GTK3 splits, no slimmed
`gnome-core`, no dropped dependencies. Builds run on Void's toolchain and
platform libraries, with gtk4 4.22, glib 2.88, accountsservice 23 and
elogind 252. It builds on
[void-linux/void-packages#59394](https://github.com/void-linux/void-packages/pull/59394)
("[WIP] GNOME 50").

Void's own build documentation is in [Manual.md](./Manual.md) and
[CONTRIBUTING.md](./CONTRIBUTING.md).

## Install

The branch is not in any binary repository. You build it with `xbps-src`
and install from the local repository it creates.

### With the script

As a normal user (not root), with `sudo` or `doas` available:

```sh
git clone --branch gnome51 https://github.com/mendescotta/void-packages.git
cd void-packages
./install-gnome51.sh        # build and install
./install-gnome51.sh -e     # the same, then enable gdm (replaces other display managers)
./install-gnome51.sh -n     # dry run: print the commands only
```

The script bootstraps `xbps-src` if needed and builds the GNOME 51 packages in
dependency order. It also rebuilds the installed packages that link
`libgnome-desktop-3` (evince, eog, cheese, totem, evolution, gnome-panel,
xdg-desktop-portal-gtk), plus `openbox` and `removed-packages`. It then
installs `gnome-core` and `gdm` from `hostdir/binpkgs/gnome51`. Run it again
to pull and rebuild after the branch changes.

### By hand

```sh
./xbps-src binary-bootstrap
for p in gsettings-desktop-schemas gnome-desktop gnome-settings-daemon mutter \
	gnome-shell gnome-control-center gnome-session gdm xdg-desktop-portal-gnome \
	gnome-shell-extensions adwaita-fonts adwaita-icon-theme gnome-backgrounds \
	gnome-initial-setup gnome-keyring gnome-online-accounts gnome-core; do
	./xbps-src pkg $p || break
done
# plus any of these that are installed: cheese eog evince evolution gnome-panel
# totem xdg-desktop-portal-gtk openbox removed-packages
sudo xbps-install -S --repository=hostdir/binpkgs/gnome51 gnome-core gdm
```

xbps-src puts packages built on a branch other than `master` in
`hostdir/binpkgs/<branch>`.

### Enable it

```sh
sudo ln -s /etc/sv/dbus /var/service/    # if not enabled yet
sudo rm /var/service/<other display manager>
sudo ln -s /etc/sv/gdm /var/service/     # starts the greeter at once
```

A GPU driver (`mesa-dri` or the NVIDIA driver) has to be installed, as the
Void handbook describes. Sound needs PipeWire, set up as the handbook
describes.

### Things to watch for

- Budgie, gnome-flashback and gnome-screensaver are removed on this branch
  (see below). Updating `removed-packages` uninstalls them. They would
  otherwise block the gnome-desktop update.
- If extra repositories with newer GNOME builds are configured (with
  `bestmatching=true`), xbps can prefer those builds over the branch's. To
  install only from Void plus the branch, add `-i` and list the repositories:
  `xbps-install -i -R hostdir/binpkgs/gnome51 -R https://repo-default.voidlinux.org/current ...`.
- gdm keeps an edited `/etc/gdm/custom.conf`. Compare it with
  `custom.conf.new-*` after updating.

## Why Void is still on GNOME 48

Since version 49, gnome-session brings the session up only by starting
systemd user units: `gnome-session-init-worker` calls
`org.freedesktop.systemd1.StartUnit`. gdm 49+ needs that newer gnome-session.
elogind does not implement `systemd1`. PR #59394 therefore updates Shell,
Mutter, Settings Daemon and the leaf packages to 50 but keeps gnome-session
and gdm at 48 with compatibility patches. Its known problems are missing
shutdown and suspend, the Shell always "Not Responding" at logout, and gdm
stuck at 48.

This branch takes a different route. Everything is GNOME 51, gnome-session
and gdm included, and only gnome-session's systemd-only init worker is
replaced. runit does not supervise the session, so the 48/50 API mismatches
from the PR do not occur.

## The session without systemd

- **gnome-session** is built with `-Dsystemd=false`
  (`systemd-optional.patch`). This builds no units, no systemd worker and no
  `gnome-session-ctl`, and uses libelogind. gnome-session sets up and exports
  the session environment, then execs
  `/usr/libexec/gnome-session-init-worker <session>`.
- **`files/gnome-session-init-worker`** (bash) starts the same components the
  systemd units would, in their order, as plain children of the login
  session:
  1. `gnome-session-service`
  2. `gnome-shell` (`--mode=gdm`, `initial-setup` or `user`). The worker
     picks the Wayland socket name so it can pass it to the plugins.
  3. A `dbus-monitor` waits for the Shell's
     `RegisterClient(org.gnome.Shell.desktop)` and then calls `Initialized`.
     Under systemd, `gnome-session-signal-init.service` does this.
  4. The `gsd-*` plugins.

  If gnome-session-service or the Shell exits, the session ends. A plugin
  that fails is restarted up to five times. Plugins whose system daemon is
  missing are skipped: cupsd, pcscd, usbguard-daemon and ModemManager.
  Per-session opt-outs go in `/etc/gnome-session/sessions/<session>.disabled`.
  A lock refuses a second concurrent session for the same user.
- **`files/sessions/gnome-login`** lists the components of gdm's greeter
  session.
- **`files/dbus-run-session-if-needed`** wraps `gnome.desktop`'s `Exec`.
  gnome-session aborts without a session bus. gdm provides one, but lightdm
  and `startx`-style logins do not.
- **gnome-shell `revert-remove-gsm.patch`** makes the Shell call
  `RegisterClient` once it is ready. The worker uses that call as its
  readiness signal.

## Package changes

| package | master | branch | notes |
|---|---|---|---|
| gsettings-desktop-schemas | 48.0 | 51.0 | |
| gnome-desktop | 44.3 | 51.0 | needed by Shell 51 (below) |
| mutter | 48.7 | 51.1 | |
| gnome-shell | 48.7 | 51.1 | `revert-remove-gsm.patch`; `gjs-1.86.0.patch` dropped (upstream) |
| gnome-settings-daemon | 48.1 | 51.1 | |
| gnome-session | 48.0 | 51.0 | `systemd-optional.patch`, `autostart-condition.patch`, init worker |
| gdm | 48.0 | 51.1 | see below |
| gnome-control-center | 48.3 | 50.0 | 51 needs gtk4 4.24, glib 2.90, pango 1.58, accountsservice 26 |
| gnome-initial-setup | 48.1 | 50.0 | same as gnome-control-center |
| nautilus | 50.2.2 | 50.2.2 | 51 needs gtk4 4.24, glib 2.89 and libgxdp |
| xdg-desktop-portal-gnome | 48.0 | 51.0 | |
| gnome-shell-extensions | 48.3 | 51.0 | |
| adwaita-fonts | 48.2 | 51.0 | |
| adwaita-icon-theme | 49.0 | 51.0 | |
| gnome-backgrounds | 48.2.1 | 51.0.1 | |
| gnome-keyring | 48.0 | 51.1 | |
| gnome-online-accounts | 3.54.4 | 3.58.1 | |
| gnome-core | 48.0 | 51.0 | `gnome-control-center>=50.0`, `gnome-initial-setup>=50.0`, `nautilus>=50.2.2` |

gdm:

- `INSTALL` creates the preallocated `gdm-greeter` account, in group `gdm`.
  gdm 49+ without userdb looks up exactly that name, and `system_accounts`
  cannot create names that contain a dash.
- `greeter-env-without-systemd.patch`. Since gdm 50, the greeter environment
  (DCONF_PROFILE, XDG_*) is written only to `environment.d`, which only
  `systemd --user` reads. The patch sets it on the session again.
- `elogind-252-session-username.patch`. `sd_session_get_username()` arrived
  in systemd 254. The patch looks the name up from the session's uid. Drop it
  with elogind ≥ 254.
- `drop-wayland-udev-rules.patch` is dropped because it is part of 51.1.

mutter's `565756e1….patch` is dropped because it is part of 51.1.

### gnome-desktop 51 and its fallout

gnome-shell 51 imports `GnomeQR` (`js/misc/dependencies.js`, used by
`js/ui/qrCode.js`) at startup. gnome-desktop 51 introduced it, as
`libgnome-qr-4`. With gnome-desktop 44, the Shell exits at once and gdm
shows a black screen. This is a GObject-introspection import, not an ELF
link, so neither meson (`gnome-desktop-4 >= 40`) nor xbps catches it.

gnome-desktop 51 is built with `-Dqr=enabled`. Its upstream `qrcodegen`
subproject is vendored in the tarball. The X11 build dependencies are gone
because nothing in 51 uses them. `libxkbcommon-devel` is listed because
`xkbregistry` is linked.

Upstream removed GnomeRR in
[`c030c776`](https://gitlab.gnome.org/GNOME/gnome-desktop/-/commit/c030c7763402069e9fdcc72e31dcf799f8052d26)
("Remove libgnome-rr", first in 51.alpha). That removed both `libgnome-rr-4`
and the RR code in the legacy `libgnome-desktop-3`.
[`65687d8a`](https://gitlab.gnome.org/GNOME/gnome-desktop/-/commit/65687d8a)
bumped `libgnome-desktop-3` from `.so.20` to `.so.21`. As a result:

- `common/shlibs` lists `libgnome-desktop-3.so.21`, `libgnome-qr-4.so.0` and
  `libgnome-qr-gtk-4.so.0`. `libgnome-rr-4.so.2` is removed.
- Revbumped and rebuilt: cheese, eog, evince, evolution, gnome-panel, totem
  (libtotem), xdg-desktop-portal-gtk.
- Removed (added to `removed-packages`):
  - budgie-desktop, budgie-control-center, budgie-screensaver,
    budgie-session, budgie-desktop-view and magpie. The Budgie packages use
    GnomeRR (budgie-control-center's color panel, budgie-screensaver's
    fade). Upstream dropped the color panel only in budgie-control-center
    2.1.2, and budgie-screensaver is unmaintained.
  - gnome-screensaver 3.6.1: unmaintained since 2012, uses GnomeRR, and
    GNOME Shell has its own lock screen.
  - gnome-flashback: no longer buildable here (ibus 1.5.32 API).
- openbox no longer ships its GNOME session (`openbox-gnome-session`, the
  `openbox-gnome*.session` files, the `openbox-gnome` xsession).
  gnome-session 49+ runs only GNOME Shell sessions.

## Testing

Bare metal (x86_64 glibc, NVIDIA GTX 1660 Ti Mobile with the proprietary driver, runit), 2026-10-23, installed
from the branch with only Void's official repository besides the branch's:

| check | result |
|---|---|
| greeter | gdm 51 greeter runs: gdm → gdm-wayland-session → `gnome-session-init-worker gnome-login` → gnome-shell, Xwayland, gsd plugins |
| gnome-desktop 44 | black greeter: `JS ERROR: Requiring GnomeQR, version 4.0: Typelib file … not found`. Fixed by gnome-desktop 51 |
| login, power menu, logout | in progress |

An earlier QEMU/KVM test of the same session design passed login, lock and
unlock, Restart, Suspend, Power Off, logout and a second login, and the
polkit agent worked. That test ran on the voidlab overlay's newer platform
(GNOME 51 throughout), not on this branch.

Known gaps:

- `gsd-xsettings` is not started. Under systemd, the Shell starts it through
  `gnome-session-x11-services-ready.target` once Xwayland runs. X11 apps
  therefore get no XSETTINGS.
- musl is not built or tested.

## Upstreaming

Each package change is its own commit, in
[CONTRIBUTING.md](./CONTRIBUTING.md) format. The last commits (this README
and `install-gnome51.sh`) exist only on this branch and are dropped before
opening a pull request.
