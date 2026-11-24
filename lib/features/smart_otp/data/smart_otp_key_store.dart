import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Demo-only software key protected by an OS secure-storage layer and PIN-derived AES-GCM.
/// A banking-grade implementation should bind private-key operations to hardware-backed
/// authentication with Android Keystore / iOS Secure Enclave and device attestation.
class SmartOtpKeyStore {
  const SmartOtpKeyStore();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const _recordKey = 'anpay_smart_otp_pending_v1';
  static String _deviceKey(String deviceId) => 'anpay_smart_otp_device_v1_$deviceId';
  static final _ed25519 = Ed25519();
  static final _aes = AesGcm.with256bits();
  static final _pbkdf = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 210000, bits: 256);

  static Uint8List _randomBytes(int count) {
    final rng = Random.secure();
    return Uint8List.fromList(List<int>.generate(count, (_) => rng.nextInt(256)));
  }

  Future<void> clearPending() => _storage.delete(key: _recordKey);

  Future<Map<String, dynamic>?> pending() async {
    final record = await _read();
    return record != null && record['state'] == 'pending' ? record : null;
  }

  Future<String> createPending(String pin) async {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      throw StateError('PIN Smart OTP phải gồm 6 chữ số.');
    }
    final pair = await _ed25519.newKeyPair();
    final priv = Uint8List.fromList(await pair.extractPrivateKeyBytes());
    final pub = await pair.extractPublicKey();
    final salt = _randomBytes(16);
    final nonce = _randomBytes(12);
    final encryptionKey = await _pbkdf.deriveKeyFromPassword(
      password: pin, nonce: salt,
    );
    final cipher = await _aes.encrypt(priv, secretKey: encryptionKey, nonce: nonce);
    await _save({
      'state': 'pending',
      'public': base64Encode(pub.bytes),
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
      'cipher': base64Encode(cipher.cipherText),
      'mac': base64Encode(cipher.mac.bytes),
    });
    // Overwriting with zeros is only best-effort in Dart's managed runtime.
    for (var i = 0; i < priv.length; i++) { priv[i] = 0; }
    return base64Encode(pub.bytes);
  }

  Future<void> bindPending(String deviceId) async {
    final record = await _read();
    if (record == null || record['state'] != 'pending') {
      throw StateError('Chưa có khóa Smart OTP để đăng ký.');
    }
    record['deviceId'] = deviceId;
    await _save(record);
  }

  Future<void> activate(String deviceId) async {
    final record = await _read();
    if (record?['deviceId'] != deviceId) {
      throw StateError('Thiết bị Smart OTP không khớp.');
    }
    record!['state'] = 'active';
    await _storage.write(key: _deviceKey(deviceId), value: jsonEncode(record));
    await _storage.delete(key: _recordKey);
  }

  Future<bool> recoverConfirmedDevice(String deviceId) async {
    // Retry the local half of activation if the server confirmed the OTP but
    // the app was interrupted before encrypted storage was finalized.
    final record = await _read();
    if (record?['state'] != 'pending' || record?['deviceId'] != deviceId) return false;
    await activate(deviceId);
    return true;
  }

  Future<bool> hasLocalDevice(String deviceId) async {
    final record = await _readDevice(deviceId);
    return record?['state'] == 'active' && record?['deviceId'] == deviceId;
  }

  Future<void> clear(String deviceId) => _storage.delete(key: _deviceKey(deviceId));

  Future<String> sign(String deviceId, String message, String pin) async {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) throw StateError('PIN không hợp lệ.');
    final record = await _readDevice(deviceId);
    if (record == null || record['state'] != 'active' || record['deviceId'] != deviceId) {
      throw StateError('Không tìm thấy khóa Smart OTP của thiết bị này. Hãy kích hoạt lại.');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final lockedUntil = (record['lockUntil'] as num? ?? 0).toInt();
    if (lockedUntil > now) {
      throw StateError('Bạn đã nhập sai PIN quá nhiều lần. Thử lại sau 10 phút.');
    }
    if (lockedUntil != 0) {
      record.remove('lockUntil');
      record.remove('failedPins');
      await _saveDevice(deviceId, record);
    }
    final encryptionKey = await _pbkdf.deriveKeyFromPassword(
      password: pin, nonce: base64Decode(record['salt'] as String),
    );
    final box = SecretBox(
      base64Decode(record['cipher'] as String),
      nonce: base64Decode(record['nonce'] as String),
      mac: Mac(base64Decode(record['mac'] as String)),
    );
    List<int> priv;
    try {
      priv = Uint8List.fromList(await _aes.decrypt(box, secretKey: encryptionKey));
    } on SecretBoxAuthenticationError {
      final count=(record['failedPins'] as num? ?? 0).toInt()+1;
      record['failedPins']=count;
      if(count>=5) record['lockUntil']=now+600000;
      await _saveDevice(deviceId, record);
      throw StateError(count>=5
          ? 'Smart OTP bị khóa 10 phút do nhập sai PIN.'
          : 'PIN Smart OTP không đúng.');
    }
    record.remove('failedPins');
    record.remove('lockUntil');
    await _saveDevice(deviceId, record);
    try {
      final pair = SimpleKeyPairData(
        priv,
        publicKey: SimplePublicKey(
          base64Decode(record['public'] as String), type: KeyPairType.ed25519,
        ),
        type: KeyPairType.ed25519,
      );
      final signature = await _ed25519.sign(utf8.encode(message), keyPair: pair);
      return base64Encode(signature.bytes);
    } finally {
      for (var i = 0; i < priv.length; i++) { priv[i] = 0; }
    }
  }

  Future<Map<String, dynamic>?> _read() => _readKey(_recordKey);
  Future<Map<String, dynamic>?> _readDevice(String deviceId) => _readKey(_deviceKey(deviceId));
  Future<Map<String, dynamic>?> _readKey(String key) async {
    final text = await _storage.read(key: key);
    if (text == null) return null;
    return Map<String, dynamic>.from(jsonDecode(text) as Map);
  }
  Future<void> _save(Map<String, dynamic> data) =>
      _storage.write(key: _recordKey, value: jsonEncode(data));
  Future<void> _saveDevice(String deviceId, Map<String, dynamic> data) =>
      _storage.write(key: _deviceKey(deviceId), value: jsonEncode(data));
}
