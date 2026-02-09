import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tokooci_app/core/services/api_service.dart';

import '../../config/constants/api_constants.dart';
import '../../config/routes/app_routes.dart';
import '../../config/theme/app_theme.dart';
import '../../core/utils/app_input_vaildators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_input_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final ApiService _apiService = ApiService();

  bool _isHidden1 = true;
  bool _isHidden2 = true;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _register() async {
    setState(() {
      _errorMessage = '';
    });

    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Password dan konfirmasi password tidak sama';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.post(
        ApiConstants.register,
        {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text,
          'password_confirmation': confirmPasswordController.text,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi berhasil, silakan login'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacementNamed(context, AppRoutes.login);
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Registrasi gagal';
          });
        }
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage =
              errorData['errors']?['email']?.first ??
              errorData['message'] ??
              'Terjadi kesalahan (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Koneksi gagal: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(color: primary),

          Positioned(top: -120, left: -80, child: _bubble(220)),
          Positioned(top: 80, right: -60, child: _bubble(160, opacity: 0.15)),
          Positioned(bottom: -100, left: -40, child: _bubble(200, opacity: 0.12)),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        label: const Text('Kembali',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Buat Akun',
                        style: lightTextStyle.copyWith(
                          fontSize: 28,
                          fontWeight: bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Daftar untuk mulai menggunakan aplikasi',
                        style: lightTextStyle.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (_errorMessage.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _errorMessage,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),

                          AppInputField(
                            controller: nameController,
                            label: 'Nama Lengkap',
                            hintText: 'Masukan nama lengkap',
                            validator: AppInputValidators.required,
                          ),
                          const SizedBox(height: 16),

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
                            obscureText: _isHidden1,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isHidden1
                                    ? Iconsax.eye_slash
                                    : Iconsax.eye,
                              ),
                              onPressed: () =>
                                  setState(() => _isHidden1 = !_isHidden1),
                            ),
                            validator: AppInputValidators.password,
                          ),
                          const SizedBox(height: 16),

                          AppInputField(
                            controller: confirmPasswordController,
                            label: 'Konfirmasi Password',
                            hintText: 'Konfirmasi Password',
                            obscureText: _isHidden2,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isHidden2
                                    ? Iconsax.eye_slash
                                    : Iconsax.eye,
                              ),
                              onPressed: () =>
                                  setState(() => _isHidden2 = !_isHidden2),
                            ),
                            validator: AppInputValidators.password,
                          ),
                          const SizedBox(height: 24),

                          AppButton(
                            text: 'Daftar',
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _register,
                          ),

                          const SizedBox(height: 16),

                          RichText(
                            text: TextSpan(
                              style: darkTextStyle.copyWith(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              children: [
                                const TextSpan(text: 'Sudah punya akun? '),
                                TextSpan(
                                  text: 'Masuk',
                                  style: darkTextStyle.copyWith(
                                    fontWeight: semiBold,
                                    color: primary,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushReplacementNamed(
                                          context, AppRoutes.login);
                                    },
                                ),
                              ],
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
