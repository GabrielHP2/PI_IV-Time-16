import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LinkText extends StatelessWidget {
  const LinkText({
    super.key,
    required this.text,
    this.onTap,
    this.fontSize = 13,
  });

  final String text;
  final VoidCallback? onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.button,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.button,
        ),
      ),
    );
  }
}
