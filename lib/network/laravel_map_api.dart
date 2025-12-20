// updated by P#rateek 20th dec 2025 to use laravel map api for place search

import 'dart:convert';
import 'package:http/http.dart' as http;

class LaravelMapApi {
  static const String baseUrl = "http://127.0.0.1:8000/api"; // emulator
  // real device => http://YOUR_IP:8000/api

  static Future<List<dynamic>> searchPlace(String query) async {
    final response = await http.get(
      Uri.parse("$baseUrl/search-place?query=$query"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['predictions'];
    } else {
      throw Exception("Laravel search API failed");
    }
  }
}
