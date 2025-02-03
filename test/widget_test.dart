import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:online_shop/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:online_shop/main.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {
  final Map<String, dynamic> _storage = {};

  @override
  bool? getBool(String key) => _storage[key] as bool?;

  @override
  Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }
}

void main() {
  testWidgets('Initial loading screen test', (WidgetTester tester) async {
    // Настраиваем мок SharedPreferences
    final prefs = MockSharedPreferences();

    // Запускаем приложение с моком
    await tester.pumpWidget(MyApp(prefs: prefs));

    // Проверяем наличие индикатора загрузки
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Onboarding flow test', (WidgetTester tester) async {
    final prefs = MockSharedPreferences();

    await tester.pumpWidget(MyApp(prefs: prefs));

    // Имитируем завершение онбординга
    prefs.setBool('onboardingComplete', true);
    await tester.pumpAndSettle();

    // Проверяем переход на главный экран
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
