# HyperDrop

HyperDrop is an original, local-first Android ↔ Windows file-transfer application.

## Current implementation

- UDP LAN discovery with signed application-level identity records.
- User-visible six-digit pairing/SAS confirmation.
- TCP streaming transport with framed protocol messages.
- Chunked file streaming; files are never base64 encoded or loaded wholly into RAM.
- SHA-256 verification.
- Resumable receiving using `.hyperdrop.part` metadata.
- Queue/state model with measured throughput and ETA.
- Safe destination-path validation and filename sanitization.
- Duplicate-file handling without silent overwrites.
- Persistent settings/history/trusted-device metadata.
- Android file picker and Windows drag/drop entry points.
- Material 3 responsive UI.
- GitHub Actions for analyze/test, Android, Windows, installer, and tag releases.

## Important build note

This repository was generated in an environment without the Flutter/Dart SDK and without Android/Windows build toolchains. Therefore no APK/AAB/EXE is fabricated here.

Run locally or through GitHub Actions:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
flutter build windows --release
```

The Windows installer workflow expects Inno Setup (`iscc`) on the runner.

## Security model

HyperDrop uses an established cryptographic primitive from the `cryptography` package:
X25519 for ephemeral key agreement, HKDF-SHA256 for key derivation, and AES-256-GCM
for authenticated encryption. The pairing/SAS value is displayed to both users and
must be confirmed by the human before a device is trusted.

The discovery packet is deliberately treated as untrusted input. A TCP session must
complete the handshake before file frames are accepted.

## Protocol

The protocol is length-prefixed UTF-8 JSON control frames plus binary file chunks.
Each binary chunk contains:

`file-id | offset | length | bytes`

Offsets are checked against the declared file size. The receiver writes only below the
selected receive root and verifies the final SHA-256 before publishing the file.

## Limitations

Bluetooth fallback is intentionally represented as a transport abstraction rather
than a fake implementation. Native Bluetooth data transport requires platform-specific
radio APIs and permissions that vary by Android version and Windows hardware. The
default production path is LAN TCP. A future `BluetoothTransport` can implement the
same `Transport` contract without changing UI/business logic.
