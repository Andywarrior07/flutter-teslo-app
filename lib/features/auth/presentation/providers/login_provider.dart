import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:teslo_shop/features/auth/presentation/providers/auth_provider.dart';
import 'package:teslo_shop/shared/infrastructure/inputs/inputs.dart';

final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>(
  (ref) {
    final loginUserCallback = ref.watch(authProvider.notifier).login;

    return LoginFormNotifier(loginUserCallback: loginUserCallback);
  },
);

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final Function(String, String) loginUserCallback;

  LoginFormNotifier({
    required this.loginUserCallback,
  }) : super(LoginFormState());

  void onEmailChanged(String value) {
    final email = Email.dirty(value);
    state = state.copyWith(
      email: email,
      isValid: Formz.validate([email, state.password]),
    );
  }

  void onPasswordChanged(String value) {
    final password = Password.dirty(value);
    state = state.copyWith(
      password: password,
      isValid: Formz.validate([state.email, password]),
    );
  }

  void onFormSubmit() async {
    _touchEveryField();

    if (!state.isValid) return;

    state = state.copyWith(isPosting: true);

    await loginUserCallback(state.email.value, state.password.value);

    state = state.copyWith(isPosting: false);
  }

  void _touchEveryField() {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);

    state = state.copyWith(
      email: email,
      password: password,
      isFormPosted: true,
      isValid: Formz.validate([email, password]),
    );
  }
}

class LoginFormState {
  final Email email;
  final Password password;
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;

  LoginFormState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
  });

  LoginFormState copyWith({
    Email? email,
    Password? password,
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
  }) =>
      LoginFormState(
        email: email ?? this.email,
        password: password ?? this.password,
        isPosting: isPosting ?? this.isPosting,
        isFormPosted: isFormPosted ?? this.isFormPosted,
        isValid: isValid ?? this.isValid,
      );

  @override
  String toString() {
    return '''
      LoginFormState:
        email:        $email,
        password:     $password,
        isPosting:    $isPosting,
        isFormPosted: $isFormPosted,
        isValid:      $isValid
    ''';
  }
}
