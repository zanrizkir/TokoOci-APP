import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/routes/app_routes.dart';
import '../../config/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final controller = PageController();
  int index = 0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: primary,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: defaultMargin),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: controller,
                onPageChanged: (i) => setState(() => index = i),
                children: const [
                  _IntroItem(
                    title: 'Belanja Mudah',
                    desc: 'Semua kebutuhan toko dalam satu aplikasi',
                  ),
                  _IntroItem(
                    title: 'Cepat & Aman',
                    desc: 'Transaksi aman dan cepat',
                  ),
                  _IntroItem(
                    title: 'Kelola Bisnis',
                    desc: 'Pantau pesanan kapan saja',
                  ),
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.all(4),
                  width: index == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            AppButton(
              text: 'Masuk',
              backgroundColor: white,
              textColor: primary,
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _IntroItem extends StatelessWidget {
  final String title;
  final String desc;

  const _IntroItem({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag, size: 120, color: Colors.white),
          const SizedBox(height: 40),
          Text(
            title,
            style: lightTextStyle.copyWith(fontSize: 28, fontWeight: bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            style: lightTextStyle.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
