// Feito por Felipe Batista Bastos - 25005337

import 'package:flutter/material.dart';

import '../../components/widgets/primary_button.dart';
import '../../repositories/personalization_repository.dart';
import '../../routes.dart';
import '../../theme/app_theme.dart';

class PlatformsPage extends StatelessWidget {
  const PlatformsPage({super.key});

  // Opções iniciais da interface. A lista poderá ser alimentada pelo backend.
  static const List<String> platforms = [
    'Netflix',
    'Prime Video',
    'Disney+',
    'Max',
    'Globoplay',
    'Apple TV+',
  ];

  void _continue(BuildContext context) {
    final selectedPlatforms =
        PersonalizationRepository.subscribedPlatforms.value;

    if (selectedPlatforms.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Selecione pelo menos uma plataforma para continuar.'),
          ),
        );
      return;
    }

    Navigator.pushNamed(context, AppRoutes.ongoingContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalização'),
        leading: BackButton(
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: ValueListenableBuilder<List<String>>(
            valueListenable:
                PersonalizationRepository.subscribedPlatforms,
            builder: (context, selectedPlatforms, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Quais dessas plataformas você já é assinante?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.onDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      itemCount: platforms.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.05,
                      ),
                      itemBuilder: (context, index) {
                        final platform = platforms[index];
                        final isSelected =
                            selectedPlatforms.contains(platform);

                        return _PlatformCard(
                          name: platform,
                          isSelected: isSelected,
                          onTap: () {
                            PersonalizationRepository.togglePlatform(platform);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    selectedPlatforms.isEmpty
                        ? 'Selecione as plataformas que você assina.'
                        : selectedPlatforms.length == 1
                            ? '1 plataforma selecionada'
                            : '${selectedPlatforms.length} plataformas selecionadas',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.onDark,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Avançar',
                    onPressed: () => _continue(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  const _PlatformCard({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFF5B2874) : const Color(0xFF4B1B60),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.onDark,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              if (isSelected)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
