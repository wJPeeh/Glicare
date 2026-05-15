import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import 'auth_providers.dart';

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _run(() async {
      await _repo.signInWithEmail(email: email, password: password);
    });
  }

  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(() async {
      await _repo.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
    });
  }

  Future<bool> signInWithGoogle() {
    return _run(() async {
      await _repo.signInWithGoogle();
    });
  }

  Future<bool> signInWithFacebook() {
    return _run(() async {
      await _repo.signInWithFacebook();
    });
  }

  Future<bool> sendPasswordResetEmail(String email) {
    return _run(() => _repo.sendPasswordResetEmail(email));
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.signOut);
  }

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncValue.loading();
    try {
      await action();
      state = const AsyncValue.data(null);
      return true;
    } on AuthCancelled {
      state = const AsyncValue.data(null);
      return false;
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
      return false;
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

String describeAuthError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'Senha muito fraca. Use ao menos 6 caracteres.';
      case 'operation-not-allowed':
        return 'Provedor de login não habilitado no Firebase.';
      case 'network-request-failed':
        return 'Sem conexão. Verifique sua internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente em instantes.';
      case 'account-exists-with-different-credential':
        return 'Já existe uma conta com este e-mail usando outro provedor.';
      case 'facebook-no-token':
      case 'facebook-login-failed':
        return error.message ?? 'Falha no login do Facebook.';
      default:
        return error.message ?? 'Falha na autenticação (${error.code}).';
    }
  }
  if (error is PlatformException) {
    final code = error.code.toLowerCase();
    if (code.contains('network')) {
      return 'Sem conexão. Verifique sua internet.';
    }
    if (code.contains('cancel')) {
      return 'Login cancelado.';
    }
    if (code == 'sign_in_failed' ||
        code == '12500' ||
        code == '10' ||
        code == 'developer_error') {
      return 'Falha no login com Google. Verifique a configuração do app (SHA-1, OAuth client).';
    }
    return error.message ?? 'Falha no login social (${error.code}).';
  }
  return 'Erro inesperado: $error';
}
