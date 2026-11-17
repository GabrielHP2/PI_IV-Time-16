// Feito por Luis Felipe Pontes Mita - 25018740
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.text, this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        // Sem ação por enquanto (somente UI). Mantém o visual de botão ativo.
        onPressed: onPressed ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.button,
          foregroundColor: AppColors.onDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Text(text),
      ),
    );
  }
}
