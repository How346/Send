enum TransferState { queued, connecting, transferring, paused, verifying, completed, failed, cancelled }

class TransferItem {
  TransferItem({
    required this.id,
    required this.path,
    required this.name,
    required this.size,
    this.offset = 0,
    this.state = TransferState.queued,
    this.sha256,
    this.error,
  });

  final String id;
  final String path;
  final String name;
  final int size;
  int offset;
  TransferState state;
  String? sha256;
  String? error;

  double get progress => size == 0 ? 1 : (offset / size).clamp(0, 1);
}
