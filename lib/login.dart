import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:eatwise2/Model/user.dart';
import 'package:eatwise2/util/session.dart';
import 'package:eatwise2/util/util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eatwise2/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eatwise2/page/home_integrated.dart' as Indexhome;
import 'package:eatwise2/util/app_theme.dart';
import 'package:eatwise2/widgets/common_widgets.dart';
import 'package:eatwise2/database/local_database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameCont = TextEditingController();
  TextEditingController passCont = TextEditingController();
  bool _isLoading = false;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Decorative Circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _opacity,
              curve: Curves.easeIn,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 80),
                    // Title Section
                    Center(
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFE0E0E0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: Text(
                              'EATWISE',
                              style: GoogleFonts.poppins(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    offset: const Offset(0, 0),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'FUEL YOUR BODY RIGHT',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Login Card
                    ModernCard(
                      isGlass: true,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome Back',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Log in to continue your journey',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ModernInput(
                            label: 'Username',
                            hint: 'Enter your username',
                            prefixIcon: Icons.person_outline,
                            controller: usernameCont,
                          ),
                          const SizedBox(height: 20),
                          ModernInput(
                            label: 'Password',
                            hint: 'Enter your password',
                            prefixIcon: Icons.lock_outline,
                            controller: passCont,
                            obscureText: true,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Forgot password logic? (Not in original, keeping it minimal)
                              },
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          GradientButton(
                            text: 'Login',
                            isLoading: _isLoading,
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              await handleLogin();
                              if (mounted) setState(() => _isLoading = false);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Footer
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 15,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpPage(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> handleLogin() async {
    print('=== HANDLE LOGIN (LOCAL) ===');
    print('Username: ${usernameCont.text}');

    try {
      final localDb = LocalDatabase();
      
      final user = await localDb.loginUser(
        usernameCont.text.trim(),
        passCont.text.trim(),
      );

      if (user != null) {
        print('✅ Login berhasil: User ID ${user['id']}');
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(IS_LOGIN, true);
        await prefs.setString('user_id', user['id'].toString());
        await prefs.setString('username', user['username'] ?? 'User');
        await prefs.setString('email', user['email'] ?? '');

        print('💾 Saved user_id to SharedPreferences: ${user['id']}');

        createUserSessionx(
          user['id']?.toString() ?? "",
          user['username']?.toString() ?? "User",
          "",
          user['email']?.toString() ?? "",
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Indexhome.HomeContent()),
        );
        print('✅ Navigation completed');
      } else {
        dialog(context, "Username atau password salah!");
      }
    } catch (e, stackTrace) {
      print('=== LOGIN ERROR ===');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      dialog(context, "Terjadi kesalahan: $e");
    }
  }
}
