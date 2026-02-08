import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/theme/app_theme.dart';

class AppInputField extends StatelessWidget {
  final String? label;
  final String hintText;
  final TextEditingController controller;
  final EdgeInsetsGeometry? margin;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;
  final bool obscureText;
  final int maxLines;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final GestureTapCallback? onTap;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final BoxConstraints? prefixIconConstraints;

  const AppInputField({
    super.key,
    required this.controller,
    this.label,
    required this.hintText,
    this.margin,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.maxLines = 1,
    this.focusNode,
    this.onChanged,
    this.onTap,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.prefixIconConstraints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: defaultMargin),
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          if (label != null && label!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                label!,
                style: darkTextStyle.copyWith(fontSize: 12, fontWeight: medium),
              ),
            ),
          ],
          // Input
          TextFormField(
            focusNode: focusNode,
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            cursorColor: Colors.black,
            obscureText: obscureText,
            maxLines: obscureText ? 1 : maxLines,
            onChanged: onChanged,
            onTap: onTap,
            style: darkTextStyle.copyWith(
              fontSize: 12,
              fontWeight: medium,
              // color: lightGrey,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: darkTextStyle.copyWith(color: lightGrey),
              errorStyle: darkTextStyle.copyWith(fontSize: 12, color: danger),
              fillColor: white,
              filled: true,
              prefixText: prefixText,
              prefixStyle: darkTextStyle.copyWith(
                fontSize: 13,
                fontWeight: semiBold,
                color: dark,
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              prefixIconConstraints: prefixIconConstraints,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: lightGrey, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: dark, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: lightGrey, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: danger, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: danger, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 10,
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
