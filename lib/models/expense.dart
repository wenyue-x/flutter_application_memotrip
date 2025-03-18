class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String icon;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.icon,
  });
}

class TripBudget {
  final double totalExpense;
  final double budget;
  final double remaining;

  TripBudget({
    required this.totalExpense,
    required this.budget,
    required this.remaining,
  });
}
