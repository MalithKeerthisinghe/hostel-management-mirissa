import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const String userId = 'userId';

  //save user id
  Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userId, id);
  }

  //get user id
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userId);
  }
}
