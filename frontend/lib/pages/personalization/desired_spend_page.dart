import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/widgets/primary_button.dart';
import '../../repositories/personalization_repository.dart';
import '../../routes.dart';
import '../../theme/app_theme.dart';

class DesiredSpendPage extends StatefulWidget {
  const DesiredSpendPage({super.key});

  @override
  State<DesiredSpendPage> createState() => _DesiredSpendPageState();
}

class _DesiredSpendPageState extends State<DesiredSpendPage> {
  final TextEditingController _spendController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final savedSpend = PersonalizationRepository.desiredMonthlySpend.value;
    if (savedSpend != null) {
      _spendController.text = savedSpend.toStringAsFixed(2).replaceAll('.', ',');
    }
  }

  @override
  void dispose() {
    _spendController.dispose();
    super.dispose();
  }

  double? _parseSpend(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) return null;

    final normalizedValue = trimmedValue.contains(',')
        ? trimmedValue.replaceAll('.', '').replaceAll(',', '.')
        : trimmedValue;
    return double.tryParse(normalizedValue);
  }

  void _continue() {
    final spend = _parseSpend(_spendController.text);

    if (spend == null || spend < 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Informe um valor válido para continuar.'),
          ),
        );
      return;
    }

    PersonalizationRepository.setDesiredMonthlySpend(spend);
    Navigator.pushNamed(context, AppRoutes.subscriptionPlan);
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
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Quanto você deseja gastar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.onDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _spendController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.,]'),
                          ),
                        ],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.button,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Digite o valor mensal',
                          hintStyle: const TextStyle(
                            color: AppColors.button,
                            fontSize: 13,
                          ),
                          prefixText: 'R\$ ',
                          prefixStyle: const TextStyle(
                            color: AppColors.button,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          filled: true,
                          fillColor: AppColors.fieldFill,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: AppColors.button,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  text: 'Avançar',
                  onPressed: _continue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
