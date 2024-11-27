import 'package:intl/intl.dart';
import '../models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final String baseUrl = 'http://10.0.2.2:5000';
  bool _isAdmin = false;
  User? _user;
  String? _token;

  User? get user => _user;
  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _token != null;
  String? get token => _token;
  bool get isAuth => _token != null;

  static const String ADMIN_EMAIL = 'admin@gmail.com';

  AuthProvider() {
    _loadSavedToken();
  }

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };
  // Load saved token when app starts
  Future<void> _loadSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _isAdmin = prefs.getBool('isAdmin') ?? false;
      print('Loaded token: $_token');
      print('Is Admin: $_isAdmin');

      // Chỉ load profile nếu không phải admin
      if (_token != null && !_isAdmin) {
        await getUserProfile();
      }
      notifyListeners();
    } catch (e) {
      print('Error loading saved token: $e');
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Password changed successfully
        print('Password changed successfully');
      } else {
        throw Exception(responseData['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      print('Error changing password: $e');
      rethrow;
    }
  }

  Future<void> signUp(String name, String email, String phoneNumber,
      String password, String dateOfBirth, String address) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
          'dateOfBirth': dateOfBirth,
          'address': address,
        }),
      );

      final data = json.decode(response.body);
      print('${response.body}');

      if (response.statusCode == 201 && data['success'] == true) {
        _token = data['data']['token'];
        await _saveToken(_token!);
        await getUserProfile(); // Get user profile after successful signup
        notifyListeners();
      } else {
        throw Exception(data['message'] ?? 'Failed to sign up');
      }
    } catch (e) {
      print('Signup error: $e');
      rethrow;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);
      debugPrint('Login response raw: ${response.body}');

      if (response.statusCode == 200 && responseData['success'] == true) {
        final data = responseData['data'];
        if (data != null) {
          _token = data['token'] as String?;
          if (_token == null) throw Exception('Token not found in response');

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', _token!);

          // Xác định và xử lý admin
          if (email.trim() == ADMIN_EMAIL || data['isAdmin'] == true) {
            _isAdmin = true;
            await prefs.setBool('isAdmin', true);
            // Đối với admin, set thông tin cơ bản
            final adminData = data['user'];
            if (adminData != null) {
              _user = User.fromJson(adminData);
            } else {
              throw Exception('Admin data not found in response');
            }
          } else {
            _isAdmin = false;
            await prefs.setBool('isAdmin', false);
            final userData = data['user'];
            if (userData != null) {
              _user = User.fromJson(userData);
              await getUserProfile();
            }
          }

          debugPrint('Login successful');
          debugPrint('Token: $_token');
          debugPrint('Is Admin: $_isAdmin');
          debugPrint('User: ${_user?.email}');

          notifyListeners();
          return true;
        }
      }
      throw Exception(responseData['message'] ?? 'Login failed');
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      print('Token saved to SharedPreferences: $token');
    } catch (e) {
      print('Error saving token: $e');
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<User> getUserProfile() async {
    try {
      final token = await getToken();
      print('Getting user profile with token: $token');

      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Assume profile data is in responseData['data']
        _user = User.fromJson(responseData['data']);
        notifyListeners();
        return _user!;
      } else if (response.statusCode == 401) {
        //await signOut();
        throw Exception('Authentication failed');
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      print('Error getting profile: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(
      {required String name,
      required String imgUrl,
      required String email,
      required String address,
      required String phoneNumber,
      required DateTime dateOfBirth}) async {
    try {
      final token = await getToken();
      final dateFormatter = DateFormat('yyyy-MM-dd');
      final formattedDate = dateFormatter.format(dateOfBirth);
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'email': email,
          'name': name,
          'imgUrl': imgUrl,
          'address': address,
          'phoneNumber': phoneNumber,
          'dateOfBirth': formattedDate,
        }),
      );

      final responseData = json.decode(response.body);
      print('Update response data: $responseData'); // Debug print

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Handle successful update
        print('Profile updated successfully');
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Error updating profile in Flutter: $e'); // Debug print
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _user = null;
      _token = null;
      _isAdmin = false;
      print('Sign out completed - token cleared');
      print('Token: $_token');
      notifyListeners();
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  Future<http.Response> authenticatedRequest(
    String url, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    if (_token == null) {
      throw Exception('Not authenticated');
    }

    Uri uri = Uri.parse('$baseUrl$url');

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(uri, headers: headers);
      case 'POST':
        return await http.post(
          uri,
          headers: headers,
          body: json.encode(body),
        );
      case 'PUT':
        final response = await http.put(
          uri,
          headers: headers,
          body: json.encode(body),
        );
        debugPrint('Debug - Response Status: ${response.statusCode}');
        debugPrint('Debug - Response Body: ${response.body}');
        return response;
      case 'DELETE':
        return await http.delete(uri, headers: headers);
      default:
        throw Exception('Unsupported method');
    }
  }
}
