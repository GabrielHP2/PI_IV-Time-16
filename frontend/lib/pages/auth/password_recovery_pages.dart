// Feito por Luis Felipe Pontes Mita - 25018740

import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../components/util/validators.dart';
import '../../components/widgets/app_text_field.dart';
import '../../components/widgets/auth_scaffold.dart';
import '../../components/widgets/primary_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
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

      child: Form(
        key: _formKey,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            AppTextField(
              label: 'Digite seu email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: validateRequired,
            ),
          
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Enviar Solicitação',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // TO DO: enviar solicitação por email.
                  Navigator.pushNamed(context, AppRoutes.resetPassword);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
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

      child: Form(
        key: _formKey,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            AppTextField(
              label: 'Nova senha',
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: validatePassword,
            ),

            const SizedBox(height: 10),
            AppTextField(
              label: 'Confirmar senha',
              controller: _confirmPasswordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: validateConfirmPassword(_passwordController),
            ),

            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Redefinir',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // TO DO: redefinir a senha. Depois, volta ao login.
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
