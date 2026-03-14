import 'package:eatwise2/login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:eatwise2/Model/user.dart';
import 'package:eatwise2/util/util.dart';
import 'package:eatwise2/util/app_theme.dart';
import 'package:eatwise2/widgets/common_widgets.dart';
import 'package:eatwise2/database/local_database.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController usernameCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
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
            left: -100,
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
                    const SizedBox(height: 60),
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
                child: Text('EATWISE',
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
                            'JOIN THE HEALTH REVOLUTION',
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
                    const SizedBox(height: 48),
                    // Register Card
                    ModernCard(
                      isGlass: true,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Create Account',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start your journey to a better you',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ModernInput(
                            label: 'Username',
                            hint: 'Choose a username',
                            prefixIcon: Icons.person_outline,
                            controller: usernameCont,
                          ),
                          const SizedBox(height: 20),
                          ModernInput(
                            label: 'Email',
                            hint: 'Enter your email',
                            prefixIcon: Icons.email_outlined,
                            controller: emailCont,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          ModernInput(
                            label: 'Password',
                            hint: 'Create a password',
                            prefixIcon: Icons.lock_outline,
                            controller: passwordCont,
                            obscureText: true,
                          ),
                          const SizedBox(height: 32),
                          GradientButton(
                            text: 'Register',
                            isLoading: _isLoading,
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              await prosesRegistrasi();
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
                          text: "Already have an account? ",
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 15,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign In',
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
                                      builder: (context) => LoginPage(),
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


  Future<void> prosesRegistrasi() async {
    // Validasi input
    if (usernameCont.text.trim().isEmpty) {
      dialog(context, "Username tidak boleh kosong!");
      return;
    }

    if (passwordCont.text.trim().isEmpty) {
      dialog(context, "Password tidak boleh kosong!");
      return;
    }

    if (emailCont.text.trim().isEmpty) {
      dialog(context, "Email tidak boleh kosong!");
      return;
    }

    print('=== PROSES REGISTRASI (LOCAL) ===');
    print('Username: ${usernameCont.text}');
    print('Email: ${emailCont.text}');

    try {
      final localDb = LocalDatabase();
      
      // Cek apakah username sudah ada
      final usernameExists = await localDb.checkUsernameExists(usernameCont.text.trim());
      if (usernameExists) {
        dialog(context, "Username sudah digunakan!");
        return;
      }

      // Register user
      final result = await localDb.registerUser(
        usernameCont.text.trim(),
        passwordCont.text.trim(),
        emailCont.text.trim(),
      );

      if (result != null) {
        print('✅ Registrasi berhasil: User ID ${result['id']}');
        dialog(context, "Registrasi berhasil!");
        
        // Tunggu sebentar lalu pindah ke login
        await Future.delayed(Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } else {
        dialog(context, "Registrasi gagal! Silakan coba lagi.");
      }
    } catch (e, stackTrace) {
      print('=== REGISTER ERROR ===');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      dialog(context, "Terjadi kesalahan: $e");
    }
  }
}
