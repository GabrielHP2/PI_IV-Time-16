import 'package:flutter/material.dart';

import '../../components/widgets/primary_button.dart';
import '../../repositories/personalization_repository.dart';
import '../../routes.dart';
import '../../theme/app_theme.dart';

class SubscriptionPlanPage extends StatefulWidget {
  const SubscriptionPlanPage({super.key});

  @override
  State<SubscriptionPlanPage> createState() => _SubscriptionPlanPageState();
}

class _SubscriptionPlanPageState extends State<SubscriptionPlanPage> {
  static const int _monthCount = 8;
  late final PageController _pageController;
  int _currentMonthIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatCurrency(double? value) {
    if (value == null) return 'R\$ --';
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _goToNextMonth() {
    if (_currentMonthIndex >= _monthCount - 1) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Você chegou ao último mês do planejamento.'),
          ),
        );
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _registerPlan() {
    PersonalizationRepository.setPlanRegistered(true);
    Navigator.pushNamed(context, AppRoutes.welcome);
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
        child: ValueListenableBuilder<double?>(
          valueListenable: PersonalizationRepository.currentMonthlySpend,
          builder: (context, currentSpend, child) {
            return ValueListenableBuilder<double?>(
              valueListenable: PersonalizationRepository.desiredMonthlySpend,
              builder: (context, desiredSpend, child) {
                return ValueListenableBuilder<List<String>>(
                  valueListenable:
                      PersonalizationRepository.subscribedPlatforms,
                  builder: (context, platforms, child) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                      child: Column(
                        children: [
                          const Text(
                            'Tudo pronto! Aqui está o seu planejamento:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.onDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: _SpendSummary(
                                  label: 'Gasto antigo:',
                                  value: _formatCurrency(currentSpend),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SpendSummary(
                                  label: 'Gasto estimado:',
                                  value: _formatCurrency(desiredSpend),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _monthCount,
                              onPageChanged: (index) {
                                setState(() => _currentMonthIndex = index);
                              },
                              itemBuilder: (context, index) {
                                return _MonthPlanCard(
                                  monthNumber: index + 1,
                                  monthlyTarget: desiredSpend,
                                  platforms: platforms,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_monthCount, (index) {
                              final isActive = index == _currentMonthIndex;
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration:
                                        const Duration(milliseconds: 220),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isActive
                                        ? AppColors.button
                                        : AppColors.fieldFill,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PrimaryButton(
                                text: 'Avançar',
                                onPressed: _goToNextMonth,
                              ),
                              ElevatedButton(
                                onPressed: _registerPlan,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.fieldFill,
                                  foregroundColor: AppColors.button,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 13,
                                  ),
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text('Registrar'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SpendSummary extends StatelessWidget {
  const _SpendSummary({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onDark,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: const ShapeDecoration(
            color: AppColors.button,
            shape: StadiumBorder(),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.onDark,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthPlanCard extends StatelessWidget {
  const _MonthPlanCard({
    required this.monthNumber,
    required this.monthlyTarget,
    required this.platforms,
  });

  final int monthNumber;
  final double? monthlyTarget;
  final List<String> platforms;

  @override
  Widget build(BuildContext context) {
    final visiblePlatforms = platforms.take(2).toList();

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 270),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          color: const Color(0xFFC19AD1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mês $monthNumber',
                  style: const TextStyle(
                    color: AppColors.onDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  monthlyTarget == null
                      ? 'R\$ --'
                      : 'R\$ ${monthlyTarget!.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    color: AppColors.onDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 18,
              runSpacing: 12,
              children: visiblePlatforms.isEmpty
                  ? const [
                      _PlatformCircle(name: 'LOGO'),
                      _PlatformCircle(name: 'LOGO'),
                    ]
                  : visiblePlatforms
                      .map((platform) => _PlatformCircle(name: platform))
                      .toList(),
            ),
            if (platforms.length > 2) ...[
              const SizedBox(height: 10),
              Text(
                '+ ${platforms.length - 2} plataforma(s) selecionada(s)',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.onDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _PlatformCircle extends StatelessWidget {
  const _PlatformCircle({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: AppColors.logoCircle,
        shape: BoxShape.circle,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
            color: AppColors.onDark,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
