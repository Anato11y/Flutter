// screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _dropController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _waveAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOutSine),
    );
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  Future<void> _authAction(Future Function() action) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await action();
      if (!mounted) return;
      await _dropController.forward();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, e.code);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(BuildContext context, String errorCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.blue[50],
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.amber[700]),
            const SizedBox(width: 10),
            const Text('Ошибка авторизации'),
          ],
        ),
        content: Text(
          _parseFirebaseError(errorCode),
          style: TextStyle(color: Colors.blueGrey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  String _parseFirebaseError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Неверный формат email';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'email-already-in-use':
        return 'Email уже используется';
      case 'weak-password':
        return 'Пароль должен содержать минимум 6 символов';
      default:
        return 'Ошибка: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _WaterWavePainter(
                    waveValue: _waveAnimation.value,
                    color: Colors.blue.withAlpha(25),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: _dropController,
                          child: const Icon(
                            Icons.water_drop,
                            size: 80,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          decoration:
                              _inputDecoration('Email', Icons.alternate_email),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || !v.contains('@')) {
                              return 'Введите корректный email';
                            }
                            return null;
                          },
                          onChanged: (v) => _email = v,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration:
                              _inputDecoration('Пароль', Icons.lock_outline),
                          obscureText: true,
                          validator: (v) {
                            if (v == null || v.length < 6) {
                              return 'Минимум 6 символов';
                            }
                            return null;
                          },
                          onChanged: (v) => _password = v,
                        ),
                        const SizedBox(height: 30),
                        _AuthButton(
                          isLoading: _isLoading,
                          label: 'Войти',
                          onPressed: () => _authAction(
                            () => _auth.signInWithEmailAndPassword(
                                email: _email, password: _password),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _AuthButton(
                          isLoading: _isLoading,
                          label: 'Зарегистрироваться',
                          isSecondary: true,
                          onPressed: () => _authAction(
                            () => _auth.createUserWithEmailAndPassword(
                                email: _email, password: _password),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue[700]),
      border: _inputBorder(),
      enabledBorder: _inputBorder(),
      focusedBorder: _inputBorder(color: Colors.blue),
    );
  }

  OutlineInputBorder _inputBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: color ?? Colors.blueGrey.withAlpha(77),
        width: 1.5,
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final bool isSecondary;
  final VoidCallback onPressed;

  const _AuthButton({
    required this.isLoading,
    required this.label,
    this.isSecondary = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: !isSecondary
              ? LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: isSecondary ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: isLoading ? null : onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isSecondary ? Colors.blue : Colors.white,
                        ),
                      ),
                    )
                  else
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSecondary ? Colors.blue : Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaterWavePainter extends CustomPainter {
  final double waveValue;
  final Color color;

  _WaterWavePainter({required this.waveValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * (0.75 + waveValue),
        size.width * 0.5,
        size.height * 0.75,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * (0.75 - waveValue),
        size.width,
        size.height * 0.75,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaterWavePainter oldDelegate) =>
      waveValue != oldDelegate.waveValue || color != oldDelegate.color;
}
