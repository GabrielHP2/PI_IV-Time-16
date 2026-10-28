import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: const BorderSide(color: AppColors.fieldBorder, width: 1.2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 2),

          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.onDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          cursorColor: AppColors.fieldBorder,
          style: const TextStyle(color: Colors.black87),

          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.fieldFill,

            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(color: AppColors.button, width: 2),
            ),

            errorBorder: border.copyWith(
              borderSide: const BorderSide(color: Color(0xFFFFB4B4), width: 1.5),
            ),

            focusedErrorBorder: border.copyWith(
              borderSide: const BorderSide(color: Color(0xFFFFB4B4), width: 2),
            ),

            errorMaxLines: 2,
            errorStyle: const TextStyle(
              color: Color(0xFFFFE0E0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
