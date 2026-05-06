import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisabi/data/repositories/auth_repository_impl.dart';
import 'package:hisabi/domain/entities/app_user.dart';
import 'package:hisabi/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepositoryImpl(),
);

final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);
