
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey        = GlobalKey<FormState>();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _fullNameCtrl   = TextEditingController();

  bool _isLoginMode   = true;
  bool _obscurePass   = true;
  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _fullNameCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() => _isLoginMode = !_isLoginMode);
    _animController.reset();
    _animController.forward();
    context.read<AuthProvider>().clearError();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    bool success;

    if (_isLoginMode) {
      success = await auth.signIn(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
    } else {
      success = await auth.signUp(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        fullName: _fullNameCtrl.text.trim(),
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Please check your email to verify.'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        _toggleMode();
      }
    }

    if (!success && mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background ────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryDeep, AppTheme.primaryMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── Decorative circles ────────────────────────────────────────────
          Positioned(
            top: -80,
            right: -60,
            // ignore: deprecated_member_use
            child: _decorCircle(200, AppTheme.accentGold.withOpacity(0.08)),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            // ignore: deprecated_member_use
            child: _decorCircle(280, AppTheme.accentTeal.withOpacity(0.07)),
          ),
          Positioned(
            top: 140,
            left: -40,
            // ignore: deprecated_member_use
            child: _decorCircle(120, Colors.white.withOpacity(0.04)),
          ),

          // ── Main Content ──────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildLogo(),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Card
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildFormCard(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Toggle
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildToggle(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.accentGold,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: AppTheme.accentGold.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.school_rounded, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'SA Apply',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 34,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'CUT Information Technology',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: Colors.white54,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isLoginMode ? 'Welcome back' : 'Create account',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              _isLoginMode
                  ? 'Sign in to manage your SA application'
                  : 'Register to apply for a Student Assistant position',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 28),

            // Full Name (register only)
            if (!_isLoginMode) ...[
              TextFormField(
                controller: _fullNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Please enter your full name' : null,
              ),
              const SizedBox(height: 16),
            ],

            // Email
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Student Email',
                prefixIcon: Icon(Icons.email_rounded),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your email';
                if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(v.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePass,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your password';
                if (!_isLoginMode && v.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 28),

            // Submit Button
            Consumer<AuthProvider>(
              builder: (_, auth, __) => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(_isLoginMode ? 'Sign In' : 'Create Account'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLoginMode ? "Don't have an account?" : "Already have an account?",
          style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14),
        ),
        TextButton(
          onPressed: _toggleMode,
          child: Text(
            _isLoginMode ? 'Register' : 'Sign In',
            style: GoogleFonts.dmSans(
              color: AppTheme.accentGold,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
