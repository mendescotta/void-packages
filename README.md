# GNOME 51 on Void Linux

- GNOME 51 for runit and elogind, with Void’s existing platform libraries.
- Settings stays at 50 and Files (Nautilus) at 50.2.2: Control Center 51
  needs GTK 4.23, while Nautilus 51 needs GTK 4.24 and GLib 2.89. Epiphany 51
  does not build against Void's WebKitGTK 2.50.4 API, so it stays at 50.6.
- Initial Setup 51 needs AccountsService 26.12 (soname 1), so accountsservice
  is updated to 26.27.3. gvfs 1.62 needs msgraph 0.3 (soname 1), and enables
  the deprecated AFP backend to keep gvfs-afp.
- GNOME Logs needs libsystemd and has no runit-compatible setup.
- `runit-settingsd` is optional. It provides the hostname1, timedate1 and
  locale1 D-Bus services for Settings; build it with `./xbps-src pkg
  runit-settingsd`, or pass `-r` to the installer.
- `gnome-core` and `gnome` follow GNOME 51's stack (gnome-build-meta 51.1):
  no gnome-themes-extra, GTK-era helper libraries, devhelp, vino, totem and
  the archived dictionary, nettool, photos and screenshot apps; Orca is back.
  gnome-builder is 50.0 (LLVM 23), as in Void master.
- Package versions against Void master and upstream GNOME 51 (checked
  2026-11-22):

  | Package | Void master | This tree | Upstream | Status |
  |---|---|---|---|---|
  | libwebkit2gtk41 (+ libwebkitgtk60) | 2.50.4 | 2.54.3 | 2.54.3 | built; dropped two obsolete patches, rebased two |
  | epiphany | 48.5 | 51.2 | 51.3 | built; needs `libpwquality-devel`; 51.3 not taken yet |
  | gnome-remote-desktop | 48.1 | 51.0 | 51.0 | built; elogind lacks `sd_pidfd_get_session`, so a patch reads the pid from fdinfo; adds `mit-krb5-devel` |
  | sushi | 46.0 | 51.2 | 51.2 | built; rewritten for GTK 4, WebKitGTK 6.0, Papers and glycin; old patch dropped |
  | tecla | 50.0 | 51.0 | 51.0 | built |
  | orca | 48.6 | 48.6 | 51.2 | blocked: 51 needs at-spi2-core 2.58.6 (Void has 2.56.5), and 2.58 replaces at-spi2-atk |
  | at-spi2-core | 2.56.5 | 2.56.5 | 2.58.9 | not bumped; see orca |
  | gnome-builder | 50.0 | 50.0 | 50.0 | as in Void master (LLVM 23) |
  | gtksourceview5, template-glib | 5.22.0, 3.40.0 | same | same | as in Void master |
  | budgie-desktop (+ devel) | 10.9.4 | 10.10.4 | 10.10.4 | built on branch `gnome51-budgie`; not in this branch |
  | budgie-control-center (+ devel) | 1.4.0 | 2.1.3 | 2.1.3 | built on branch `gnome51-budgie` |
  | budgie-desktop-view | 1.3 | 10.10.3 | 10.10.3 | built on branch `gnome51-budgie` |
  | budgie-extras | not packaged | 2.3.1 | not checked | built on branch `gnome51-budgie` |
  | budgie-screensaver, budgie-session | 5.1.0, 1.0.1 | same (revbumped) | 5.1.0, 1.0.1 | built on branch `gnome51-budgie` |
  | libtheora, gst-plugins-base1 | 1.2.0, 1.28.9_2 | same | n/a | taken from Void master (soname bump in `common/shlibs`) |

- Small compatibility patches support elogind 252, session startup without
  systemd, autostart conditions and IBus 1.5.32.
- Build with `./xbps-src binary-bootstrap`, then `./xbps-src pkg gnome-core`
  and `./xbps-src pkg gdm`. Packages go in `hostdir/binpkgs/gnome51`.
- `./install-gnome51.sh -n` previews the build and install commands.
  Run without `-n` to install; `-e` also switches the display manager to GDM.
- The gnome-desktop ABI change requires rebuilding installed consumers.
  The installer handles these. Updating `removed-packages` removes Budgie,
  Magpie, GNOME Flashback and gnome-screensaver; the separate `gnome51-budgie`
  branch brings Budgie back on GNOME 51 and drops those removals.
- XSETTINGS startup is still missing; musl and cross builds are untested.
- See [Manual.md](Manual.md) for packaging details.
