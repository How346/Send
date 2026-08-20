# Windows target

The Flutter Windows runner is intentionally kept platform-isolated. Run:

flutter create --platforms=windows .

This regenerates the standard runner without changing the Dart application layer.
The GitHub workflow performs this step on a clean runner.
