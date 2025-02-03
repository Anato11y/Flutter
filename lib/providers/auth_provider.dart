// providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:online_shop/models/user.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _user;

  // Получение текущего пользователя
  UserModel? get user => _user;

  /// Проверка, авторизован ли пользователь
  Future<void> checkUserLoggedIn() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        _user = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'Пользователь',
          bonusBalance: 100, // Заглушка для баланса бонусов
        );
      } else {
        _user = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Ошибка проверки авторизации: $e");
    }
  }

  /// Вход через email и пароль
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await checkUserLoggedIn(); // Проверяем, вошел ли пользователь
    } on FirebaseAuthException catch (e) {
      debugPrint("Ошибка входа: ${e.message}");
      rethrow; // Пробрасываем ошибку для обработки в UI
    }
  }

  /// Регистрация нового пользователя
  Future<void> register(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Создаем объект пользователя
      await userCredential.user
          ?.updateDisplayName(name); // Обновляем имя пользователя в Firebase
      _user = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        bonusBalance: 100, // Начальный бонус
      );

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      debugPrint("Ошибка регистрации: ${e.message}");
      rethrow; // Пробрасываем ошибку для обработки в UI
    }
  }

  /// Выход из аккаунта
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _user = null; // Сбрасываем данные пользователя
      notifyListeners();
    } catch (e) {
      debugPrint("Ошибка выхода: $e");
      rethrow; // Пробрасываем ошибку для обработки в UI
    }
  }

  /// Обновление информации о пользователе
  Future<void> updateUserInformation(String name) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return; // ✅ Заключили return в блок {}
      }

      // Обновляем имя пользователя в Firebase
      await firebaseUser.updateDisplayName(name);

      // Обновляем локальную модель пользователя
      _user = _user?.copyWith(name: name);
      notifyListeners();
    } catch (e) {
      debugPrint("Ошибка обновления информации: $e");
      rethrow; // Пробрасываем ошибку для обработки в UI
    }
  }
}
