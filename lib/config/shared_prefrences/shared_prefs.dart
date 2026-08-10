

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';



@injectable
class SharedPrefsUtils {
  // Future<void> saveUser(AppUser user) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var json = user.toJson();
  //   prefs.setString("user", jsonEncode(json));
  // }

  Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token);
  }

  // Future<AppUser?> getUser() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? userString = prefs.getString("user");
  //   if (userString == null) return null;
  //   Map <String, dynamic>json = jsonDecode(userString);
  //   return AppUser.fromJson(json);
  // }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

}
