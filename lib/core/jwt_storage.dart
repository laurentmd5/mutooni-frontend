import 'package:shared_preferences/shared_preferences.dart';

class JwtStorage {
  final String _key = 'jwt';

  Future<void> writeJwt(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  Future<String?> readJwt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> clearJwt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
