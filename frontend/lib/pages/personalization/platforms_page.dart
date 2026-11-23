// Feito por Felipe Batista Bastos - 25005337

import 'package:flutter/material.dart';

import '../../components/widgets/primary_button.dart';
import '../../models/platform_model.dart';
import '../../repositories/personalization_repository.dart';
import '../../routes.dart';
import '../../services/personalization_service.dart';
import '../../theme/app_theme.dart';

class PlatformsPage extends StatefulWidget {
  const PlatformsPage({super.key});

  @override
  State<PlatformsPage> createState() => _PlatformsPageState();
}

class _PlatformsPageState extends State<PlatformsPage> {
  final PersonalizationService _personalizationService =
      PersonalizationService();

  late Future<List<PlatformModel>> _platformsFuture;

  @override
  void initState() {
    super.initState();
    _platformsFuture = _loadPlatforms();
  }

  Future<List<PlatformModel>> _loadPlatforms() async {
    final platforms = await _personalizationService.getPlatforms();
    PersonalizationRepository.availablePlatforms.value = platforms;
    return platforms;
  }

  void _retryLoading() {
    setState(() {
      _platformsFuture = _loadPlatforms();
    });
  }

  void _continue() {
    if (PersonalizationRepository.subscribedPlatformIds.value.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Selecione pelo menos uma plataforma para continuar.',
            ),
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
          child: Column(
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
                child: FutureBuilder<List<PlatformModel>>(
                  future: _platformsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      final message = snapshot.error
                          .toString()
                          .replaceFirst('Exception: ', '');

                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off,
                              color: AppColors.onDark,
                              size: 42,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.onDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _retryLoading,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      );
                    }

                    final platforms = snapshot.data ?? [];

                    if (platforms.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhuma plataforma disponível no momento.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.onDark),
                        ),
                      );
                    }

                    return ValueListenableBuilder<List<int>>(
                      valueListenable:
                          PersonalizationRepository.subscribedPlatformIds,
                      builder: (context, selectedIds, child) {
                        return GridView.builder(
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
                                selectedIds.contains(platform.id);

                            return _PlatformCard(
                              platform: platform,
                              isSelected: isSelected,
                              onTap: () {
                                PersonalizationRepository
                                    .togglePlatformItem(platform);
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<List<String>>(
                valueListenable:
                    PersonalizationRepository.subscribedPlatforms,
                builder: (context, selectedPlatforms, child) {
                  return Text(
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
                  );
                },
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Avançar',
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  const _PlatformCard({
    required this.platform,
    required this.isSelected,
    required this.onTap,
  });

  final PlatformModel platform;
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (platform.logoUrl.isNotEmpty)
                        Expanded(
                          child: Image.network(
                            platform.logoUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.live_tv,
                                color: AppColors.onDark,
                                size: 38,
                              );
                            },
                          ),
                        )
                      else
                        const Expanded(
                          child: Icon(
                            Icons.live_tv,
                            color: AppColors.onDark,
                            size: 38,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        platform.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.onDark,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
