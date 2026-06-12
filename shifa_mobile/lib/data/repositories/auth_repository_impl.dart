import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/interfaces.dart';
import '../datasources/remote_datasource.dart';
import '../models/models.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSource;
  AppUser? _cachedUser;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AppUser?> get currentUser async {
    if (_cachedUser != null) return _cachedUser;
    
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('auth_user');
    if (userJson != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(userJson);
        _cachedUser = UserModel.fromMap(map);
        return _cachedUser;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _saveUserLocally(UserModel user) async {
    _cachedUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user', jsonEncode(user.toMap()));
  }

  @override
  Future<AppUser> login(String email, String password) async {
    final user = await remoteDataSource.login(email, password);
    await _saveUserLocally(user);
    return user;
  }

  @override
  Future<AppUser> signup(String email, String password, String name) async {
    final user = await remoteDataSource.signup(email, password, name);
    await _saveUserLocally(user);
    return user;
  }

  @override
  Future<AppUser> loginWithGoogle() async {
    final user = await remoteDataSource.loginWithGoogle();
    await _saveUserLocally(user);
    return user;
  }

  @override
  Future<AppUser> loginAsGuest() async {
    final user = await remoteDataSource.loginAsGuest();
    await _saveUserLocally(user);
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulated behavior
  }

  @override
  Future<void> logout() async {
    _cachedUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_user');
  }
}
