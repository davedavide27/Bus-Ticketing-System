import 'package:shared_preferences/shared_preferences.dart';

class ORNumberService {
  static const String _orNumberKey = 'or_number';

  // Get the next OR number and increment it
  static Future<String> getNextORNumber() async {
    final prefs = await SharedPreferences.getInstance();
    int orNumber = prefs.getInt(_orNumberKey) ?? 26376; // Default value if not set
    String formattedOrNumber = orNumber.toString().padLeft(6, '0'); // Format to a 6-digit string
    await prefs.setInt(_orNumberKey, orNumber + 1);
    return formattedOrNumber;
  }
}
