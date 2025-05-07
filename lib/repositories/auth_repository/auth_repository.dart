import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bookstore_app/core/exceptions/auth_exception.dart';
import 'package:bookstore_app/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository()
      : _firebaseAuth = FirebaseAuth.instance,
        _firebaseFirestore = FirebaseFirestore.instance,
        _googleSignIn = GoogleSignIn(
          serverClientId:
              '237674666615-71sollbgtsirhqmd6mfe9c87sle2rp6f.apps.googleusercontent.com',
          scopes: ['email', 'profile'],
        ) {
    print('AuthRepository initialized');
    print('Firebase Project ID: ${_firebaseAuth.app.options.projectId}');
    print('Firebase Auth Instance: ${_firebaseAuth.app.name}');
    print('Firebase Auth Current User: ${_firebaseAuth.currentUser}');
    print(
        'Firebase Auth Current User Email: ${_firebaseAuth.currentUser?.email}');
  }

  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      print('Starting sign up process...');
      print('Email: $email');
      print('Username: $username');

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      print('Firebase Auth User created with UID: ${user?.uid}');

      if (user == null) {
        print('User creation failed - user is null');
        throw AuthException('user-creation-failed', 'User creation failed.');
      }

      await user.updateDisplayName(username);
      print('Display name updated in Firebase Auth');

      final userModel = UserModel(
        uid: user.uid,
        username: username,
        email: email,
      );

      await _firebaseFirestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson());

      print('User data successfully saved to Firestore');
      return true;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw AuthException.fromFirebaseError(e.code);
    } catch (e) {
      print('Unexpected error during sign up: $e');
      throw AuthException(
          'signup-failed', 'An unexpected error occurred during sign up.');
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Starting sign in process...');
      print('Email: $email');

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      print('Firebase Auth User signed in with UID: ${user?.uid}');

      if (user == null) {
        print('Login failed - user is null');
        throw AuthException('login-failed', 'Login failed.');
      }

      final doc =
          await _firebaseFirestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        print('User not found in Firestore, creating default user data...');
        final userData = {
          'uid': user.uid,
          'email': user.email,
          'username': user.displayName ?? user.email?.split('@')[0] ?? 'User',
        };

        await _firebaseFirestore
            .collection('users')
            .doc(user.uid)
            .set(userData);

        if (user.displayName == null || user.displayName!.isEmpty) {
          await user.updateDisplayName(userData['username']);
          print('Display name updated in Firebase Auth');
        }

        print('Default user data created in Firestore');
      } else {
        final userData = doc.data() as Map<String, dynamic>;
        if (user.displayName != userData['username']) {
          await user.updateDisplayName(userData['username']);
          print('Display name updated in Firebase Auth to match Firestore');
        }
      }

      print('Sign in successful');
      return true;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw AuthException.fromFirebaseError(e.code);
    } catch (e) {
      print('Unexpected error during sign in: $e');
      throw AuthException(
          'signin-failed', 'An unexpected error occurred during sign in.');
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      print('Starting password reset process...');
      print('Email: $email');

      await _firebaseAuth.sendPasswordResetEmail(email: email);
      print('Password reset email sent successfully');

      return true;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw AuthException.fromFirebaseError(e.code);
    } catch (e) {
      print('Unexpected error during password reset: $e');
      throw AuthException('reset-failed',
          'An unexpected error occurred during password reset.');
    }
  }

  Future<void> signOut() async {
    try {
      print('Starting sign out process...');
      print('Current User before sign out: ${_firebaseAuth.currentUser?.uid}');
      await _firebaseAuth.signOut();
      print('Sign out successful');
      print('Current User after sign out: ${_firebaseAuth.currentUser?.uid}');
    } catch (e) {
      print('Error during sign out: $e');
      throw AuthException(
          'signout-failed', 'An error occurred during sign out.');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google sign in process...');
      print('Google Sign In Configuration:');
      print('Server Client ID: ${_googleSignIn.serverClientId}');
      print('Scopes: ${_googleSignIn.scopes}');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('Google User: ${googleUser?.email}');

      if (googleUser == null) {
        print('Google Sign In was canceled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print(
          'Google Auth Token: ${googleAuth.accessToken?.substring(0, 10)}...');
      print('Google Auth ID Token: ${googleAuth.idToken?.substring(0, 10)}...');

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('Google Auth tokens are null');
        throw AuthException(
            'google-sign-in-failed', 'Failed to get Google auth tokens');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      print('Firebase Auth User: ${userCredential.user?.uid}');
      print('Firebase Auth User Email: ${userCredential.user?.email}');
      print(
          'Firebase Auth User Display Name: ${userCredential.user?.displayName}');
      print(
          'Firebase Auth User Email Verified: ${userCredential.user?.emailVerified}');

      final userDoc = await _firebaseFirestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      if (!userDoc.exists) {
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          username: userCredential.user!.displayName ??
              userCredential.user!.email!.split('@')[0],
          email: userCredential.user!.email!,
        );

        await _firebaseFirestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toJson());
        print('Created new user document in Firestore');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error:');
      print('Error Code: ${e.code}');
      print('Error Message: ${e.message}');
      print('Error Details: $e');
      throw AuthException.fromFirebaseError(e.code);
    } catch (e, stackTrace) {
      print('Unexpected Error:');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      throw AuthException('google-sign-in-failed',
          'An unexpected error occurred during Google sign in');
    }
  }
}
