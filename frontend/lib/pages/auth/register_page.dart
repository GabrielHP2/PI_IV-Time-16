// Feito por Luis Felipe Pontes Mita - 25018740

import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../components/util/validators.dart';
import '../../components/widgets/app_text_field.dart';
import '../../components/widgets/auth_scaffold.dart';
import '../../components/widgets/primary_button.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.register(
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      final message = response['message']?.toString() ??
          'Cadastro realizado com sucesso.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Cadastro',
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Nome',
              controller: _nameController,
              textInputAction: TextInputAction.next,
              validator: validateRequired,
            ),
            const SizedBox(height: 10),
            AppTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: validateRequired,
            ),
            const SizedBox(height: 10),
            AppTextField(
              label: 'Telefone',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: validateRequired,
            ),
            const SizedBox(height: 10),
            AppTextField(
              label: 'Senha',
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
            const SizedBox(height: 24),
            PrimaryButton(
              text: _isLoading ? 'Cadastrando...' : 'Cadastrar',
              onPressed: _isLoading ? null : _register,
            ),
          ],
        ),
      ),
    );
  }
}
