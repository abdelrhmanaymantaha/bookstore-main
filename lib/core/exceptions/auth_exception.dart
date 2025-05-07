class AuthException implements Exception {
  final String code;
  final String message;

  AuthException(this.code, this.message);

  factory AuthException.fromFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return AuthException(code, 'This email is already in use.');
      case 'invalid-email':
        return AuthException(code, 'The email address is not valid.');
      case 'user-not-found':
        return AuthException(code, 'No user found for this email.');
      case 'wrong-password':
        return AuthException(code, 'The password is incorrect.');
      case 'too-many-requests':
        return AuthException(code, 'Too many requests. Try again later.');
      case 'operation-not-allowed':
        return AuthException(code, 'This operation is not allowed.');
      case 'weak-password':
        return AuthException(code, 'The password is too weak.');
      case 'network-request-failed':
        return AuthException(code, 'Network error occurred.');
      default:
        return AuthException(code, 'An unknown error occurred.');
    }
  }

  @override
  String toString() => message;
}
