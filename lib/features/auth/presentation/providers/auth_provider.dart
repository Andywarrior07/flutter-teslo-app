import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/auth/domain/domain.dart';
import 'package:teslo_shop/features/auth/infraestructure/infraestructure.dart';
import 'package:teslo_shop/features/shared/infrastructure/services/storage_service.dart';
import 'package:teslo_shop/features/shared/infrastructure/services/storage_service_impl.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final storageService = StorageServiceImpl();

  return AuthNotifier(
      authRepository: authRepository, storageService: storageService);
});

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;

  AuthState({
    this.authStatus = AuthStatus.checking,
    this.errorMessage = '',
    this.user,
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage,
  }) =>
      AuthState(
        authStatus: authStatus ?? this.authStatus,
        errorMessage: errorMessage ?? this.errorMessage,
        user: user ?? this.user,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final StorageService storageService;

  AuthNotifier({required this.authRepository, required this.storageService})
      : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final user = await authRepository.login(email, password);
      _setLoggedUser(user);
    } on CustomError catch (e) {
      logout(e.message);
    } catch (e) {
      logout('Something went wrong');
    }
  }

  void register(String email, String password) async {}

  void checkAuthStatus() async {
    final token = await storageService.read<String>('token');

    if (token == null) {
      return logout();
    }

    try {
      final user = await authRepository.checkAuthStatus(token);
      _setLoggedUser(user);
    } catch (e) {
      logout();
    }
  }

  Future<void> logout([String? errorMessage]) async {
    await storageService.delete('token');

    state = state.copyWith(
      user: null,
      authStatus: AuthStatus.unauthenticated,
      errorMessage: errorMessage,
    );
  }

  void _setLoggedUser(User user) async {
    await storageService.write('token', user.token);

    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: '',
    );
  }
}
