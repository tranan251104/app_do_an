import 'package:shared_preferences/shared_preferences.dart';

/// Remove account/session data while retaining device UI preferences.
Future<void> clearSessionPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  const deviceKeys = {
    'anpay.favorite-services.v1',
    'language',
    'locale', // easy_localization's saved locale
  };
  for (final key in prefs.getKeys().where((key) => !deviceKeys.contains(key))) {
    await prefs.remove(key);
  }
}
