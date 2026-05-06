import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _accountIdController = TextEditingController();
  final _passwordController  = TextEditingController();
  bool _isLoading     = false;
  bool _showPassword  = false;
  String _error       = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ── Set your credentials here ────────────────
  static const String accountId = '541172290899';
  static const String password  = 'DevOpsGPT@2026';
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _accountIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_accountIdController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() =>
          _error = 'Please fill in all fields');
      return;
    }

    setState(() { _isLoading = true; _error = ''; });

    await Future.delayed(
        const Duration(milliseconds: 1500));

    if (_accountIdController.text.trim() ==
            accountId &&
        _passwordController.text.trim() == password) {
      if (mounted) {
        Navigator.pushReplacementNamed(
            context, '/home');
      }
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Invalid Account ID or Password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppTheme.textPrimary(context);
    final textMuted   = AppTheme.textMuted(context);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [

                      // Logo
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                          ),
                          borderRadius:
                              BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent
                                  .withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_fix_high_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'DevOpsGPT',
                        style: GoogleFonts.inter(
                          color: textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        'AI Cloud Operations Platform',
                        style: GoogleFonts.inter(
                          color: textMuted,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Login Card
                      GlassCard(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text('Sign In',
                                style: GoogleFonts.inter(
                                  color: textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(
                                'Enter your AWS credentials',
                                style: GoogleFonts.inter(
                                  color: textMuted,
                                  fontSize: 13,
                                )),

                            const SizedBox(height: 24),

                            // Account ID field
                            _buildField(
                              context: context,
                              controller: _accountIdController,
                              label: 'AWS Account ID',
                              hint: '123456789012',
                              icon: Icons.cloud_rounded,
                              keyboardType:
                                  TextInputType.number,
                            ),

                            const SizedBox(height: 16),

                            // Password field
                            _buildField(
                              context: context,
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••••',
                              icon: Icons.lock_rounded,
                              isPassword: true,
                              showPassword: _showPassword,
                              onTogglePassword: () =>
                                  setState(() =>
                                      _showPassword =
                                          !_showPassword),
                            ),

                            // Error message
                            if (_error.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding:
                                    const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.criticalGlow,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Row(children: [
                                  const Icon(
                                      Icons.error_rounded,
                                      color: AppColors.critical,
                                      size: 16),
                                  const SizedBox(width: 8),
                                  Text(_error,
                                      style: const TextStyle(
                                        color: AppColors.critical,
                                        fontSize: 13,
                                      )),
                                ]),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Login Button
                            GestureDetector(
                              onTap: _isLoading ? null : _login,
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: _isLoading
                                      ? null
                                      : const LinearGradient(
                                          colors: AppColors
                                              .primaryGradient,
                                        ),
                                  color: _isLoading
                                      ? AppTheme.cardBorder(context)
                                      : null,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  boxShadow: _isLoading
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: AppColors.accent
                                                .withValues(alpha: 0.3),
                                            blurRadius: 20,
                                            offset:
                                                const Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child:
                                              CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Sign In',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Hint
                            Center(
                              child: Text(
                                'Use your AWS Account ID as username',
                                style: GoogleFonts.inter(
                                  color: textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Security note
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_rounded,
                              color: AppColors.success,
                              size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Secured with AWS IAM',
                            style: GoogleFonts.inter(
                              color: textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword         = false,
    bool showPassword       = false,
    VoidCallback? onTogglePassword,
  }) {
    final textColor    = AppTheme.textPrimary(context);
    final textMuted    = AppTheme.textMuted(context);
    final textSecondary = AppTheme.textSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: textSecondary,
                fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.glassWhite(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppTheme.glassBorder(context)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !showPassword,
            keyboardType: keyboardType,
            style: TextStyle(
                color: textColor, fontSize: 14),
            onSubmitted: (_) => _login(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: textMuted,
                  fontSize: 14),
              prefixIcon:
                  Icon(icon, color: AppColors.accent,
                      size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        showPassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: textMuted,
                        size: 20,
                      ),
                      onPressed: onTogglePassword,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
