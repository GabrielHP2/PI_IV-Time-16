import 'package:flutter/material.dart';

import '../routes.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Solicitar Redefinição',
      showBackButton: true,
      topPadding: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Digite seu email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Enviar Solicitação',
            // TODO: enviar solicitação por email.
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.resetPassword),
          ),
        ],
      ),
    );
  }
}
