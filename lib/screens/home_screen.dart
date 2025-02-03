// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_background.dart';
import 'category_screen.dart'; // Экран категорий
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = const [
    CategoryScreen(), // Экран категорий
    CartScreen(), // Экран корзины
    ProfileScreen(), // Экран профиля
  ];

  Future<void> _handleProfileNavigation() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      if (result == true && mounted) {
        _updateSelectedIndex(2);
      }
      return;
    }
    if (mounted) _updateSelectedIndex(2);
  }

  void _updateSelectedIndex(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (mounted) setState(() => _selectedIndex = index);
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _handleProfileNavigation();
      return;
    }
    _updateSelectedIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      backgroundUrl: 'assets/images/phon.jpg',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor:
          theme.colorScheme.onSurface.withAlpha(153), // Уже корректно
      backgroundColor: theme.colorScheme.surface
          .withAlpha((0.9 * 255).round()), // Исправлено здесь
      showUnselectedLabels: true,
      items: [
        _buildBottomNavItem(
            Icons.category_outlined, Icons.category, 'Категории', 0),
        _buildBottomNavItem(
            Icons.shopping_cart_outlined, Icons.shopping_cart, 'Корзина', 1),
        _buildBottomNavItem(Icons.person_outlined, Icons.person, 'Профиль', 2),
      ],
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(
      IconData icon, IconData activeIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: _buildAnimatedIcon(icon, index,
          size: 24), // Размер иконки по умолчанию
      activeIcon: _buildAnimatedIcon(activeIcon, index,
          size: 28), // Увеличение при активации
      label: label,
    );
  }

  Widget _buildAnimatedIcon(IconData iconData, int index, {double size = 24}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: Icon(
        iconData,
        key:
            ValueKey(_selectedIndex == index), // Ключ для перестроения анимации
        size: size,
        color: _selectedIndex == index
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context)
                .colorScheme
                .onSurface
                .withAlpha(153), // Уже корректно
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
