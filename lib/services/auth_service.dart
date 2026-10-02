import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  final ApiClient _api = ApiClient.instance;

  User? get currentUser =>
      _api.currentUser != null ? User.fromJson(_api.currentUser!) : null;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _api.post('/auth/login', body: {
      'email': email.trim(),
      'password': password,
    });

    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    _api.setSession(token, user);

    return data;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = await _api.post('/auth/register', body: {
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'password': password,
    });

    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    _api.setSession(token, user);

    return data;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final data = await _api.get('/users/me');
    return data as Map<String, dynamic>;
  }

  void logout() {
    _api.clearSession();
  }
}
