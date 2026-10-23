# GNOME 51 on Void Linux (runit + elogind)

GNOME 51 for stock Void Linux: runit, elogind 252, no systemd. The branch is
a patch set against Void's `master` and keeps its toolchain and platform
libraries (gtk4 4.22, glib 2.88, accountsservice 23). It builds on
[void-linux/void-packages#59394](https://github.com/void-linux/void-packages/pull/59394).

Void's build documentation is in [Manual.md](./Manual.md) and
[CONTRIBUTING.md](./CONTRIBUTING.md).

## Build and install

xbps-src puts packages built on a branch other than `master` in
`hostdir/binpkgs/<branch>`.

```sh
./xbps-src binary-bootstrap
for p in gsettings-desktop-schemas gnome-desktop gnome-settings-daemon mutter \
	gnome-shell gnome-control-center gnome-session gdm xdg-desktop-portal-gnome \
	gnome-shell-extensions adwaita-fonts adwaita-icon-theme gnome-backgrounds \
	gnome-initial-setup gnome-keyring gnome-online-accounts gnome-core; do
	./xbps-src pkg $p || break
done
# rebuild those that are installed: cheese eog evince evolution gnome-panel
# totem xdg-desktop-portal-gtk openbox removed-packages
sudo xbps-install -S --repository=hostdir/binpkgs/gnome51 gnome-core gdm
sudo ln -s /etc/sv/gdm /var/service/
```

`./install-gnome51.sh` does the same (`-n` dry run, `-e` also enables gdm).

- Updating `removed-packages` uninstalls Budgie, gnome-flashback and
  gnome-screensaver (see [Removed packages](#removed-packages)).
- With other repositories that carry newer GNOME builds, install with `-i`
  and list only this repository and Void's.

## Why gnome-session and gdm need changes

Since 49, gnome-session starts the session only through systemd user units:
its `gnome-session-init-worker` asks `org.freedesktop.systemd1` to start
`gnome-session@<session>.target`. elogind does not provide that interface,
and gdm 49+ requires gnome-session 49+. This branch builds gnome-session
without systemd and installs a replacement init worker that starts the same
components as the units would. gdm needs two small patches for what systemd
used to provide.

## Versions

| package | master | branch | why not 51 |
|---|---|---|---|
| gsettings-desktop-schemas | 48.0 | 51.0 | |
| gnome-desktop | 44.3 | 51.0 | |
| mutter | 48.7 | 51.1 | |
| gnome-shell | 48.7 | 51.1 | |
| gnome-settings-daemon | 48.1 | 51.1 | |
| gnome-session | 48.0 | 51.0 | |
| gdm | 48.0 | 51.1 | |
| xdg-desktop-portal-gnome | 48.0 | 51.0 | |
| gnome-shell-extensions | 48.3 | 51.0 | |
| adwaita-fonts | 48.2 | 51.0 | |
| adwaita-icon-theme | 49.0 | 51.0 | |
| gnome-backgrounds | 48.2.1 | 51.0.1 | |
| gnome-keyring | 48.0 | 51.1 | |
| gnome-online-accounts | 3.54.4 | 3.58.1 | |
| gnome-control-center | 48.3 | 50.0 | 51 needs gtk4 4.24, glib 2.90, pango 1.58, accountsservice 26 |
| gnome-initial-setup | 48.1 | 50.0 | same as gnome-control-center |
| nautilus | 50.2.2 | 50.2.2 | 51 needs gtk4 4.24, glib 2.89, libgxdp |
| gnome-core | 48.0 | 51.0 | |

## Changes from upstream GNOME

### gnome-session

- `systemd-optional.patch`: adds `-Dsystemd=false` and links libelogind
  instead of libsystemd. With it off, no systemd units, systemd init worker
  or `gnome-session-ctl` are built. Adapted from
  [swagtoy's gnome-session branch](https://gitlab.gnome.org/swagtoy/gnome-session/-/commit/c17b5b56bcfcc0eba899295da7c79fb3ac98fd45)
  (gnome-session-openrc).
- `files/gnome-session-init-worker`: replaces the systemd worker.
  gnome-session exports the session environment, then execs it with the
  session name. It starts, as children of the login session (so gdm and
  polkit find them in it):
  1. `gnome-session-service`;
  2. `gnome-shell` (`--mode=gdm`, `initial-setup` or `user`), with a Wayland
     socket name the worker chooses so it can pass it to the plugins;
  3. once the Shell calls `RegisterClient`, `org.gnome.SessionManager.Initialized`
     (what `gnome-session-signal-init.service` does under systemd);
  4. the `gsd-*` plugins.

  The session ends when gnome-session-service or the Shell exits. A failed
  plugin restarts up to five times (`Restart=on-failure`). Plugins whose
  system daemon is missing (cupsd, pcscd, usbguard-daemon, ModemManager)
  are skipped, and `/etc/gnome-session/sessions/<session>.disabled` lists
  per-session opt-outs. A lock refuses a second concurrent session for the
  same user.
- `files/sessions/gnome-login`: the greeter's components, taken from gdm's
  `gnome-session@gnome-login.target` drop-in.
- `files/dbus-run-session-if-needed`, wrapped around `gnome.desktop`'s
  `Exec`: gnome-session 49+ aborts without a session bus. Upstream relies on
  `systemd --user` for it; gdm starts one, other display managers may not.
- `autostart-condition.patch`: gnome-session 49 dropped `AutostartCondition`
  because systemd's xdg-autostart generator evaluates it. Without systemd,
  entries such as Orca's would start at every login. Restores the
  GSettings, `if-exists`/`unless-exists` and `if-session`/`unless-session`
  checks from gnome-session 48.
- `depends`: `dbus` (for `dbus-run-session`) and `gnome-settings-daemon`
  (the worker starts its plugins).

### gnome-shell

- `revert-remove-gsm.patch` (Achill Gilgenast): reapplies "main: Notify
  gnome-session when we're ready". The Shell calls `RegisterClient` once it
  is up, and the init worker uses that as its readiness signal.
- `gjs-1.86.0.patch` dropped: included in 51.
- The separate libgnome-volume-control distfile is dropped: the 51 tarball
  ships `subprojects/gvc`.
- New dependencies: `glycin` (image loading), `librsvg-devel`,
  `elogind-devel`.
- `depends` on `gnome-desktop>=51.0_1`: the Shell imports the GnomeQR
  typelib at startup (see [gnome-desktop 51](#gnome-desktop-51)). It is not
  linked, so the shlib dependency (`>=43.0_1`) allows gnome-desktop 44.
  `checkdepends` strips the version, which xbps-src rejects in build
  dependencies. No build option disables it.

### gdm

- `greeter-env-without-systemd.patch`: since gdm 50 (dec7056f8) the greeter
  environment (`DCONF_PROFILE`, `XDG_CONFIG_HOME`, `XDG_STATE_HOME`,
  `XDG_DATA_DIRS`, ...) is only written to `environment.d`, which only
  `systemd --user` reads. Sets it on the session again and keeps the file.
- `elogind-252-session-username.patch`: gdm 51 calls
  `sd_session_get_username()`, added in systemd 254. Looks the name up from
  the session's uid instead. Drop it with elogind ≥ 254.
- `INSTALL` creates the `gdm-greeter` account (in groups `gdm` and `video`).
  Without systemd's userdb, gdm 49+ runs the greeter as exactly that user,
  and `system_accounts` cannot create names that contain a dash.
- `-Dpam-services-dir=/etc/pam.d`, so the PAM files land where Void's PAM
  reads them.
- The PAM conversion deletes `pam_systemd.so` lines from files that already
  list `pam_elogind.so`, where converting them would add pam_elogind twice.
- `-Dtcp-wrappers`, `-Dxauth-dir` and `-Dwayland-support` removed: upstream
  dropped them.
- `drop-wayland-udev-rules.patch` dropped: included in 51.1.

### mutter

- `-Degl_device`, `-Dudev` and `-Dnative_backend` removed: upstream dropped
  them.
- New dependency `glycin-devel`. The library sonames move from `-16` to
  `-51`, and `libmutter-cogl-pango` no longer exists.
- `565756e1….patch` dropped: included in 51.1.

### gnome-settings-daemon

- `-Delogind=true`: new option in 51, off by default; with `-Dsystemd=false`
  it is what makes gnome-settings-daemon use elogind.
- The separate libgnome-volume-control distfile is dropped, as for
  gnome-shell.

### gnome-desktop 51

gnome-shell 51 imports `GnomeQR` (`js/ui/qrCode.js`) at startup, and
gnome-desktop introduced it in 51 as `libgnome-qr-4`. With gnome-desktop 44
the Shell exits at once and gdm shows a black screen. It is a
GObject-introspection import, so neither meson nor xbps catches the missing
dependency.

- `-Dqr=enabled`; the `qrcodegen` subproject ships in the tarball.
- X11 build dependencies dropped: nothing in 51 uses them. Added
  `libxkbcommon-devel` (`xkbregistry` is linked).
- Upstream removed GnomeRR
  ([`c030c776`](https://gitlab.gnome.org/GNOME/gnome-desktop/-/commit/c030c7763402069e9fdcc72e31dcf799f8052d26)),
  which deleted `libgnome-rr-4` and the RR code in `libgnome-desktop-3`, and
  [`65687d8a`](https://gitlab.gnome.org/GNOME/gnome-desktop/-/commit/65687d8a)
  bumped `libgnome-desktop-3` to `.so.21`. `common/shlibs` gets
  `libgnome-desktop-3.so.21`, `libgnome-qr-4.so.0` and
  `libgnome-qr-gtk-4.so.0`, and loses `libgnome-rr-4.so.2`.
- Rebuilt for the new soname: cheese, eog, evince, evolution, gnome-panel,
  totem, xdg-desktop-portal-gtk.

### gnome-control-center 50

- New build dependencies: `blueprint-compiler`, `NetworkManager-devel`.
- For cross builds, `GI_TYPELIB_PATH` points at the target's typelibs so
  blueprint-compiler finds them.

### gnome-initial-setup 50

- `-Dsystemd=false` removed: upstream dropped the option.
- `system_groups="gnome-initial-setup"`: upstream creates the group only
  through sysusers.d, and gdm's PAM stack checks `user in
  gdm:gnome-initial-setup`.

### gnome-core

Requires `gnome-control-center>=50.0`, `gnome-initial-setup>=50.0` and
`nautilus>=50.2.2` instead of `>=${version}` (see [Versions](#versions)).

### Kept from master

`pam-turnstile-elogind.patch` (gdm) and `no-exe-introspection.patch`
(gnome-shell, musl) are unchanged.

## Removed packages

Added to `removed-packages`. Each one blocks the gnome-desktop 51 update:

- budgie-desktop, budgie-control-center, budgie-screensaver, budgie-session,
  budgie-desktop-view, magpie: use GnomeRR (budgie-control-center's color
  panel, budgie-screensaver's fade). Upstream dropped the color panel only
  in budgie-control-center 2.1.2, and budgie-screensaver is unmaintained.
- gnome-screensaver 3.6.1: uses GnomeRR, unmaintained since 2012. GNOME
  Shell has its own lock screen.
- gnome-flashback: no longer builds against ibus 1.5.32.

openbox no longer ships its GNOME session (`openbox-gnome-session`, the
`openbox-gnome*.session` files and the `openbox-gnome` xsession), because
gnome-session 49+ runs only GNOME Shell sessions.

## Known gaps

- `gsd-xsettings` is not started. Under systemd the Shell starts it through
  `gnome-session-x11-services-ready.target` once Xwayland runs, so X11 apps
  get no XSETTINGS.
- musl is not built.

## Upstreaming

Each package change is its own commit in [CONTRIBUTING.md](./CONTRIBUTING.md)
format. This README and `install-gnome51.sh` exist only on this branch and
are dropped before a pull request.
