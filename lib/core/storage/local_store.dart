import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  static const _deviceId = 'device_id';
  static const _deviceName = 'device_name';
  static const _receiveRoot = 'receive_root';
  static const _trusted = 'trusted_devices';
  static const _history = 'history';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<String?> get deviceId async => (await _prefs).getString(_deviceId);
  Future<void> setDeviceId(String value) async => (await _prefs).setString(_deviceId, value);

  Future<String> get deviceName async => (await _prefs).getString(_deviceName) ?? 'HyperDrop device';
  Future<void> setDeviceName(String value) async => (await _prefs).setString(_deviceName, value);

  Future<String?> get receiveRoot async => (await _prefs).getString(_receiveRoot);
  Future<void> setReceiveRoot(String value) async => (await _prefs).setString(_receiveRoot, value);

  Future<List<Map<String, dynamic>>> get history async {
    final raw = (await _prefs).getStringList(_history) ?? const [];
    return raw.map((x) => Map<String, dynamic>.from(jsonDecode(x) as Map)).toList();
  }

  Future<void> addHistory(Map<String, dynamic> item) async {
    final p = await _prefs;
    final list = p.getStringList(_history) ?? [];
    list.insert(0, jsonEncode(item));
    await p.setStringList(_history, list.take(500).toList());
  }

  Future<List<Map<String, dynamic>>> get trusted async {
    final raw = (await _prefs).getStringList(_trusted) ?? const [];
    return raw.map((x) => Map<String, dynamic>.from(jsonDecode(x) as Map)).toList();
  }

  Future<void> trust(Map<String, dynamic> device) async {
    final p = await _prefs;
    final list = p.getStringList(_trusted) ?? [];
    list.removeWhere((x) => (jsonDecode(x) as Map)['id'] == device['id']);
    list.add(jsonEncode(device));
    await p.setStringList(_trusted, list);
  }
}
