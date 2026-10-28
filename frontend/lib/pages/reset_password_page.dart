import 'package:flutter/material.dart';

import '../routes.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/primary_button.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Redefinir Senha',
      showBackButton: true,
      topPadding: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Nova senha',
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          AppTextField(
            label: 'Confirmar senha',
            controller: _confirmPasswordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Redefinir',
            // TODO: redefinir a senha. Depois, volta ao login.
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            ),
          ),
        ],
      ),
    );
  }
}
