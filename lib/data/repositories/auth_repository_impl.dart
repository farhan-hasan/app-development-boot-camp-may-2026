import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hisabi/domain/entities/app_user.dart';
import 'package:hisabi/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl()
      : _auth = FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AppUser _fromUser(User user) => AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );

  @override
  Stream<AppUser?> get authStateChanges =>
      _auth.authStateChanges().map((u) => u != null ? _fromUser(u) : null);

  @override
  AppUser? get currentUser {
    final u = _auth.currentUser;
    return u != null ? _fromUser(u) : null;
  }

  @override
  Future<AppUser> signInWithEmailPassword(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _fromUser(cred.user!);
  }

  @override
  Future<AppUser> signUpWithEmailPassword(
      String email, String password, String name) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user!.updateDisplayName(name.trim());
    await cred.user!.sendEmailVerification();
    return _fromUser(cred.user!);
  }

  @override
  Future<AppUser> signInWithGoogle({VoidCallback? onAccountSelected}) async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('cancelled');
    onAccountSelected?.call();
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    return _fromUser(cred.user!);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }
}
