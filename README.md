# granola-linux

Run [Granola](https://www.granola.ai), the AI meeting notepad, natively on
Linux. Granola ships for macOS and Windows only, but it is an Electron app:
its macOS disk image holds the app's JavaScript next to a macOS Electron
runtime. `granola-linux` pairs that JavaScript with the matching Linux
Electron runtime, rebuilds the one native module Granola needs from the
sources in the image, and patches what keeps it from running. No Wine, no
virtual machine.

This is an unofficial compatibility project, not affiliated with Granola.
It redistributes nothing of Granola's: the image comes from Granola's own
release endpoint, and you sign in with your own account.

## Install

You need x86-64 Linux, `curl`, `python3`, `node` and `npm`, `make`, and
`g++` 11 or newer. A 7-Zip of version 21.02 or newer is used if present
(the `7zip` package on Arch, `7zip` on Debian 13 and Ubuntu 24.04 and
newer); otherwise the static build from 7-zip.org is fetched and checked
against the checksum pinned in the script.

```sh
git clone https://github.com/cacarico/granola-linux
cd granola-linux
make install DRY_RUN=1   # shows what would happen
make install             # downloads the current release and installs it
```

Then open Granola from the app menu, or run `~/.local/bin/granola`, and
sign in. Sign-in opens in your browser and comes back through a
`granola://` link, which the install registers.

To update, run `make install` again: it does nothing if the installed
version is current. `./granola-linux install --dmg FILE` uses an image you
already have, `--version 7.668.3` picks a release, `--force` rebuilds the
installed one. `make uninstall` removes the install and keeps your notes;
`./granola-linux uninstall --purge` removes those too.

Nothing needs root. The install lives under `~/.local/share/granola-linux`,
downloads under `~/.cache/granola-linux`, and Granola's own data under
`~/.config/Granola`, as the official app would.

## What works

| | |
|---|---|
| ✅ | Notes, editor, sync, AI features and search |
| ✅ | Sign-in with Google, Microsoft or SSO |
| ✅ | The encrypted local database |
| ✅ | Microphone recording |
| ✅ | Native Wayland and X11 |
| ⚠️ | System audio capture. The macOS build hears the other side of a call through Core Audio; on Linux the app falls back to a browser-style capture path. |
| ❌ | Apple Calendar. Google and Microsoft calendars work, since those run on the server. |
| ❌ | Global hotkeys |
| ❌ | Auto-update. Run `make install` again. |

## How it works

The conversion is six steps, each with its reasoning in the script:

1. Read the Electron version from the image and download that release's
   Linux build from Electron's GitHub releases. The zip is verified against
   the `SHASUMS256.txt` published next to it.
2. Copy `app.asar`, `app.asar.unpacked` and the icons from the image into
   the runtime. The macOS native binaries stay behind; the app guards them
   with platform checks.
3. Rebuild `better-sqlite3-multiple-ciphers` for Linux. Granola ships a
   patched fork with an `updateHook` method that no public build has, and
   the fork's C++ source is in the image. Only `binding.gyp` is missing;
   it comes from the npm release of the same version. The build uses the
   Electron headers for the exact runtime version.
4. Patch the platform label inside `app.asar`. Granola's API answers 500
   to `platform=linux`, sign-in included, so the fallback that would say
   `linux` says `Windows` instead. The replacement is byte-for-byte the
   same length, because the asar header records file offsets.
5. Make the click-and-drag module a no-op under Wayland. The meeting
   indicator window uses it, and its Linux build talks to X11 through
   Xlib, which aborts the whole app on a Wayland window handle.
6. Rename the Electron binary to `granola`, so that `app.isPackaged` is
   true and Granola does not run as a development build, and replace the
   macOS tray template icons with the coloured app icon.

A failed build never touches a working install: the app is assembled and
smoke-tested in the cache directory, then swapped into place.

Some distributions restrict unprivileged user namespaces, which Chromium
needs for its sandbox; the install then prints the root command that
configures the setuid sandbox helper instead of running it.

## Safety

Read the script before you run it; it is one file. It runs nothing as root,
downloads only from 7-zip.org, Electron's GitHub releases, electronjs.org,
the npm registry and Granola's release host, and verifies every download
against a published or pinned checksum, except Granola's own image, for
which Granola publishes none.

Granola's user terms forbid reverse engineering its software. This project
changes one string and one module's entry point in a build you downloaded
yourself; whether that is acceptable to you and to Granola is your call.

## License

Apache License 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
