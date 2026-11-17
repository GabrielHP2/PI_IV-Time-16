// Feito por Luis Felipe Pontes Mita - 25018740

import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../components/util/validators.dart';
import '../../components/widgets/app_text_field.dart';
import '../../components/widgets/auth_scaffold.dart';
import '../../components/widgets/primary_button.dart';
import '../../services/password_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordService = PasswordService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      final uid = await _passwordService.validateEmail(_emailController.text);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(uid: uid),
        ),
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
              text: _isLoading ? 'Verificando...' : 'Enviar Solicitação',
              onPressed: _isLoading ? null : _requestPasswordReset,
            ),
          ],
        ),
      ),
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, this.uid = ''});

  final String uid;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordService = PasswordService();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitNewPassword() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    if (widget.uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível identificar a conta. Solicite a redefinição novamente.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _passwordService.changePassword(
        uid: widget.uid,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada com sucesso!')),
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

const SizedBox(height: 12),

Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.3),
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Sua senha deve conter:',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        '• Entre 6 e 126 caracteres\n'
        '• Pelo menos uma letra maiúscula\n'
        '• Pelo menos uma letra minúscula\n'
        '• Pelo menos um número\n'
        '• Pelo menos um caractere especial\n'
        '• Não pode conter espaços',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          height: 1.6,
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        r'Caracteres especiais aceitos: @#$%^&+=!*_?-',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 11,
        ),
      ),
    ],
  ),
),

const SizedBox(height: 12),

AppTextField(
  label: 'Confirmar senha',
              controller: _confirmPasswordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: validateConfirmPassword(_passwordController),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: _isLoading ? 'Redefinindo...' : 'Redefinir',
              onPressed: _isLoading ? null : _submitNewPassword,
            ),
          ],
        ),
      ),
    );
  }
}
