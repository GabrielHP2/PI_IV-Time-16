class SubscriptionPlan {
  const SubscriptionPlan({
    required this.status,
    required this.months,
    required this.currentMonthlyExpense,
    required this.desiredMonthlyExpense,
    required this.subscribedPlatformIds,
  });

  final String status;
  final List<SubscriptionPlanMonth> months;
  final double currentMonthlyExpense;
  final double desiredMonthlyExpense;
  final List<int> subscribedPlatformIds;

  factory SubscriptionPlan.fromMap(Map<String, dynamic> map) {
    final rawMonths = map['months'];
    if (rawMonths is! List) {
      throw const FormatException(
        'O planejamento retornado não contém os meses esperados.',
      );
    }

    final months = rawMonths
        .whereType<Map>()
        .map(
          (item) => SubscriptionPlanMonth.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    if (months.isEmpty) {
      throw const FormatException(
        'O backend não retornou meses para o planejamento.',
      );
    }

    return SubscriptionPlan(
      status: map['status']?.toString() ?? 'unknown',
      months: months,
      currentMonthlyExpense: _readDouble(map['currentMonthlyExpense']),
      desiredMonthlyExpense: _readDouble(map['desiredMonthlyExpense']),
      subscribedPlatformIds: _readIntList(map['subscribedPlatformIds']),
    );
  }
}

class SubscriptionPlanMonth {
  const SubscriptionPlanMonth({
    required this.month,
    required this.platformIds,
    required this.platformNames,
    required this.monthlyExpense,
    required this.currentCoverage,
    required this.desiredCoverage,
    required this.status,
  });

  final int month;
  final List<int> platformIds;
  final List<String> platformNames;
  final double monthlyExpense;
  final int currentCoverage;
  final int desiredCoverage;
  final String status;

  factory SubscriptionPlanMonth.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlanMonth(
      month: _readInt(map['month']),
      platformIds: _readIntList(map['platformIds']),
      platformNames: _readStringList(map['platformNames']),
      monthlyExpense: _readDouble(map['monthlyExpense']),
      currentCoverage: _readInt(map['currentCoverage']),
      desiredCoverage: _readInt(map['desiredCoverage']),
      status: map['status']?.toString() ?? 'unknown',
    );
  }
}

double _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  throw const FormatException('O backend retornou um valor numérico inválido.');
}

int _readInt(dynamic value) {
  if (value is num) return value.toInt();
  throw const FormatException('O backend retornou um número inválido.');
}

List<int> _readIntList(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<num>().map((item) => item.toInt()).toList();
}

List<String> _readStringList(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList();
}
