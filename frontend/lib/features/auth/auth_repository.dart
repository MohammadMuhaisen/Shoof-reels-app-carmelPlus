import '../../core/api_client.dart';
import 'auth_models.dart';

class AuthRepository {
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final data = await ApiClient().post('/register', {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
    return AuthSession.fromJson(data);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await ApiClient().post('/login', {
      'email': email,
      'password': password,
    });
    return AuthSession.fromJson(data);
  }

  Future<User> currentUser(String token) async {
    final data = await ApiClient(token: token).get('/user');
    return User.fromJson(data);
  }

  Future<void> logout(String token) async {
    await ApiClient(token: token).post('/logout');
  }
}
