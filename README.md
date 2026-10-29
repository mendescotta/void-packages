# GNOME 51 on Void Linux

- Settings and Initial Setup stay at 50; Control Center 51 needs GTK 4.23,
  Nautilus 51 needs GTK 4.24 and GLib 2.89. Epiphany 51 does not build
  against Void's WebKitGTK 2.50.4 API, so it stays at 50.6.
- GNOME Logs needs libsystemd and has no runit-compatible setup.
- Small compatibility patches support elogind 252, session startup without
  systemd, autostart conditions and IBus 1.5.32.
