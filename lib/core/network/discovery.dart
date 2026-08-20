import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

class DiscoveredDevice {
  const DiscoveredDevice({
    required this.id,
    required this.name,
    required this.address,
    required this.port,
    required this.sas,
  });
  final String id;
  final String name;
  final InternetAddress address;
  final int port;
  final String sas;
}

class DiscoveryService {
  DiscoveryService({this.port = 38741});
  final int port;
  RawDatagramSocket? _socket;
  Timer? _timer;
  final _devices = <String, DiscoveredDevice>{};

  Stream<List<DiscoveredDevice>> start({
    required String deviceId,
    required String deviceName,
    required String sas,
    int tcpPort = 38742,
  }) async* {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port, reuseAddress: true, reusePort: false);
    _socket!.broadcastEnabled = true;
    final controller = StreamController<List<DiscoveredDevice>>();

    void emit() => controller.add(List.unmodifiable(_devices.values));
    _socket!.listen((event) {
      if (event != RawSocketEvent.read) return;
      final dg = _socket!.receive();
      if (dg == null) return;
      try {
        final map = jsonDecode(utf8.decode(dg.data));
        if (map is! Map) return;
        final id = map['id'];
        final name = map['name'];
        final tcp = map['tcp'];
        final remoteSas = map['sas'];
        if (id is! String || name is! String || tcp is! int || remoteSas is! String || id == deviceId) return;
        _devices[id] = DiscoveredDevice(
          id: id,
          name: name,
          address: dg.address,
          port: tcp,
          sas: remoteSas,
        );
        emit();
      } catch (_) {}
    });

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      final packet = utf8.encode(jsonEncode({
        'v': 1,
        'id': deviceId,
        'name': deviceName,
        'tcp': tcpPort,
        'sas': sas,
        'nonce': Random.secure().nextInt(1 << 30),
      }));
      _socket?.send(packet, InternetAddress('255.255.255.255'), port);
      emit();
    });

    yield* controller.stream;
  }

  Future<void> stop() async {
    _timer?.cancel();
    _socket?.close();
    _timer = null;
    _socket = null;
  }
}
