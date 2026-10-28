import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      topPadding: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(kLogoAsset, width: 100, fit: BoxFit.contain),
          ),
          const SizedBox(height: 40),
          AppTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Senha',
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 20),
          Center(
            child: LinkText(
              text: 'Esqueci a senha',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.forgotPassword),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'Entrar',
            // TODO: autenticar e navegar para a tela principal do app.
            onPressed: () {},
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Não tem uma conta? ',
                style: TextStyle(color: AppColors.onDark, fontSize: 13),
              ),
              LinkText(
                text: 'Registre-se',
                onTap: () => Navigator.pushNamed(context, AppRoutes.register),
              ),
            ]
          ),
        ],
      ),
    );
  }
}
