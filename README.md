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
- Every package that differs from Void master, with the latest upstream
  release (checked 2026-11-22). Where Void already has a newer or equal
  version the branch keeps Void's template, except for revbumps that need a
  rebuild. GTK is not bumped; `-` means no upstream lookup. Packages built
  here before the final rebase onto master were not all rebuilt together.

  | Package | Void master | This branch | Upstream | Note |
  |---|---|---|---|---|
  | Endeavour | 43.0_4 | 43.0_5 | - |  |
  | accountsservice | 23.13.9_2 | 26.27.3_1 | 26.27.3 | Initial Setup 51 needs 26.12 (soname 1) |
  | adwaita-fonts | 48.2_1 | 51.0_1 | 51.0 |  |
  | adwaita-icon-theme | 49.0_1 | 51.0_1 | 51.0 |  |
  | at-spi2-core | 2.56.5_1 | 2.62.1_1 | 2.62.1 | required by orca 51 |
  | baobab | 48.0_1 | 50.0_1 | 50.0 |  |
  | bijiben | 40.2_1 | 40.2_2 | 40.2 |  |
  | budgie-control-center | 1.4.0_1 | 2.1.3_1 | 2.1.3 |  |
  | budgie-desktop | 10.9.4_1 | 10.10.4_1 | 10.10.4 | Budgie 10.10 on GNOME 51 |
  | budgie-desktop-view | 1.3_2 | 10.10.3_1 | 10.10.3 |  |
  | budgie-extras | - | 2.3.1_1 | 2.3.1 |  |
  | budgie-screensaver | 5.1.0_2 | 5.1.0_3 | 5.1.0 |  |
  | cheese | 44.1_4 | 44.1_5 | 44.1 | rebuild for gnome-desktop 51 |
  | dconf | 0.40.0_1 | 51.0_1 | - |  |
  | dconf-editor | 45.0.1_1 | 49.0_1 | 49.0 |  |
  | enter-tex | 3.49.0_1 | 3.51.0_1 | - |  |
  | eog | 50.0_1 | 50.4_1 | 50.4 | rebuild for gnome-desktop 51 |
  | epiphany | 48.5_1 | 51.3_1 | 51.3 | needs libpwquality-devel |
  | evince | 48.1_1 | 48.5_1 | 48.5 | rebuild for gnome-desktop 51 |
  | evolution | 3.56.2_2 | 3.62.1_1 | 3.62.1 | rebuild for gnome-desktop 51 |
  | evolution-data-server | 3.56.2_4 | 3.62.1_1 | 3.62.1 | soname bumps in common/shlibs |
  | evolution-ews | 3.56.2_1 | 3.62.1_1 | 3.62.1 |  |
  | fcron | 3.4.1_1 | 3.4.1_1 | - |  |
  | file-roller | 44.5_1 | 44.7_1 | 44.7 |  |
  | folks | 0.15.9_1 | 0.15.12_1 | 0.14.0 |  |
  | gcr4 | 4.4.0.1_2 | 4.4.1_1 | 4.4.1 |  |
  | gdm | 48.0_2 | 51.1.1_1 | 51.1.1 | drops gnome-themes-extra |
  | gedit | 50.0_1 | 51.0_1 | - | soname bump in common/shlibs |
  | gedit-plugins | 50.0_1 | 50.0_2 | - |  |
  | ghex | 46.3_1 | 50.4_1 | 50.4 |  |
  | gjs | 1.88.0_2 | 1.90.1_1 | 1.90.1 |  |
  | glycin | 2.2.1_1 | 2.2.6_1 | 2.2.6 |  |
  | gnome | 48.0_3 | 51.0_1 | - | meta: dropped archived apps, added d-spy |
  | gnome-backgrounds | 48.2.1_1 | 51.0.1_1 | 51.0.1 |  |
  | gnome-bluetooth | 47.1_2 | 47.2_1 | 47.2 |  |
  | gnome-calculator | 50.0_1 | 51.1_1 | 51.1 |  |
  | gnome-calendar | 50.0_1 | 51.0_1 | 51.0 |  |
  | gnome-characters | 48.0_1 | 51.0_1 | 51.0 |  |
  | gnome-clocks | 50.0_1 | 51.0_1 | 51.0 |  |
  | gnome-connections | 48.0_3 | 51.0_1 | 51.0 |  |
  | gnome-console | 48.0.1_1 | 51.0_1 | 51.0 |  |
  | gnome-contacts | 50.0_1 | 51.0_1 | 51.0 |  |
  | gnome-control-center | 48.3_1 | 50.4_1 | 51.1 | GTK 4.23 needed for 51, so it stays at 50.x |
  | gnome-core | 48.0_1 | 51.0_1 | - | meta: dropped gnome-themes-extra and helper libs, added orca |
  | gnome-desktop | 44.3_1 | 51.0_1 | 51.0 | ABI change, consumers rebuilt |
  | gnome-flashback | 3.52.1_1 | - | 3.58.0 | removed |
  | gnome-initial-setup | 48.1_1 | 51.1_1 | 51.1 |  |
  | gnome-keyring | 48.0_1 | 51.1_1 | - |  |
  | gnome-mines | 48.1_1 | 50.0_1 | - |  |
  | gnome-panel | 3.52.0_1 | 3.52.0_3 | 3.58.1 | rebuild for gnome-desktop 51 |
  | gnome-power-manager | 43.0_1 | 50.0_1 | - |  |
  | gnome-remote-desktop | 48.1_3 | 51.0_1 | 51.0 | elogind patch for sd_pidfd_get_session; mit-krb5-devel |
  | gnome-robots | 41.2_1 | 50.0_1 | - |  |
  | gnome-screensaver | 3.6.1_5 | - | - | removed |
  | gnome-session | 48.0_1 | 51.0_1 | 51.0 |  |
  | gnome-settings-daemon | 48.1_2 | 51.1_1 | 51.1 |  |
  | gnome-shell | 48.7_1 | 51.1_1 | 51.1 |  |
  | gnome-shell-extensions | 48.3_1 | 51.0_1 | 51.0 |  |
  | gnome-software | 50.2_1 | 51.1_1 | - |  |
  | gnome-sudoku | 49.2_1 | 51.0.1_1 | 51.0.1 |  |
  | gnome-system-monitor | 48.1_1 | 51.1_1 | - |  |
  | gnome-terminal | 3.56.2_1 | 3.60.0_1 | - |  |
  | gnome-tetravex | 3.38.2_1 | 3.38.3_1 | - |  |
  | gnome-text-editor | 50.1_1 | 51.0_1 | 51.0 |  |
  | gnome-tour | 48.1_1 | 50.0_1 | 50.0 |  |
  | gnome-user-docs | 48.2_1 | 51.0_1 | 51.2 |  |
  | gnome-weather | 48.0_1 | 50.0_1 | 50.0 |  |
  | gnote | 48.1_1 | 51.0_1 | 51.0 |  |
  | gsettings-desktop-schemas | 48.0_1 | 51.0_1 | 51.0 |  |
  | gspell | 1.14.2_1 | 1.14.5_1 | 1.14.5 |  |
  | gssdp | 1.6.3_1 | 1.6.6_1 | 1.6.6 |  |
  | gthumb | 3.12.8.2_2 | 4.0.3_1 | 4.0.3 |  |
  | gtranslator | 45.3_1 | 51.0_1 | 51.0 |  |
  | gucharmap | 16.0.1_1 | 18.0.0_1 | - |  |
  | gupnp | 1.6.8_2 | 1.6.10_1 | 1.6.10 |  |
  | gupnp-av | 0.14.1_1 | 0.14.5_1 | 0.14.5 |  |
  | gupnp-tools | 0.12.1_1 | 0.12.4_1 | 0.12.4 |  |
  | gweather-locations | - | 2026.2_1 | 2026.2 |  |
  | iagno | 3.38.1_1 | 50.0_1 | - |  |
  | io.elementary.calendar | 7.0.0_1 | 7.0.0_2 | - |  |
  | jsonrpc-glib | 3.44.0_1 | 3.44.2_1 | 3.44.2 |  |
  | libgedit-amtk | 5.10.0_1 | 5.11.0_1 | - |  |
  | libgedit-gfls | 0.4.0_1 | 0.5.0_1 | - |  |
  | libgedit-gtksourceview | 299.7.0_1 | 299.8.0_1 | - |  |
  | libgedit-tepl | 6.14.0_1 | 6.15.0_1 | - |  |
  | libgepub | 0.7.1_1 | 0.7.3_1 | - |  |
  | libgexiv2 | 0.14.5_3 | 0.14.7_1 | 0.16.2 |  |
  | libgexiv2-0.16 | 0.16.0_1 | 0.16.2_1 | 0.16.2 |  |
  | libgtop | 2.41.3_1 | 2.41.4_1 | - |  |
  | libgweather | 4.4.4_1 | 4.6.0_1 | 40.0 |  |
  | libmanette | 0.2.6_1 | 0.2.13_1 | - |  |
  | libmediaart | 1.9.6_1 | 1.9.7_1 | - |  |
  | libpanel | 1.8.1_1 | 1.10.4_1 | 1.10.4 |  |
  | libsecret | 0.21.7_1 | 0.21.8.2_1 | 0.20.5 |  |
  | libshumate | 1.6.1_1 | 1.7.0_1 | 1.6.4 |  |
  | libspelling | 0.4.9_1 | 0.4.11_1 | 0.4.11 |  |
  | libwebkit2gtk41 | 2.50.4_1 | 2.54.3_1 | 2.54.3 | 2.54.3, provides libwebkitgtk60 (API 6.0); two obsolete patches dropped, two rebased |
  | libwnck | 43.2_1 | 43.3_1 | 43.3 |  |
  | localsearch | 3.11.0_1 | 3.12.0_1 | 3.12.0 |  |
  | loupe | 51.0_1 | 51.2_1 | 51.2 |  |
  | magpie | 0.9.4_1 | - | 0.9.4 | removed |
  | metacity | 3.52.0_1 | 3.58.1_1 | - |  |
  | mm-common | 1.0.7_1 | 1.0.8_1 | 1.0.8 |  |
  | msgraph | 0.3.5_1 | 0.3.5_1 | 0.2.3 | gvfs 1.62 needs 0.3 (soname 1) |
  | mutter | 48.7_2 | 51.1_1 | 51.1 |  |
  | nautilus | 50.2.2_1 | 50.4_1 | 51.1 | GTK 4.24 and GLib 2.89 needed for 51, so it stays at 50.x |
  | nautilus-python | 4.1.0_1 | 4.2.0_1 | 4.2.0 |  |
  | openbox | 3.6.1_5 | 3.6.1_6 | - | drops GNOME session |
  | orca | 48.6_2 | 51.2_1 | 51.2 | needs at-spi2-core >= 2.58.6; python3-dasbus, MathCAT off |
  | papers | 51.0_1 | 51.1_1 | 51.1 |  |
  | phodav | 3.0_2 | 3.2_1 | 3.2 |  |
  | pidgin | 2.14.14_1 | 2.14.14_2 | - |  |
  | planify | 4.5.12_2 | 4.5.12_3 | - |  |
  | python3-atspi | 2.38.0_8 | 2.58.2_1 | 2.58.2 |  |
  | python3-pytest-cov | 7.1.0_1 | 7.1.0_1 | - |  |
  | quadrapassel | 40.2_2 | 51.1_1 | - |  |
  | removed-packages | 0.1.20260823_1 | 0.1.20261023_1 | - | adds Flashback, Magpie, gnome-screensaver, etc. |
  | runit-settingsd | - | 0.3.0_1 | - | optional hostname1/timedate1/locale1 services |
  | shotwell | 0.32.13_2 | 0.32.17_1 | 33.2 |  |
  | simple-scan | 49.1_1 | 50.0_1 | 50.0 |  |
  | sushi | 46.0_3 | 51.2_1 | 51.2 | ported to GTK 4, WebKitGTK 6.0, Papers, glycin |
  | swell-foop | 48.1_1 | 50.0_1 | - |  |
  | sysprof | 47.2_1 | 51.0_1 | 51.0 |  |
  | tecla | 50.0_1 | 51.0_1 | 51.0 |  |
  | tinysparql | 3.11.0_1 | 3.12.0_1 | 3.12.0 |  |
  | totem | 43.2_3 | 43.2_4 | 43.2 | rebuild for gnome-desktop 51 |
  | totem-pl-parser | 3.26.6_1 | 3.26.7_1 | - |  |
  | vte3 | 0.82.1_1 | 0.84.1_1 | 0.84.1 |  |
  | xdg-desktop-portal-gnome | 48.0_1 | 51.0_1 | 51.0 |  |
  | xdg-desktop-portal-gtk | 1.15.3_1 | 1.15.3_2 | - | rebuild for gnome-desktop 51 |
  | xdg-user-dirs-gtk | 0.14_1 | 0.16_1 | 0.16 |  |
  | yelp | 42.3_1 | 49.2_1 | 49.2 |  |
  | yelp-xsl | 42.4_1 | 49.0_1 | 49.0 |  |
  | zenity | 4.0.5_1 | 4.2.2_1 | 4.2.2 |  |

- Small compatibility patches support elogind 252, session startup without
  systemd, autostart conditions and IBus 1.5.32.
- Build with `./xbps-src binary-bootstrap`, then `./xbps-src pkg gnome-core`
  and `./xbps-src pkg gdm`. Packages go in `hostdir/binpkgs/gnome51-v2`.
- `./install-gnome51.sh -n` previews the build and install commands.
  Run without `-n` to install; `-e` also switches the display manager to GDM.
- The gnome-desktop ABI change requires rebuilding installed consumers.
  The installer handles these. Updating `removed-packages` removes Magpie,
  GNOME Flashback and gnome-screensaver. Budgie 10.10 is packaged on GNOME 51.
- XSETTINGS startup is still missing; musl and cross builds are untested.
- See [Manual.md](Manual.md) for packaging details.
