import 'package:flutter/material.dart';

import '../../config/theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final double borderRadius;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.margin,
    this.padding,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.borderRadius = 8,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: defaultMargin),
      width: double.infinity,
      padding: padding ?? EdgeInsets.only(top: 20, bottom: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? primary,
          foregroundColor: dark,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const LoadingIndicator(size: 18, strokeWidth: 2)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: textColor ?? dark),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: darkTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: medium,
                      color: textColor ?? white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = 24,
    this.strokeWidth = 2.5,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? primary),
      ),
    );
  }
}
