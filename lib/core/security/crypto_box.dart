import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class SessionSecrets {
  SessionSecrets(this.key, this.sessionId);
  final SecretKey key;
  final String sessionId;
}

class CryptoBox {
  static final _x25519 = X25519();
  static final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
  static final _aes = AesGcm.with256bits();

  static Future<KeyPair> createEphemeralKeyPair() => _x25519.newKeyPair();

  static Future<SessionSecrets> derive({
    required KeyPair local,
    required SimplePublicKey remote,
    required String sas,
  }) async {
    final shared = await _x25519.sharedSecretKey(keyPair: local, remotePublicKey: remote);
    final info = utf8.encode('HyperDrop-v1|$sas');
    final key = await _hkdf.deriveKey(secretKey: shared, info: info);
    final bytes = await key.extractBytes();
    final sessionId = base64UrlEncode(bytes.sublist(0, 12)).replaceAll('=', '');
    return SessionSecrets(key, sessionId);
  }

  static Future<Uint8List> seal(SecretKey key, Uint8List plaintext) async {
    final box = await _aes.encrypt(plaintext, secretKey: key);
    return Uint8List.fromList([...box.nonce, ...box.cipherText, ...box.mac.bytes]);
  }

  static Future<Uint8List> open(SecretKey key, Uint8List payload) async {
    if (payload.length < 28) {
      throw const FormatException('Encrypted frame too short');
    }
    final nonce = payload.sublist(0, 12);
    final mac = Mac(payload.sublist(payload.length - 16));
    final cipher = payload.sublist(12, payload.length - 16);
    final clear = await _aes.decrypt(
      SecretBox(cipher, nonce: nonce, mac: mac),
      secretKey: key,
    );
    return Uint8List.fromList(clear);
  }
}
