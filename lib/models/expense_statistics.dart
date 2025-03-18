class ExpenseCategory {
  final String id;
  final String name;
  final double amount;
  final double percentage;
  final String iconName;
  final String colorCode;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.amount,
    required this.percentage,
    required this.iconName,
    required this.colorCode,
  });
}

class ExpenseStatistics {
  final double totalAmount;
  final List<ExpenseCategory> categories;

  ExpenseStatistics({
    required this.totalAmount,
    required this.categories,
  });
}
