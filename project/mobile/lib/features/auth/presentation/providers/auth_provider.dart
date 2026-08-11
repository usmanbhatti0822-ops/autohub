import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/app_user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AppUser? user;

  const AuthState({required this.status, this.user});

  const AuthState.unknown() : this(status: AuthStatus.unknown);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);
  const AuthState.authenticated(AppUser user)
      : this(status: AuthStatus.authenticated, user: user);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState.unknown()) {
    _init();
  }

  Future<void> _init() async {
    final user = await _repo.fetchCurrentUser();
    state = user != null
        ? AuthState.authenticated(user)
        : const AuthState.unauthenticated();
  }

  /// Returns the dev OTP code (non-null only outside production) so the
  /// UI can prefill it during testing without a real SMS gateway.
  Future<String?> requestOtp(String phone) => _repo.requestOtp(phone);

  Future<void> verifyOtp(String phone, String code) async {
    final user = await _repo.verifyOtp(phone, code);
    state = AuthState.authenticated(user);
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final user = await _repo.register(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
    );
    state = AuthState.authenticated(user);
  }

  Future<void> login({required String email, required String password}) async {
    final user = await _repo.login(email: email, password: password);
    state = AuthState.authenticated(user);
  }

  Future<String?> forgotPassword(String email) => _repo.forgotPassword(email);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final user = await _repo.resetPassword(email: email, code: code, newPassword: newPassword);
    state = AuthState.authenticated(user);
  }

  Future<void> updateProfile({String? fullName, String? email, String? city, String? avatarUrl}) async {
    final user = await _repo.updateProfile(
      fullName: fullName,
      email: email,
      city: city,
      avatarUrl: avatarUrl,
    );
    state = AuthState.authenticated(user);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState.unauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
