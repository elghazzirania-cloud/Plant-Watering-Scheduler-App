import 'dart:convert';
import 'package:http/http.dart' as http;
import '../plant.dart';

class ApiService {
  static const String baseUrl = 'http://plantswatering.atwebpages.com';

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'An error occurred');
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final body = Uri(
        queryParameters: {'email': email, 'password': password},
      ).query;

      final response = await http
          .post(
            Uri.parse('$baseUrl/login.php'),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout. Please check your internet connection.',
              );
            },
          );

      final data = _handleResponse(response);
      if (data['status'] == 'success') {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Failed to fetch')) {
        throw Exception(
          'Cannot connect to server. Please check:\n1. PHP files are uploaded to AwardSpace\n2. URL is correct: $baseUrl\n3. Internet connection is working',
        );
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> signup(
    String username,
    String email,
    String password,
  ) async {
    try {
      // Encode form data properly
      final body = Uri(
        queryParameters: {
          'username': username,
          'email': email,
          'password': password,
        },
      ).query;

      final response = await http
          .post(
            Uri.parse('$baseUrl/signup.php'),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout. Please check your internet connection.',
              );
            },
          );

      final data = _handleResponse(response);
      if (data['status'] == 'success') {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Signup failed');
      }
    } catch (e) {
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Failed to fetch')) {
        throw Exception(
          'Cannot connect to server. Please check:\n1. PHP files are uploaded to AwardSpace\n2. URL is correct: $baseUrl\n3. Internet connection is working',
        );
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<List<Plant>> getPlants(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_plants.php?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Plant.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load plants');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<int> addPlant({
    required int userId,
    required String name,
    required String type,
    required DateTime lastWatered,
    required int wateringIntervalDays,
    required String notes,
    required String color,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_plant.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'user_id': userId.toString(),
          'name': name,
          'type': type,
          'last_watered': _formatDateTime(lastWatered),
          'watering_interval_days': wateringIntervalDays.toString(),
          'notes': notes,
          'color': color,
        },
      );

      final data = _handleResponse(response);
      if (data['status'] == 'success') {
        return data['plant_id'] as int;
      } else {
        throw Exception(data['message'] ?? 'Failed to add plant');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<void> waterPlant(int plantId, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/water_plant.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'plant_id': plantId.toString(),
          'user_id': userId.toString(),
          'timestamp': _formatDateTime(DateTime.now()),
        },
      );

      final data = _handleResponse(response);
      if (data['status'] != 'success') {
        throw Exception(data['message'] ?? 'Failed to update plant');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<void> deletePlant(int plantId, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_plant.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'plant_id': plantId.toString(), 'user_id': userId.toString()},
      );

      final data = _handleResponse(response);
      if (data['status'] != 'success') {
        throw Exception(data['message'] ?? 'Failed to delete plant');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
