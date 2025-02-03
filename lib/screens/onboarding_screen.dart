import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "https://example.com/water-filter-1.jpg",
      "title": "Кристально Чистая Вода",
      "description":
          "Фильтры последнего поколения с 5-ступенчатой системой очистки"
    },
    {
      "image": "https://example.com/water-filter-2.jpg",
      "title": "Умный Контроль",
      "description":
          "Мониторинг качества воды в реальном времени через приложение"
    },
    {
      "image": "https://example.com/water-filter-3.jpg",
      "title": "Экологичная Экономия",
      "description":
          "Сокращаем пластиковые отходы - 1 фильтр = 800 бутылок воды"
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primary.withAlpha(0x19), // 10% opacity
                    colorScheme.surface,
                  ],
                ),
              ),
            ),
            Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        "Пропустить",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate().fadeIn(delay: 500.ms),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 300,
                                  height: 300,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.primary.withAlpha(0x19),
                                  ),
                                ),
                                CachedNetworkImage(
                                  imageUrl: _pages[index]["image"]!,
                                  width: 280,
                                  height: 280,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error_outline_rounded),
                                )
                                    .animate()
                                    .scale(delay: 200.ms, duration: 500.ms)
                                    .shimmer(delay: 300.ms),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Column(
                              children: [
                                Text(
                                  _pages[index]["title"]!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.primary,
                                    height: 1.3,
                                  ),
                                ).animate().fadeIn(delay: 200.ms),
                                const SizedBox(height: 20),
                                Text(
                                  _pages[index]["description"]!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurface
                                        .withAlpha(0xCC), // 80% opacity
                                    height: 1.5,
                                  ),
                                ).animate().fadeIn(delay: 300.ms),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: colorScheme.primary,
                    dotColor:
                        colorScheme.primary.withAlpha(0x33), // 20% opacity
                    expansionFactor: 4,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24).copyWith(top: 40),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentPage == _pages.length - 1
                        ? _buildGetStartedButton()
                        : _buildNextButton(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return FloatingActionButton(
      onPressed: () {
        if (_controller.page! < _pages.length - 1) {
          _controller.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 4,
      child: const Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white,
        size: 28,
      ),
    ).animate().scale(delay: 200.ms);
  }

  Widget _buildGetStartedButton() {
    return ElevatedButton.icon(
      icon: Icon(
        Icons.water_drop_rounded,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      label: Text(
        "Начать очистку",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      onPressed: _completeOnboarding,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
      ),
    ).animate().slideY(
          begin: 1,
          end: 0,
          curve: Curves.easeOutBack,
          duration: const Duration(milliseconds: 600),
        );
  }
}
