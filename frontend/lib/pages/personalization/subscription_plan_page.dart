// Feito por Felipe Batista Bastos - 25005337

import 'package:flutter/material.dart';

import '../../components/widgets/primary_button.dart';
import '../../models/subscription_plan_model.dart';
import '../../repositories/personalization_repository.dart';
import '../../routes.dart';
import '../../services/personalization_service.dart';
import '../../theme/app_theme.dart';

// Tela que solicita ao backend um planejamento de assinaturas com base nas preferências coletadas.
class SubscriptionPlanPage extends StatefulWidget {
  const SubscriptionPlanPage({super.key});

  @override
  State<SubscriptionPlanPage> createState() => _SubscriptionPlanPageState();
}

// Controla a geração do plano, o estado de carregamento, erros e mês atualmente exibido.
class _SubscriptionPlanPageState extends State<SubscriptionPlanPage> {
  final PersonalizationService _personalizationService =
      PersonalizationService();
  late final PageController _pageController;

  SubscriptionPlan? _plan;
  String? _errorMessage;
  bool _isLoading = true;
  int _currentMonthIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Reúne gastos, plataformas e conteúdos selecionados e solicita a geração do planejamento.
    _generatePlan();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    PersonalizationRepository.clearSubscriptionPlan();
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final currentExpense =
          PersonalizationRepository.currentMonthlySpend.value;
      final desiredExpense =
          PersonalizationRepository.desiredMonthlySpend.value;

      if (currentExpense == null || desiredExpense == null) {
        throw Exception('Informe seus gastos atual e desejado antes de continuar.');
      }
      if (desiredExpense <= 0) {
        throw Exception('O gasto desejado precisa ser maior que zero.');
      }

      // Serviço envia as preferências para a Cloud Function e converte a resposta em SubscriptionPlan.
      final result = await _personalizationService.generateSubscriptionPlan(
        platformIds: PersonalizationRepository.subscribedPlatformIds.value,
        currentContents: PersonalizationRepository.ongoingContents.value,
        desiredContents: PersonalizationRepository.desiredContents.value,
        currentExpense: currentExpense,
        desiredExpense: desiredExpense,
      );

      if (!mounted) return;
      PersonalizationRepository.setSubscriptionPlan(result);
      setState(() {
        _plan = result;
        _currentMonthIndex = 0;
        _isLoading = false;
      });
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _plan = null;
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // Formata os valores numéricos para exibição no padrão monetário brasileiro.
  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Atualiza o índice do mês exibido para permitir navegar pelo planejamento.
  void _goToNextMonth() {
    final plan = _plan;
    if (plan == null || plan.months.isEmpty) return;

    if (_currentMonthIndex >= plan.months.length - 1) {
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

  // Marca no repositório que o usuário concluiu a visualização/registro do planejamento.
  void _registerPlan() {
    if (_plan == null) return;
    PersonalizationRepository.setPlanRegistered(true);
    Navigator.pushNamed(context, AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Personalização'),
        leading: BackButton(onPressed: () => Navigator.maybePop(context)),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                // Apresenta uma mensagem de falha e uma ação para tentar gerar o plano novamente.
                ? _buildErrorState()
                : _plan == null
                    ? _buildErrorState(
                        message: 'Não foi possível carregar o planejamento.',
                      )
                    // Organiza os dados gerais e a lista de meses recebidos do backend.
                    : _buildPlan(_plan!),
      ),
    );
  }

  Widget _buildErrorState({String? message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: AppColors.onDark, size: 42),
            const SizedBox(height: 14),
            Text(
              message ?? _errorMessage ?? 'Ocorreu um erro inesperado.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onDark),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _generatePlan,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlan(SubscriptionPlan plan) {
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
          const SizedBox(height: 12),
          _PlanStatus(status: plan.status),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SpendSummary(
                  label: 'Gasto atual:',
                  value: _formatCurrency(plan.currentMonthlyExpense),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SpendSummary(
                  label: 'Gasto desejado:',
                  value: _formatCurrency(plan.desiredMonthlyExpense),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: plan.months.length,
              onPageChanged: (index) {
                setState(() => _currentMonthIndex = index);
              },
              itemBuilder: (context, index) {
                return _MonthPlanCard(
                  month: plan.months[index],
                  budget: plan.desiredMonthlyExpense,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(plan.months.length, (index) {
              final isActive = index == _currentMonthIndex;
              return GestureDetector(
                onTap: () => _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.button : AppColors.fieldFill,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PrimaryButton(
                text: _currentMonthIndex == plan.months.length - 1
                    ? 'Último mês'
                    : 'Avançar',
                onPressed: _currentMonthIndex == plan.months.length - 1
                    ? null
                    : _goToNextMonth,
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
  }
}

class _PlanStatus extends StatelessWidget {
  const _PlanStatus({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isWithinBudget = status == 'ok';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isWithinBudget ? Icons.check_circle_outline : Icons.info_outline,
          color: AppColors.onDark,
          size: 17,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            isWithinBudget
                ? 'Primeiro mês dentro do orçamento'
                : 'Primeiro mês acima do orçamento',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.onDark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
  const _MonthPlanCard({required this.month, required this.budget});

  final SubscriptionPlanMonth month;
  final double budget;

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final isWithinBudget = month.status == 'ok';

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 340),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          color: const Color(0xFFC19AD1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mês ${month.month}',
                  style: const TextStyle(
                    color: AppColors.onDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Flexible(
                  child: Text(
                    _formatCurrency(month.monthlyExpense),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: AppColors.onDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isWithinBudget
                  ? 'Dentro do orçamento de ${_formatCurrency(budget)}'
                  : 'Acima do orçamento de ${_formatCurrency(budget)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.onDark,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Plataformas recomendadas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onDark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: month.platformNames.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma plataforma retornada para este mês.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.onDark),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: month.platformNames
                            .map((name) => _PlatformChip(name: name))
                            .toList(),
                      ),
                    ),
            ),
            const Divider(color: Colors.white54),
            Text(
              'Índice de cobertura dos conteúdos atuais: ${month.currentCoverage}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.onDark,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Conteúdos desejados atendidos neste mês: ${month.desiredCoverage}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.onDark,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformChip extends StatelessWidget {
  const _PlatformChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.logoCircle,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: AppColors.onDark,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
