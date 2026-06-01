import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  // IMPORTANT: For a production app, this key should NOT be hardcoded. 
  // It should be fetched securely, or unique per chat derived from user passwords.
  // We use a static 32-character key for AES-256 for demonstration purposes.
  static final String _keyString = 'my32lengthsupersecretnooneknows1'; // 32 chars
  
  static final _key = encrypt.Key.fromUtf8(_keyString);
  // IV must be 16 bytes.
  static final _iv = encrypt.IV.fromLength(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));

  /// Encrypts a plain text string using AES-256
  static String encryptText(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      print('Encryption error: $e');
      return plainText; // Fallback to plain text if error occurs (optional, but safer to return empty or error in strict systems)
    }
  }

  /// Decrypts an encrypted base64 string using AES-256
  static String decryptText(String encryptedText) {
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      // If decryption fails (e.g., old unencrypted message), return the original text
      return encryptedText; 
    }
  }
}
