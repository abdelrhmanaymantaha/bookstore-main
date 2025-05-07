import 'package:bookstore_app/core/exceptions/auth_exception.dart';
import 'package:bookstore_app/models/user_model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositroy {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;
  final GoogleSignIn _googleSignIn;

  AuthRepositroy()
      : _firebaseAuth = FirebaseAuth.instance,
        _firebaseFirestore = FirebaseFirestore.instance,
        _googleSignIn = GoogleSignIn() {
    print('AuthRepository initialized');
    print('Firebase Project ID: ${_firebaseFirestore.app.options.projectId}');
    print('Firebase Auth Instance: ${_firebaseAuth.app.name}');
    print('Firebase Auth Current User: ${_firebaseAuth.currentUser?.uid}');
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
      print('Firebase Project ID: ${_firebaseFirestore.app.options.projectId}');
      print('Firebase Auth Instance: ${_firebaseAuth.app.name}');

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      print('Firebase Auth User created with UID: ${user?.uid}');
      print('User Email: ${user?.email}');
      print('User Email Verified: ${user?.emailVerified}');

      if (user == null) {
        print('User creation failed - user is null');
        throw AuthException('user-creation-failed', 'User creation failed.');
      }

      // Update the display name in Firebase Auth
      await user.updateDisplayName(username);
      print('Display name updated in Firebase Auth');

      final userModel = UserModel(
        uid: user.uid,
        username: username,
        email: email,
      );

      print('Attempting to save user data to Firestore...');
      print('Collection: users');
      print('Document ID: ${user.uid}');
      print('User Data: ${userModel.toJson()}');

      await _firebaseFirestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson());

      print('User data successfully saved to Firestore');
      return true;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      print('Error Details: ${e.toString()}');
      throw AuthException.fromFirebaseError(e.code);
    } catch (e) {
      print('Unexpected error during sign up: $e');
      print('Error Stack Trace: ${StackTrace.current}');
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
      print('Firebase Project ID: ${_firebaseFirestore.app.options.projectId}');
      print('Current Firebase Auth Instance: ${_firebaseAuth.app.name}');
      print('Current Firebase Auth User: ${_firebaseAuth.currentUser?.uid}');

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      print('Firebase Auth User signed in with UID: ${user?.uid}');
      print('User Email: ${user?.email}');
      print('User Email Verified: ${user?.emailVerified}');
      print('User Display Name: ${user?.displayName}');

      if (user == null) {
        print('Login failed - user is null');
        throw AuthException('login-failed', 'Login failed.');
      }

      print('Checking Firestore for user data...');
      final doc =
          await _firebaseFirestore.collection('users').doc(user.uid).get();
      print('Firestore document exists: ${doc.exists}');
      print('Firestore document data: ${doc.data()}');
      print('Firestore document ID: ${doc.id}');
      print('Firestore document path: ${doc.reference.path}');

      if (!doc.exists) {
        print('User not found in Firestore, creating default user data...');
        // Create default user data
        final userData = {
          'uid': user.uid,
          'email': user.email,
          'username': user.displayName ?? user.email?.split('@')[0] ?? 'User',
        };

        await _firebaseFirestore
            .collection('users')
            .doc(user.uid)
            .set(userData);

        // Update display name in Firebase Auth if not set
        if (user.displayName == null || user.displayName!.isEmpty) {
          await user.updateDisplayName(userData['username']);
          print('Display name updated in Firebase Auth');
        }

        print('Default user data created in Firestore');
      } else {
        // Update display name in Firebase Auth if it doesn't match Firestore
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
      print('Error Details: ${e.toString()}');
      throw AuthException.fromFirebaseError(e.code);
    } catch (e) {
      print('Unexpected error during sign in: $e');
      print('Error Stack Trace: ${StackTrace.current}');
      throw AuthException(
          'signin-failed', 'An unexpected error occurred during sign in.');
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      print('Starting password reset process...');
      print('Email: $email');
      print('Firebase Project ID: ${_firebaseFirestore.app.options.projectId}');
      print('Current Firebase Auth Instance: ${_firebaseAuth.app.name}');

      await _firebaseAuth.sendPasswordResetEmail(email: email);
      print('Password reset email sent successfully');

      return true;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      print('Error Details: ${e.toString()}');
      throw AuthException.fromFirebaseError(e.code);
    } catch (e) {
      print('Unexpected error during password reset: $e');
      print('Error Stack Trace: ${StackTrace.current}');
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
      print('Error Stack Trace: ${StackTrace.current}');
      throw AuthException(
          'signout-failed', 'An error occurred during sign out.');
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      print('Starting Google sign in process...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google sign in was cancelled by user');
        throw AuthException(
            'google-signin-cancelled', 'Google sign in was cancelled.');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        print('Google sign in failed - user is null');
        throw AuthException('google-signin-failed', 'Google sign in failed.');
      }

      print('Google sign in successful');
      print('User UID: ${user.uid}');
      print('User Email: ${user.email}');
      print('User Display Name: ${user.displayName}');

      // Check if user exists in Firestore
      final doc =
          await _firebaseFirestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        print('Creating new user document in Firestore...');
        final userModel = UserModel(
          uid: user.uid,
          username: user.displayName ?? user.email?.split('@')[0] ?? 'User',
          email: user.email ?? '',
        );

        await _firebaseFirestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson());

        print('New user document created in Firestore');
      }

      return true;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      print('Error Details: ${e.toString()}');
      throw AuthException.fromFirebaseError(e.code);
    } catch (e) {
      print('Unexpected error during Google sign in: $e');
      print('Error Stack Trace: ${StackTrace.current}');
      throw AuthException('google-signin-failed',
          'An unexpected error occurred during Google sign in.');
    }
  }
}
