// Feito por Felipe Batista Bastos - 25005337

import 'package:flutter/material.dart';

import '../../components/widgets/primary_button.dart';
import '../../routes.dart';
import '../../theme/app_theme.dart';

// Tela final do fluxo de personalização, apresentada após as preferências e o planejamento.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // Remove as telas anteriores da pilha de navegação e direciona o usuário à página inicial.
  void _goToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Personalização'),
        leading: BackButton(
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          child: Column(
            children: [
              const SizedBox(height: 4),
              const Text(
                'Agora é só curtir!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Você pode favoritar um filme para assistir ou seu planejamento.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onDark,
                  fontSize: 14,
                  height: 1.25,
                ),
              ),
              const Spacer(flex: 2),
              const _WelcomeIllustration(),
              const Spacer(flex: 2),
              const Text(
                'Você pode conferir o seu planejamento a qualquer momento, em seu perfil.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onDark,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Página inicial',
                onPressed: () => _goToHome(context),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// Ilustração visual simples usada para concluir a experiência de boas-vindas.
class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      height: 158,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 16,
            child: Container(
              width: 88,
              height: 142,
              decoration: BoxDecoration(
                color: AppColors.logoCircle,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.fieldFill,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.background,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.smartphone_rounded,
              color: AppColors.button,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }
}
