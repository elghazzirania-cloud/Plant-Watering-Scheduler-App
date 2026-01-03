import 'dart:convert';
import 'package:http/http.dart' as http;
import '../plant.dart';

class ApiService {
  
  static const String baseUrl = 'http://plantswatering.atwebpages.com';


  static String _formatDateTime(DateTime dt) {
    
    String two(int n) => n.toString().padLeft(2, '0');
   
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }

  static Future<Map<String, dynamic>> _post(String path, Map<String, String> body) async {
   
    final uri = Uri.parse('$baseUrl/$path');
    
    final response = await http
        .post(uri, headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: body)
        .timeout(const Duration(seconds: 30));

   
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
  
    throw Exception('Server error: ${response.statusCode}');
  }


  static Future<Map<String, dynamic>> login(String email, String password) async {
   
    final data = await _post('login.php', {'email': email, 'password': password});
    
    if (data['status'] == 'success') return data;
    
    throw Exception(data['message'] ?? 'Login failed');
  }

  
  static Future<Map<String, dynamic>> signup(String username, String email, String password) async {
  
    final data = await _post('signup.php', {'username': username, 'email': email, 'password': password});
    
    if (data['status'] == 'success') return data;
    throw Exception(data['message'] ?? 'Signup failed');
  }


  static Future<List<Plant>> getPlants(int userId) async {
   
    final uri = Uri.parse('$baseUrl/get_plants.php?user_id=$userId');
    
    final response = await http.get(uri);
    
    if (response.statusCode != 200) throw Exception('Failed to load plants');
   
    final List<dynamic> list = json.decode(response.body);
   
    return list.map((j) => Plant.fromJson(j)).toList();
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
    
    final data = await _post('add_plant.php', {
      'user_id': userId.toString(),
      'name': name,
      'type': type,
      'last_watered': _formatDateTime(lastWatered),
      'watering_interval_days': wateringIntervalDays.toString(),
      'notes': notes,
      'color': color,
    });
    
    if (data['status'] == 'success') return data['plant_id'] as int;
    
    throw Exception(data['message'] ?? 'Failed to add plant');
  }

  
  static Future<void> waterPlant(int plantId, int userId) async {
  
    final data = await _post('water_plant.php', {
      'plant_id': plantId.toString(),
      'user_id': userId.toString(),
      'timestamp': _formatDateTime(DateTime.now()),
    });
  
    if (data['status'] != 'success') throw Exception(data['message'] ?? 'Failed to update plant');
  }

 
  static Future<void> deletePlant(int plantId, int userId) async {
   
    final data = await _post('delete_plant.php', {'plant_id': plantId.toString(), 'user_id': userId.toString()});
   
    if (data['status'] != 'success') throw Exception(data['message'] ?? 'Failed to delete plant');
  }
}
