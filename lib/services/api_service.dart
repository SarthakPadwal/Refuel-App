import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class ApiService {
  static const String baseUrl = 'http://192.168.0.101:5000/api/auth';

  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: await getHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _saveAuthData(data);
    }

    return response;
  }

  static Future<http.Response> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveAuthData(data);
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
      }
      return response;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  static Future<void> _saveAuthData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString('token', data['token']),
        prefs.setString('user', jsonEncode(data['user'])),
      ]);
      print('Auth data saved successfully');
    } catch (e) {
      print('Error saving auth data: $e');
      rethrow;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('Retrieved token: $token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }


  static Future<String> getCrowdLevelMultiDirection({
    required double lat,
    required double lng,
    required String apiKey,
  }) async {
    final offsets = [
      [0.0009, 0.0],   // ~100m North
      [-0.0009, 0.0],  // ~100m South
      [0.0, 0.0009],   // ~100m East
      [0.0, -0.0009],  // ~100m West

    ];

    int totalDelay = 0;
    int validRoutes = 0;

    for (final offset in offsets) {
      final originLat = lat + offset[0];
      final originLng = lng + offset[1];

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json'
            '?origins=$originLat,$originLng'
            '&destinations=$lat,$lng'
            '&departure_time=now'
            '&traffic_model=best_guess'
            '&mode=driving'
            '&key=$apiKey',
      );

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final elements = data['rows']?[0]?['elements']?[0];

          if (elements != null &&
              elements['status'] == 'OK' &&
              elements['duration'] != null) {
            final int duration = elements['duration']['value'];
            final int durationInTraffic = elements['duration_in_traffic']?['value'] ?? duration;

            final int delay = durationInTraffic - duration;
            totalDelay += delay;
            validRoutes++;
          } else {
            print("❗ No valid element for $originLat,$originLng → $lat,$lng");
          }
        } else {
          print("❌ API error ${response.statusCode} for $originLat,$originLng");
        }
      } catch (e) {
        print("❌ Exception during Distance Matrix call: $e");
      }
    }

    if (validRoutes == 0) {
      print("❌ No valid routes. Returning 'unknown'.");
      return 'unknown';
    }

    final int avgDelay = totalDelay ~/ validRoutes;
    print("✅ Avg delay from $validRoutes routes: $avgDelay sec");

    if (avgDelay < 30) return 'green';
    if (avgDelay < 90) return 'yellow';
    if (avgDelay < 180) return 'orange';
    return 'red';
  }

  /// Parses ISO duration strings like "30s", "2m5s", etc. into seconds
  static int _parseDuration(String durationString) {
    final regex = RegExp(r'(?:(\d+)m)?(?:(\d+)s)?');
    final match = regex.firstMatch(durationString);
    if (match == null) return 0;

    final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(2) ?? '0') ?? 0;

    return minutes * 60 + seconds;
  }
}
