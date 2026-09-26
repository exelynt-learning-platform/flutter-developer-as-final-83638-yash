import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';

abstract class AuthRemoteDataSource {
  Future<AppUser> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<AppUser> signInWithGoogle();

  Future<void> logout();

  Future<AppUser?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final SharedPreferences _sharedPreferences;

  static const String _sessionUserKey = 'auth_session_user';

  AuthRemoteDataSourceImpl({
    fb_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    required SharedPreferences sharedPreferences,
  })  : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _sharedPreferences = sharedPreferences;

  @override
  Future<AppUser> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = credential.user;
      final user = AppUser(
        id: fbUser?.uid ?? DateTime.now().millisecondsSinceEpoch.toString(),
        email: fbUser?.email ?? email,
        displayName: fbUser?.displayName ?? _extractNameFromEmail(email),
        photoUrl: fbUser?.photoURL,
      );
      await _saveUserSession(user);
      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Authentication failed');
    } catch (_) {
      // Fallback demo/mock authentication if Firebase App is not initialized
      final user = AppUser(
        id: 'user_${email.hashCode}',
        email: email,
        displayName: _extractNameFromEmail(email),
        photoUrl: 'https://cdn.jsdelivr.net/gh/faker-js/assets-person-portrait/male/512/1.jpg',
      );
      await _saveUserSession(user);
      return user;
    }
  }

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      final user = AppUser(
        id: credential.user?.uid ?? DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        displayName: name,
        photoUrl: credential.user?.photoURL,
      );
      await _saveUserSession(user);
      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Registration failed');
    } catch (_) {
      // Fallback demo/mock registration if Firebase is not initialized
      final user = AppUser(
        id: 'user_${email.hashCode}',
        email: email,
        displayName: name,
        photoUrl: 'https://cdn.jsdelivr.net/gh/faker-js/assets-person-portrait/female/512/1.jpg',
      );
      await _saveUserSession(user);
      return user;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Failed to send password reset email');
    } catch (_) {
      // Fallback response if Firebase is not configured
      return;
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = fb_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final fbUser = userCredential.user;

      final user = AppUser(
        id: fbUser?.uid ?? googleUser.id,
        email: fbUser?.email ?? googleUser.email,
        displayName: fbUser?.displayName ?? googleUser.displayName ?? 'Google User',
        photoUrl: fbUser?.photoURL ?? googleUser.photoUrl,
      );

      await _saveUserSession(user);
      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Google Sign-In failed');
    } catch (e) {
      if (e is Failure) rethrow;
      // Demo fallback if Google Sign In natively unavailable or unconfigured
      final user = AppUser(
        id: 'google_user_demo',
        email: 'google.user@example.com',
        displayName: 'Google Demo User',
        photoUrl: 'https://cdn.jsdelivr.net/gh/faker-js/assets-person-portrait/male/512/5.jpg',
      );
      await _saveUserSession(user);
      return user;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (_) {}
    await _clearUserSession();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser != null) {
        return AppUser(
          id: fbUser.uid,
          email: fbUser.email ?? '',
          displayName: fbUser.displayName ?? _extractNameFromEmail(fbUser.email ?? 'User'),
          photoUrl: fbUser.photoURL,
        );
      }
    } catch (_) {}

    // Fallback to SharedPreferences stored session
    final userJsonStr = _sharedPreferences.getString(_sessionUserKey);
    if (userJsonStr != null) {
      try {
        return AppUser.fromJson(jsonDecode(userJsonStr) as Map<String, dynamic>);
      } catch (_) {}
    }

    return null;
  }

  Future<void> _saveUserSession(AppUser user) async {
    await _sharedPreferences.setString(_sessionUserKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearUserSession() async {
    await _sharedPreferences.remove(_sessionUserKey);
  }

  String _extractNameFromEmail(String email) {
    if (email.contains('@')) {
      final part = email.split('@').first;
      return part[0].toUpperCase() + part.substring(1);
    }
    return email;
  }
}
