import 'package:intl/intl.dart';

/// 支出类别模型
class ExpenseCategory {
  final String id;
  final String name;
  final String iconName;
  final String colorCode;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorCode,
  });

  /// 从 JSON 数据创建 ExpenseCategory
  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'],
      name: json['name'],
      iconName: json['icon_name'],
      colorCode: json['color_code'],
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'color_code': colorCode,
    };
  }
}

/// 支出记录模型
class Expense {
  final String id;
  final String tripId;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? categoryName;
  final String? iconName;
  final String? colorCode;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.categoryName,
    this.iconName,
    this.colorCode,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 格式化的日期显示
  String get formattedDate {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }
  
  /// 格式化的金额显示
  String get formattedAmount {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'zh_CN',
      symbol: '¥',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// 从 JSON 数据创建 Expense
  factory Expense.fromJson(Map<String, dynamic> json, {
    String? categoryName,
    String? iconName,
    String? colorCode,
  }) {
    return Expense(
      id: json['id'],
      tripId: json['trip_id'],
      title: json['title'],
      amount: double.parse(json['amount'].toString()),
      date: json['date'] is String 
          ? DateTime.parse(json['date'])
          : DateTime.parse(json['date'].toString()),
      categoryId: json['category_id'],
      categoryName: categoryName,
      iconName: iconName,
      colorCode: colorCode,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category_id': categoryId,
    };
  }

  /// 创建拷贝并更新某些字段
  Expense copyWith({
    String? id,
    String? tripId,
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    String? categoryName,
    String? iconName,
    String? colorCode,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      iconName: iconName ?? this.iconName,
      colorCode: colorCode ?? this.colorCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 旅行预算模型
class TripBudget {
  final double totalExpense;
  final double budget;
  final double remaining;

  TripBudget({
    required this.totalExpense,
    required this.budget,
    required this.remaining,
  });
  
  /// 获取预算使用百分比
  double get usagePercentage {
    if (budget <= 0) return 0;
    return (totalExpense / budget).clamp(0.0, 1.0);
  }
  
  /// 格式化的总支出显示
  String get formattedTotalExpense {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'zh_CN',
      symbol: '¥',
      decimalDigits: 2,
    );
    return formatter.format(totalExpense);
  }
  
  /// 格式化的预算显示
  String get formattedBudget {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'zh_CN',
      symbol: '¥',
      decimalDigits: 2,
    );
    return formatter.format(budget);
  }
  
  /// 格式化的剩余金额显示
  String get formattedRemaining {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'zh_CN',
      symbol: '¥',
      decimalDigits: 2,
    );
    return formatter.format(remaining);
  }
}
