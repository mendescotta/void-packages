# GNOME 51 on Void Linux

- GNOME 51 for runit and elogind, with Void’s existing platform libraries.
- Settings and Initial Setup stay at 50; Control Center 51 needs GTK 4.23,
  while Nautilus 51 needs GTK 4.24 and GLib 2.89. Epiphany 51 does not build
  against Void's WebKitGTK 2.50.4 API, so it stays at 50.6.
- GNOME Logs needs libsystemd and has no runit-compatible setup.
- Small compatibility patches support elogind 252, session startup without
  systemd, autostart conditions and IBus 1.5.32.
- Build with `./xbps-src binary-bootstrap`, then `./xbps-src pkg gnome-core`
  and `./xbps-src pkg gdm`. Packages go in `hostdir/binpkgs/gnome51`.
- `./install-gnome51.sh -n` previews the build and install commands.
  Run without `-n` to install; `-e` also switches the display manager to GDM.
- The gnome-desktop ABI change requires rebuilding installed consumers.
  The installer handles these. Updating `removed-packages` removes Budgie,
  Magpie, GNOME Flashback and gnome-screensaver.
- XSETTINGS startup is still missing; musl and cross builds are untested.
- See [Manual.md](Manual.md) for packaging details.
