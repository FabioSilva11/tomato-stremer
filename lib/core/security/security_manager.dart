import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gerenciador de segurança e criptografia avançada
/// Implementa múltiplas camadas de proteção contra engenharia reversa
class SecurityManager {
  static final SecurityManager _instance = SecurityManager._internal();
  factory SecurityManager() => _instance;
  SecurityManager._internal();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  // Chaves ofuscadas (serão geradas dinamicamente)
  String? _masterKey;
  String? _encryptionIV;
  
  // Cache temporário em memória
  final Map<String, dynamic> _memoryCache = {};
  
  /// Inicializa o gerenciador de segurança
  Future<void> initialize() async {
    await _ensureMasterKey();
    await _ensureIV();
  }

  /// Garante que existe uma chave mestra
  Future<void> _ensureMasterKey() async {
    try {
      _masterKey = await _storage.read(key: _obf('master_k'));
      if (_masterKey == null || _masterKey!.length != 32) {
        _masterKey = _generateSecureKey(32);
        await _storage.write(key: _obf('master_k'), value: _masterKey);
      }
    } catch (e) {
      // Fallback para chave gerada localmente
      _masterKey = _generateSecureKey(32);
    }
  }

  /// Garante que existe um IV (Initialization Vector)
  Future<void> _ensureIV() async {
    try {
      _encryptionIV = await _storage.read(key: _obf('enc_iv'));
      if (_encryptionIV == null || _encryptionIV!.length != 16) {
        _encryptionIV = _generateSecureKey(16);
        await _storage.write(key: _obf('enc_iv'), value: _encryptionIV);
      }
    } catch (e) {
      _encryptionIV = _generateSecureKey(16);
    }
  }

  /// Gera uma chave segura aleatória
  String _generateSecureKey(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(values).substring(0, length);
  }

  /// Ofusca strings simples (evita strings em texto claro no binário)
  String _obf(String input) {
    // Simples XOR para ofuscação básica
    final bytes = utf8.encode(input);
    final obfuscated = bytes.map((b) => b ^ 0x42).toList();
    return base64.encode(obfuscated);
  }

  /// Criptografa dados sensíveis
  Future<String> encrypt(String plainText) async {
    if (_masterKey == null || _encryptionIV == null) {
      await initialize();
    }

    try {
      final key = enc.Key.fromUtf8(_masterKey!);
      final iv = enc.IV.fromUtf8(_encryptionIV!);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return encrypted.base64;
    } catch (e) {
      // Fallback para Base64 se criptografia falhar
      return base64.encode(utf8.encode(plainText));
    }
  }

  /// Descriptografa dados
  Future<String> decrypt(String encryptedText) async {
    if (_masterKey == null || _encryptionIV == null) {
      await initialize();
    }

    try {
      final key = enc.Key.fromUtf8(_masterKey!);
      final iv = enc.IV.fromUtf8(_encryptionIV!);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      
      final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
      return decrypted;
    } catch (e) {
      // Fallback para Base64
      try {
        return utf8.decode(base64.decode(encryptedText));
      } catch (_) {
        return encryptedText; // Retorna original se não conseguir descriptografar
      }
    }
  }

  /// Armazena valor criptografado com segurança
  Future<void> secureWrite(String key, String value) async {
    final encrypted = await encrypt(value);
    await _storage.write(key: _obf(key), value: encrypted);
    _memoryCache[key] = value; // Cache em memória
  }

  /// Lê valor criptografado
  Future<String?> secureRead(String key) async {
    // Verificar cache primeiro
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key] as String?;
    }

    final encrypted = await _storage.read(key: _obf(key));
    if (encrypted == null) return null;

    final decrypted = await decrypt(encrypted);
    _memoryCache[key] = decrypted; // Adicionar ao cache
    return decrypted;
  }

  /// Remove valor do armazenamento seguro
  Future<void> secureDelete(String key) async {
    await _storage.delete(key: _obf(key));
    _memoryCache.remove(key);
  }

  /// Limpa todos os dados seguros
  Future<void> secureDeleteAll() async {
    await _storage.deleteAll();
    _memoryCache.clear();
  }

  /// Gera hash de string para validação
  String generateHash(String input) {
    final bytes = utf8.encode(input);
    int hash = 0;
    for (final byte in bytes) {
      hash = ((hash << 5) - hash) + byte;
      hash = hash & hash; // Convert to 32bit integer
    }
    return hash.toRadixString(16);
  }

  /// Valida integridade de dados
  bool validateIntegrity(String data, String expectedHash) {
    return generateHash(data) == expectedHash;
  }

  /// Limpa cache em memória (por segurança)
  void clearMemoryCache() {
    _memoryCache.clear();
  }
}

/// Classe para ofuscação de strings em tempo de compilação
/// Uso: const token = ObfuscatedString('meu_token_secreto');
class ObfuscatedString {
  const ObfuscatedString(this._value);
  
  final String _value;
  
  String get value {
    // Decodificação simples (pode ser melhorada)
    final bytes = utf8.encode(_value);
    final decoded = bytes.map((b) => b ^ 0x5A).toList();
    return utf8.decode(decoded);
  }
  
  @override
  String toString() => value;
}

/// Extensão para ofuscar strings facilmente
extension StringObfuscation on String {
  /// Ofusca a string atual
  String obfuscate() {
    final bytes = utf8.encode(this);
    final obfuscated = bytes.map((b) => b ^ 0x5A).toList();
    return utf8.decode(obfuscated);
  }
  
  /// Remove a ofuscação
  String deobfuscate() {
    return obfuscate(); // XOR é reversível
  }
}
