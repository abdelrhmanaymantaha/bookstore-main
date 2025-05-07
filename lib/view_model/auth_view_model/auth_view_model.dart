import 'package:bookstore_app/repositories/auth_repository/provider/auth_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  FutureOr<bool> build() {
    return false;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      state = AsyncData(
        await authRepository.signUp(
          email: email,
          password: password,
          username: username,
        ),
      );

      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      state = AsyncData(
        await authRepository.signIn(
          email: email,
          password: password,
        ),
      );

      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      state = AsyncData(
        await authRepository.resetPassword(email: email),
      );
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(false);
  }

  Future<bool> signInWithGoogle() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      state = AsyncData(
        await authRepository.signInWithGoogle(),
      );
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}
