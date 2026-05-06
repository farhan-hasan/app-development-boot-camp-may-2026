import 'package:hisabi/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
  Future<AppUser> signInWithEmailPassword(String email, String password);
  Future<AppUser> signUpWithEmailPassword(String email, String password, String name);
  Future<AppUser> signInWithGoogle();
  Future<void> signOut();
}
