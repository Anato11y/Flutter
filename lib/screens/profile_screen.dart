// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart'; // ✅ Импортируем кастомный UserModel
import '../screens/auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? user = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text("Профиль")),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfoRow('Имя', user.name ?? 'Не указано'),
                  const SizedBox(height: 10),
                  _buildUserInfoRow('Email', user.email ?? 'Не указано'),
                  const SizedBox(height: 20),
                  _buildBonusBalance(user.bonusBalance),
                  const Spacer(),
                  _LogoutButton(
                      onPressed: () => _logout(context, authProvider)),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        children: [
          TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _buildBonusBalance(int bonusBalance) {
    return Row(
      children: [
        Text(
          "Бонусный баланс: $bonusBalance бонусов",
          style: const TextStyle(fontSize: 18, color: Colors.green),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.star, color: Colors.amber, size: 20),
      ],
    );
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    try {
      await authProvider.logout();
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Вы вышли из аккаунта")),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка выхода: ${e.toString()}")),
      );
    }
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        "Выйти",
        style: TextStyle(fontSize: 18),
      ),
    ).animate().scale(); // Добавляем анимацию масштабирования
  }
}
