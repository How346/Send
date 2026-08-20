import 'dart:io';

abstract interface class Transport {
  Future<Socket> connect(InternetAddress address, int port);
  Future<void> close();
}

class TcpTransport implements Transport {
  Socket? _socket;

  @override
  Future<Socket> connect(InternetAddress address, int port) async {
    _socket = await Socket.connect(address, port, timeout: const Duration(seconds: 5));
    _socket!.setOption(SocketOption.tcpNoDelay, true);
    return _socket!;
  }

  @override
  Future<void> close() async => _socket?.destroy();
}

// Intentionally not a fake implementation. Android/Windows Bluetooth APIs should
// implement this contract in platform adapters when a real radio transport is available.
abstract interface class BluetoothTransport implements Transport {}
