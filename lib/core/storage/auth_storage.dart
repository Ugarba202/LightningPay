import 'package:shared_preferences/shared_preferences.dart';
import '../service/currency_mapper.dart';

class AuthStorage {
  static const _kEmail = 'registered_email';
  static const _kPin = 'login_pin';

  // Transaction PIN and biometric keys
  static const _kTransactionPin = 'transaction_pin';
  static const _kBiometricsEnabled = 'biometrics_enabled';
  static const _kNeedTransactionSetup = 'need_transaction_setup';

  /// Save a user's email and pin locally (for mock login in absence of backend)
  static Future<void> saveCredentials(String email, String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmail, email);
    await prefs.setString(_kPin, pin);
  }

  static Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kEmail);
  }

  static Future<String?> getSavedPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPin);
  }

  // ----------------------
  // Profile fields (name, username, country, phone, recovery)
  // ----------------------
  static const _kFullName = 'full_name';
  static const _kUsername = 'username';
  static const _kCountry = 'country';
  static const _kPhone = 'phone_number';
  static const _kRecoveryPhrase = 'recovery_phrase';

  static Future<void> saveFullName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFullName, name);
  }

  static Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kFullName);
  }

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsername, username);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUsername);
  }

  static Future<void> saveCountry(String country) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCountry, country);
  }

  static Future<String?> getCountry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kCountry);
  }

  static Future<String> getCurrency() async {
    final country = await getCountry();
    if (country == null) return 'USD';
    return CurrencyMapper.fromCountry(country);
  }

  static Future<void> savePhoneNumber(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPhone, phone);
  }

  static Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPhone);
  }

  static Future<void> saveRecoveryPhrase(String phrase) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRecoveryPhrase, phrase);
  }

  static Future<String?> getRecoveryPhrase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRecoveryPhrase);
  }

  // ----------------------
  // Profile image helpers
  // ----------------------
  static const _kProfileImagePath = 'profile_image_path';

  static Future<void> saveProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfileImagePath, path);
  }

  static Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kProfileImagePath);
  }

  static Future<void> removeProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kProfileImagePath);
  }

  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_kEmail);
    final pin = prefs.getString(_kPin);
    return email != null && pin != null;
  }

  // ----------------------
  // Transaction PIN helpers
  // ----------------------
  static Future<void> saveTransactionPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTransactionPin, pin);
  }

  static Future<String?> getSavedTransactionPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTransactionPin);
  }

  static Future<void> clearTransactionPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTransactionPin);
  }

  // ----------------------
  // Biometrics flag
  // ----------------------
  static Future<void> setBiometricsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometricsEnabled, enabled);
  }

  static Future<bool> isBiometricsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kBiometricsEnabled) ?? false;
  }

  // ----------------------
  // First-run transaction setup
  // ----------------------
  static Future<void> markNeedTransactionSetup(bool need) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNeedTransactionSetup, need);
  }

  static Future<bool> needsTransactionSetup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kNeedTransactionSetup) ?? false;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEmail);
    await prefs.remove(_kPin);
    await prefs.remove(_kTransactionPin);
    await prefs.remove(_kBiometricsEnabled);
    await prefs.remove(_kNeedTransactionSetup);
  }
}
