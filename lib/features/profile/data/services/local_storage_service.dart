import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();

  static const String _prefix = 'agrokaf.profile.';
  static const String _keyUserName = '${_prefix}userName';
  static const String _keyFarmName = '${_prefix}farmName';
  static const String _keyMunicipality = '${_prefix}municipality';
  static const String _keyCoffeeVariety = '${_prefix}coffeeVariety';
  static const String _keyProfileImagePath = '${_prefix}profileImagePath';
  static const String _keyHasProfile = '${_prefix}hasProfile';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> hasSavedProfile() async {
    final SharedPreferences prefs = await _ensurePrefs();
    return prefs.getBool(_keyHasProfile) ?? false;
  }

  Future<Map<String, String?>> loadProfileFields() async {
    final SharedPreferences prefs = await _ensurePrefs();
    return <String, String?>{
      _keyUserName: prefs.getString(_keyUserName),
      _keyFarmName: prefs.getString(_keyFarmName),
      _keyMunicipality: prefs.getString(_keyMunicipality),
      _keyCoffeeVariety: prefs.getString(_keyCoffeeVariety),
      _keyProfileImagePath: prefs.getString(_keyProfileImagePath),
    };
  }

  Future<bool> saveProfileFields({
    required String userName,
    required String farmName,
    required String municipality,
    required String coffeeVariety,
    required String profileImagePath,
  }) async {
    try {
      final SharedPreferences prefs = await _ensurePrefs();
      await prefs.setString(_keyUserName, userName);
      await prefs.setString(_keyFarmName, farmName);
      await prefs.setString(_keyMunicipality, municipality);
      await prefs.setString(_keyCoffeeVariety, coffeeVariety);
      await prefs.setString(_keyProfileImagePath, profileImagePath);
      await prefs.setBool(_keyHasProfile, true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> clearProfileFields() async {
    try {
      final SharedPreferences prefs = await _ensurePrefs();
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyFarmName);
      await prefs.remove(_keyMunicipality);
      await prefs.remove(_keyCoffeeVariety);
      await prefs.remove(_keyProfileImagePath);
      await prefs.setBool(_keyHasProfile, false);
      return true;
    } catch (_) {
      return false;
    }
  }
}
