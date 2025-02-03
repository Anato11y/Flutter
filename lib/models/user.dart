// models/user.dart

import 'package:flutter/foundation.dart';

class UserModel {
  final String id;
  final String? name;
  final String? email;
  final int bonusBalance;

  const UserModel({
    required this.id,
    this.name,
    this.email,
    this.bonusBalance = 0,
  });

  /// Создание объекта UserModel из Map
  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    if (data.isEmpty) {
      debugPrint('Ошибка: данные пользователя пустые');
      return UserModel(id: id); // Возвращаем пустой объект
    }

    return UserModel(
      id: id,
      name: data.getString(UserKeys.name),
      email: data.getString(UserKeys.email),
      bonusBalance: data.getInt(UserKeys.bonusBalance),
    );
  }

  /// Преобразование объекта UserModel в Map
  Map<String, dynamic> toMap() {
    return {
      UserKeys.id: id,
      UserKeys.name: name ?? '',
      UserKeys.email: email ?? '',
      UserKeys.bonusBalance: bonusBalance,
    };
  }

  /// Создание копии объекта с измененными полями
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? bonusBalance,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      bonusBalance: bonusBalance ?? this.bonusBalance,
    );
  }
}

/// Константы для ключей Firestore
class UserKeys {
  static const String id = 'id';
  static const String name = 'name';
  static const String email = 'email';
  static const String bonusBalance = 'bonusBalance';
}

/// Расширение для безопасного получения данных из Map
extension SafeDataAccess on Map<String, dynamic> {
  String? getString(String key) {
    final value = this[key];
    if (value is String) {
      return value;
    } else if (value != null) {
      debugPrint('Ошибка: значение для ключа "$key" не является строкой');
    }
    return null;
  }

  int getInt(String key) {
    final value = this[key];
    if (value is num) {
      return value.toInt();
    } else if (value != null) {
      debugPrint('Ошибка: значение для ключа "$key" не является числом');
    }
    return 0;
  }
}
