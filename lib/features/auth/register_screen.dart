import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/routes/app_routes.dart';
import '../../config/theme/app_theme.dart';
import '../../core/utils/app_input_vaidators.dart';
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

  bool _isHidden1 = true;
  bool _isHidden2 = true;

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
          /// BACKGROUND
          Container(color: primary),

          /// BUBBLES
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Kembali',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: Colors.white,
                        ),
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

                /// FORM
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  height: MediaQuery.of(context).size.height * 0.7,
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
                          AppInputField(
                            controller: nameController,
                            label: 'Nama Lengkap',
                            hintText: 'Masukan naa lengkap',
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
                                _isHidden1 ? Iconsax.eye_slash : Iconsax.eye,
                                size: 20,
                                color: dark,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isHidden1 = !_isHidden1;
                                });
                              },
                            ),
                            validator: AppInputValidators.password,
                          ),
                          const SizedBox(height: 16),
                          AppInputField(
                            controller: confirmPasswordController,
                            label: 'Konfirmasi password',
                            hintText: 'Konfirmasi Password',
                            obscureText: _isHidden2,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isHidden2 ? Iconsax.eye_slash : Iconsax.eye,
                                size: 20,
                                color: dark,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isHidden2 = !_isHidden2;
                                });
                              },
                            ),
                            validator: AppInputValidators.password,
                          ),

                          /// REGISTER BUTTON
                          AppButton(
                            text: 'Daftar',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // TODO: register logic
                              }
                            },
                          ),

                          /// LOGIN LINK
                          RichText(
                            textAlign: TextAlign.center,
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
                                        context,
                                        AppRoutes.login,
                                      );
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

  /// BUBBLE DECOR
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
}
