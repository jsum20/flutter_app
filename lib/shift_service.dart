import 'package:http/http.dart' as http;
import 'dart:convert';

class ShiftService {
  static Future<List<dynamic>> fetchShifts() async {
    final response = await http.get(Uri.parse(
        'https://flutter-test-five.vercel.app/api/shifts/user'
    ));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load shifts');
    }
  }
}