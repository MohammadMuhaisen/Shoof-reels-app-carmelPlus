import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/token_storage.dart';
import 'auth_models.dart';
import 'auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final tokenStorageProvider = Provider((ref) => TokenStorage());

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

/// Holds who is logged in for the whole app: an [AuthSession], or null.
class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    final storage = ref.read(tokenStorageProvider);
    final token = await storage.read();
    if (token == null) {
      return null;
    }

    try {
      final user = await ref.read(authRepositoryProvider).currentUser(token);
      return AuthSession(user: user, token: token);
    } on ApiException catch (e) {
      // The saved token was deleted on the server (logged out elsewhere).
      if (e.statusCode == 401) {
        await storage.clear();
        return null;
      }
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final session = await ref
        .read(authRepositoryProvider)
        .register(name: name, email: email, password: password, role: role);
    await ref.read(tokenStorageProvider).save(session.token);
    state = AsyncData(session);
  }

  Future<void> login({required String email, required String password}) async {
    final session = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    await ref.read(tokenStorageProvider).save(session.token);
    state = AsyncData(session);
  }

  Future<void> logout() async {
    final session = state.value;
    if (session != null) {
      try {
        await ref.read(authRepositoryProvider).logout(session.token);
      } catch (_) {
        // Log out on the phone even if the server can't be reached.
      }
    }
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(null);
  }
}
