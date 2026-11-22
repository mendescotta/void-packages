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
- Every package that differs from Void master (checked 2026-11-22 against
  `origin/master`). Nothing
  here is older than Void: where Void has already bumped a package, the
  branch keeps Void's template unless a rebuild is needed. Same-as-Void
  packages (gnome-builder 50.0, gtksourceview5, template-glib, libtheora,
  gst-plugins-base1) are not listed. GTK is not bumped.

  | Package | Void master | This branch | Change | Note |
  |---|---|---|---|---|
  | accountsservice | 23.13.9_2 | 26.27.3_1 | newer | Initial Setup 51 needs 26.12 (soname 1) |
  | adwaita-fonts | 48.2_1 | 51.0_1 | newer |  |
  | adwaita-icon-theme | 49.0_1 | 51.0_1 | newer |  |
  | at-spi2-core | 2.56.5_1 | 2.62.1_1 | newer | required by orca 51; no soname change |
  | baobab | 48.0_1 | 50.0_1 | newer |  |
  | budgie-control-center | 1.4.0_1 | - | removed on branch | removed (Budgie lives on `gnome51-budgie`) |
  | budgie-desktop | 10.9.4_1 | - | removed on branch | removed (Budgie lives on `gnome51-budgie`) |
  | budgie-desktop-view | 1.3_2 | - | removed on branch | removed (Budgie lives on `gnome51-budgie`) |
  | budgie-screensaver | 5.1.0_2 | - | removed on branch | removed (Budgie lives on `gnome51-budgie`) |
  | budgie-session | 1.0.1_1 | - | removed on branch | removed (Budgie lives on `gnome51-budgie`) |
  | cheese | 44.1_4 | 44.1_5 | revbump | rebuild for gnome-desktop 51 |
  | dconf | 0.40.0_1 | 51.0_1 | newer |  |
  | eog | 50.0_1 | 50.0_2 | revbump | rebuild for gnome-desktop 51 |
  | epiphany | 48.5_1 | 51.3_1 | newer | needs libpwquality-devel |
  | evince | 48.1_1 | 48.1_2 | revbump | rebuild for gnome-desktop 51 |
  | evolution | 3.56.2_2 | 3.56.2_3 | revbump | rebuild for gnome-desktop 51 |
  | gdm | 48.0_2 | 51.1.1_2 | newer | drops gnome-themes-extra dependency |
  | gjs | 1.88.0_2 | 1.90.1_1 | newer |  |
  | glycin | 2.2.1_1 | 2.2.6_1 | newer |  |
  | gnome | 48.0_3 | 48.0_6 | revbump | meta: dropped archived/replaced apps, added d-spy |
  | gnome-backgrounds | 48.2.1_1 | 51.0.1_1 | newer |  |
  | gnome-bluetooth | 47.1_2 | 47.2_1 | newer |  |
  | gnome-calculator | 50.0_1 | 51.1_1 | newer |  |
  | gnome-calendar | 50.0_1 | 51.0_1 | newer |  |
  | gnome-characters | 48.0_1 | 51.0_1 | newer |  |
  | gnome-clocks | 50.0_1 | 51.0_1 | newer |  |
  | gnome-connections | 48.0_3 | 51.0_1 | newer |  |
  | gnome-console | 48.0.1_1 | 51.0_1 | newer |  |
  | gnome-contacts | 50.0_1 | 51.0_1 | newer |  |
  | gnome-control-center | 48.3_1 | 50.0_2 | newer | stays at 50: 51 needs GTK 4.23 |
  | gnome-core | 48.0_1 | 51.0_2 | newer | meta: dropped gnome-themes-extra and helper libs, added orca |
  | gnome-desktop | 44.3_1 | 51.0_2 | newer | ABI change; consumers rebuilt |
  | gnome-flashback | 3.52.1_1 | - | removed on branch | removed (Budgie lives on `gnome51-budgie`) |
  | gnome-initial-setup | 48.1_1 | 51.1_1 | newer |  |
  | gnome-keyring | 48.0_1 | 51.1_1 | newer |  |
  | gnome-panel | 3.52.0_1 | 3.52.0_2 | revbump | rebuild for gnome-desktop 51 |
  | gnome-remote-desktop | 48.1_3 | 51.0_1 | newer | elogind patch for sd_pidfd_get_session; mit-krb5-devel |
  | gnome-screensaver | 3.6.1_5 | - | removed on branch | removed (Budgie lives on `gnome51-budgie`) |
  | gnome-session | 48.0_1 | 51.0_2 | newer |  |
  | gnome-settings-daemon | 48.1_2 | 51.1_1 | newer |  |
  | gnome-shell | 48.7_1 | 51.1_2 | newer |  |
  | gnome-shell-extensions | 48.3_1 | 51.0_1 | newer |  |
  | gnome-software | 50.2_1 | 51.1_1 | newer |  |
  | gnome-system-monitor | 48.1_1 | 51.1_1 | newer |  |
  | gnome-text-editor | 50.1_1 | 51.0_1 | newer |  |
  | gnome-tour | 48.1_1 | 50.0_1 | newer |  |
  | gnome-user-docs | 48.2_1 | 51.0_1 | newer |  |
  | gnome-weather | 48.0_1 | 50.0_1 | newer |  |
  | gsettings-desktop-schemas | 48.0_1 | 51.0_1 | newer |  |
  | libshumate | 1.6.1_1 | 1.6.3_1 | newer |  |
  | libwebkit2gtk41 | 2.50.4_1 | 2.54.3_1 | newer | 2.54.3 (provides libwebkitgtk60); two obsolete patches dropped, two rebased |
  | localsearch | 3.11.0_1 | 3.12.0_1 | newer |  |
  | loupe | 51.0_1 | 51.2_1 | newer |  |
  | magpie | 0.9.4_1 | - | removed on branch | removed (Budgie lives on `gnome51-budgie`) |
  | msgraph | 0.3.5_1 | 0.3.5_1 | same version, files/patches differ | gvfs 1.62 needs 0.3 (soname 1) |
  | mutter | 48.7_2 | 51.1_1 | newer |  |
  | openbox | 3.6.1_5 | 3.6.1_6 | revbump | drops GNOME session |
  | orca | 48.6_2 | 51.2_1 | newer | needs at-spi2-core >= 2.58.6; adds python3-dasbus, MathCAT off |
  | papers | 51.0_1 | 51.1_1 | newer |  |
  | removed-packages | 0.1.20260823_1 | 0.1.20261023_1 | newer | adds Budgie, Magpie, Flashback, gnome-screensaver |
  | runit-settingsd | - | 0.3.0_1 | new on branch | optional hostname1/timedate1/locale1 D-Bus services |
  | simple-scan | 49.1_1 | 50.0_1 | newer |  |
  | sushi | 46.0_3 | 51.2_1 | newer | ported to GTK 4, WebKitGTK 6.0, Papers, glycin; old patch dropped |
  | tecla | 50.0_1 | 51.0_1 | newer |  |
  | tinysparql | 3.11.0_1 | 3.12.0_1 | newer |  |
  | totem | 43.2_3 | 43.2_4 | revbump | rebuild for gnome-desktop 51 |
  | xdg-desktop-portal-gnome | 48.0_1 | 51.0_1 | newer |  |
  | xdg-desktop-portal-gtk | 1.15.3_1 | 1.15.3_2 | revbump | rebuild for gnome-desktop 51 |
  | yelp | 42.3_1 | 49.2_1 | newer |  |
  | yelp-xsl | 42.4_1 | 49.0_1 | newer |  |

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
