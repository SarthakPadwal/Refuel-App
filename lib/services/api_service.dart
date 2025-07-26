import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<http.Response> register(
      String name,
      String email,
      String password,
      ) async {
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

  /// 🔥 Traditional 1-to-1 delay based method (optional)
  static Future<String> getCrowdLevel({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required String apiKey,
  }) async {
    final url = Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask': 'routes.duration,routes.durationInTraffic',
      },
      body: jsonEncode({
        "origin": {
          "location": {"latLng": {"latitude": originLat, "longitude": originLng}}
        },
        "destination": {
          "location": {"latLng": {"latitude": destLat, "longitude": destLng}}
        },
        "travelMode": "DRIVE",
        "routingPreference": "TRAFFIC_AWARE_OPTIMAL",
        "departureTime": DateTime.now().toUtc().toIso8601String(),
        "trafficModel": "BEST_GUESS",
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final duration = _parseDuration(data['routes'][0]['duration']);
      final trafficDuration = _parseDuration(data['routes'][0]['durationInTraffic']);

      final delay = trafficDuration - duration;

      if (delay < 30) {
        return 'green';
      } else if (delay < 90) {
        return 'yellow';
      } else if (delay < 180) {
        return 'orange';
      } else {
        return 'red';
      }
    } else {
      print("Traffic API error: ${response.statusCode} - ${response.body}");
      return 'unknown';
    }
  }

  static int _parseDuration(String durationStr) {
    final regex = RegExp(r'(\d+)s');
    final match = regex.firstMatch(durationStr);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  /// 🔥🔥 Multi-Directional Traffic Check (better for petrol pumps)
  static Future<String> getCrowdLevelMultiDirection({
    required double lat,
    required double lng,
    required String apiKey,
  }) async {
    final offsets = [
      [0.003, 0.0],   // North (~300m)
      [-0.003, 0.0],  // South
      [0.0, 0.003],   // East
      [0.0, -0.003],  // West
    ];

    int totalDelay = 0;
    int validRoutes = 0;

    for (final offset in offsets) {
      final originLat = lat + offset[0];
      final originLng = lng + offset[1];

      final url = Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask': 'routes.duration,routes.durationInTraffic',
        },
        body: jsonEncode({
          "origin": {
            "location": {"latLng": {"latitude": originLat, "longitude": originLng}}
          },
          "destination": {
            "location": {"latLng": {"latitude": lat, "longitude": lng}}
          },
          "travelMode": "DRIVE",
          "routingPreference": "TRAFFIC_AWARE_OPTIMAL",
          "departureTime": DateTime.now().toUtc().toIso8601String(),
          "trafficModel": "BEST_GUESS",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final duration = _parseDuration(data['routes'][0]['duration']);
        final trafficDuration = _parseDuration(data['routes'][0]['durationInTraffic']);

        final delay = trafficDuration - duration;
        totalDelay += delay;
        validRoutes++;
      } else {
        print("Skipped one direction due to API failure");
      }
    }

    if (validRoutes == 0) return 'unknown';

    final avgDelay = totalDelay ~/ validRoutes;

    if (avgDelay < 30) {
      return 'green';
    } else if (avgDelay < 90) {
      return 'yellow';
    } else if (avgDelay < 180) {
      return 'orange';
    } else {
      return 'red';
    }
  }
}
