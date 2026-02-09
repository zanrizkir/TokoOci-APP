import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tokooci_app/core/utils/app_input_vaildators.dart';
import '../../config/constants/api_constants.dart';
import '../../config/routes/app_routes.dart';
import '../../config/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isHidden = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (mounted) {
      setState(() {
        _rememberMe = rememberMe;
        if (rememberMe && savedEmail != null) {
          emailController.text = savedEmail;
        }
        if (rememberMe && savedPassword != null) {
          passwordController.text = savedPassword;
        }
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', emailController.text);
      await prefs.setString('saved_password', passwordController.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<void> _login() async {
    // Reset error message
    setState(() {
      _errorMessage = '';
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.post(
        ApiConstants.login,
        {
          'email': emailController.text.trim(),
          'password': passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          // Save token
          final token = data['token'];
          await _apiService.saveToken(token);
          
          // Save user data to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final user = data['user'];
          await prefs.setString('user_name', user['name']);
          await prefs.setString('user_email', user['email']);
          await prefs.setString('user_phone', user['phone'] ?? '');
          await prefs.setString('user_address', user['address'] ?? '');
          await prefs.setString('user_role', user['role'] ?? 'user');
          
          // Save credentials if remember me is active
          await _saveCredentials();
          
          // Navigate to Home
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
          
          // Show success snackbar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selamat datang, ${user['name']}!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Login gagal';
            _isLoading = false;
          });
        }
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage = errorData['errors']?['email']?.first ?? 
                         errorData['message'] ?? 
                         'Terjadi kesalahan (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Koneksi gagal: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          /// BACKGROUND
          Container(color: primary),

          /// BUBBLE DECOR
          Positioned(top: -120, left: -80, child: _bubble(220)),
          Positioned(top: 80, right: -60, child: _bubble(160, opacity: 0.15)),
          Positioned(
            bottom: -100,
            left: -40,
            child: _bubble(200, opacity: 0.12),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/logo_app.png',
                        width: 120,
                        color: Colors.white,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          width: 120,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            size: 30,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Selamat Datang 👋',
                        style: lightTextStyle.copyWith(
                          fontSize: 28,
                          fontWeight: bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Masuk untuk melanjutkan',
                        style: lightTextStyle.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                /// FORM SECTION - DISESUAIKAN DENGAN REGISTER SCREEN
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  height: MediaQuery.of(context).size.height * 0.65,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Error Message
                          if (_errorMessage.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200] ?? Colors.red),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage,
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          AppInputField(
                            controller: emailController,
                            label: 'Email',
                            hintText: 'Masukan alamat E-mail',
                            validator: AppInputValidators.email,
                          ),
                          const SizedBox(height: 16),
                          AppInputField(
                            controller: passwordController,
                            label: 'Password',
                            hintText: 'Password',
                            obscureText: _isHidden,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isHidden ? Iconsax.eye_slash : Iconsax.eye,
                                size: 20,
                                color: dark,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isHidden = !_isHidden;
                                });
                              },
                            ),
                            validator: AppInputValidators.password,
                          ),

                          const SizedBox(height: 16),

                          // Remember Me Checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeColor: primary,
                              ),
                              const Text('Ingat saya'),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Fitur lupa password dalam pengembangan'),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Lupa Password?',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          /// LOGIN BUTTON
                          AppButton(
                            text: 'Masuk',
                            onPressed: _isLoading ? null : _login,
                            isLoading: _isLoading,
                          ),

                          const SizedBox(height: 24),

                          /// REGISTER LINK
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: darkTextStyle.copyWith(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              children: [
                                const TextSpan(text: 'Belum punya akun? '),
                                TextSpan(
                                  text: 'Daftar',
                                  style: darkTextStyle.copyWith(
                                    fontWeight: semiBold,
                                    color: primary,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.register,
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Terms & Privacy
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                                children: [
                                  const TextSpan(text: 'Dengan masuk, Anda menyetujui '),
                                  TextSpan(
                                    text: 'Syarat & Ketentuan',
                                    style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const TextSpan(text: ' serta '),
                                  TextSpan(
                                    text: 'Kebijakan Privasi',
                                    style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const TextSpan(text: ' kami'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// BUBBLE WIDGET
  Widget _bubble(double size, {double opacity = 0.2}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}