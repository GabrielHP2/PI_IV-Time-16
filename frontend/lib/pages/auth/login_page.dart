// Feito por Luis Felipe Pontes Mita - 25018740

import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../theme/app_theme.dart';
import '../../components/util/validators.dart';
import '../../components/widgets/app_text_field.dart';
import '../../components/widgets/auth_scaffold.dart';
import '../../components/widgets/link_text.dart';
import '../../components/widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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

      child: Form(
        key: _formKey,
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
              validator: validateRequired,
            ),
        
            const SizedBox(height: 12),
            AppTextField(
              label: 'Senha',
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: validatePassword,
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
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pushNamed(context, AppRoutes.home);
                }
              },
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
      ),
    );
  }
}
