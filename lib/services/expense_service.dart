import 'package:flutter_application_memotrip/models/expense.dart';
import 'package:flutter_application_memotrip/models/trip.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// 负责处理支出相关数据操作的服务类
class ExpenseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  /// 获取所有支出类别
  Future<List<ExpenseCategory>> getExpenseCategories() async {
    try {
      final data = await _supabase
          .from('expense_categories')
          .select()
          .order('name');
      
      return data.map((cat) => ExpenseCategory.fromJson(cat)).toList();
    } catch (e) {
      print('获取支出类别失败: $e');
      rethrow;
    }
  }

  /// 根据ID获取支出类别
  Future<ExpenseCategory?> getExpenseCategoryById(String categoryId) async {
    try {
      final data = await _supabase
          .from('expense_categories')
          .select()
          .eq('id', categoryId)
          .single();
      
      return ExpenseCategory.fromJson(data);
    } catch (e) {
      print('获取支出类别详情失败: $e');
      return null;
    }
  }

  /// 获取指定旅行的所有支出
  Future<List<Expense>> getExpensesByTripId(String tripId) async {
    try {
      // 获取所有支出
      final expenses = await _supabase
          .from('expenses')
          .select('*, expense_categories(name, icon_name, color_code)')
          .eq('trip_id', tripId)
          .order('date', ascending: false);
      
      // 转换为Expense对象
      return expenses.map<Expense>((exp) {
        final categoryData = exp['expense_categories'] as Map<String, dynamic>;
        return Expense.fromJson(exp,
          categoryName: categoryData['name'],
          iconName: categoryData['icon_name'],
          colorCode: categoryData['color_code'],
        );
      }).toList();
    } catch (e) {
      print('获取支出列表失败: $e');
      rethrow;
    }
  }

  /// 获取旅行预算信息
  Future<TripBudget> getTripBudget(String tripId) async {
    try {
      // 获取旅行信息
      final tripData = await _supabase
          .from('trips')
          .select('budget')
          .eq('id', tripId)
          .single();
      
      final double budget = tripData['budget'] != null
          ? double.parse(tripData['budget'].toString())
          : 0.0;
      
      // 获取所有支出记录并在客户端计算总支出
      final expenses = await _supabase
          .from('expenses')
          .select('amount')
          .eq('trip_id', tripId);
      
      double totalExpense = 0.0;
      for (final expense in expenses) {
        totalExpense += double.parse(expense['amount'].toString());
      }
      
      // 计算剩余金额
      final double remaining = budget - totalExpense;
      
      return TripBudget(
        totalExpense: totalExpense,
        budget: budget,
        remaining: remaining,
      );
    } catch (e) {
      print('获取旅行预算失败: $e');
      // 默认返回零值
      return TripBudget(
        totalExpense: 0,
        budget: 0,
        remaining: 0,
      );
    }
  }

  /// 根据ID获取单个支出
  Future<Expense?> getExpenseById(String expenseId) async {
    try {
      final data = await _supabase
          .from('expenses')
          .select('*, expense_categories(name, icon_name, color_code)')
          .eq('id', expenseId)
          .single();
      
      final categoryData = data['expense_categories'] as Map<String, dynamic>;
      return Expense.fromJson(data,
        categoryName: categoryData['name'],
        iconName: categoryData['icon_name'],
        colorCode: categoryData['color_code'],
      );
    } catch (e) {
      print('获取支出详情失败: $e');
      return null;
    }
  }

  /// 创建新支出
  Future<Expense> createExpense({
    required String tripId,
    required String title,
    required double amount,
    required DateTime date,
    required String categoryId,
  }) async {
    try {
      // 获取类别信息
      final category = await getExpenseCategoryById(categoryId);
      if (category == null) {
        throw Exception('支出类别不存在');
      }
      
      // 生成唯一ID
      final expenseId = _uuid.v4();
      
      // 创建支出数据
      final expenseData = {
        'id': expenseId,
        'trip_id': tripId,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category_id': categoryId,
      };
      
      // 插入数据库
      await _supabase.from('expenses').insert(expenseData);
      
      // 返回创建的支出对象
      return Expense(
        id: expenseId,
        tripId: tripId,
        title: title,
        amount: amount,
        date: date,
        categoryId: categoryId,
        categoryName: category.name,
        iconName: category.iconName,
        colorCode: category.colorCode,
      );
    } catch (e) {
      print('创建支出失败: $e');
      rethrow;
    }
  }

  /// 更新支出
  Future<Expense> updateExpense({
    required String expenseId,
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
  }) async {
    try {
      // 先获取当前支出数据
      final currentExpense = await getExpenseById(expenseId);
      if (currentExpense == null) {
        throw Exception('支出不存在');
      }
      
      // 准备更新数据
      final expenseData = {
        if (title != null) 'title': title,
        if (amount != null) 'amount': amount,
        if (date != null) 'date': date.toIso8601String(),
        if (categoryId != null) 'category_id': categoryId,
      };
      
      // 更新数据库
      await _supabase.from('expenses').update(expenseData).eq('id', expenseId);
      
      // 如果类别变更，获取新类别信息
      String? categoryName;
      String? iconName;
      String? colorCode;
      
      if (categoryId != null) {
        final category = await getExpenseCategoryById(categoryId);
        if (category != null) {
          categoryName = category.name;
          iconName = category.iconName;
          colorCode = category.colorCode;
        }
      }
      
      // 返回更新后的支出对象
      return Expense(
        id: expenseId,
        tripId: currentExpense.tripId,
        title: title ?? currentExpense.title,
        amount: amount ?? currentExpense.amount,
        date: date ?? currentExpense.date,
        categoryId: categoryId ?? currentExpense.categoryId,
        categoryName: categoryName ?? currentExpense.categoryName,
        iconName: iconName ?? currentExpense.iconName,
        colorCode: colorCode ?? currentExpense.colorCode,
      );
    } catch (e) {
      print('更新支出失败: $e');
      rethrow;
    }
  }

  /// 删除支出
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _supabase.from('expenses').delete().eq('id', expenseId);
    } catch (e) {
      print('删除支出失败: $e');
      rethrow;
    }
  }

  /// 按类别统计支出
  Future<Map<String, double>> getExpenseStatisticsByCategory(String tripId) async {
    try {
      // 直接使用 SQL 查询按类别汇总
      final result = await _supabase
          .rpc('get_expense_by_category', params: {'trip_id_param': tripId});
      
      // 转换为Map格式
      final Map<String, double> statistics = {};
      for (final item in result) {
        final categoryName = item['category_name'] as String;
        final amount = double.parse(item['total_amount'].toString());
        statistics[categoryName] = amount;
      }
      
      // 如果没有存储过程，可以获取所有支出并在客户端汇总
      if (statistics.isEmpty) {
        final expenses = await getExpensesByTripId(tripId);
        for (final expense in expenses) {
          final categoryName = expense.categoryName ?? '未分类';
          statistics[categoryName] = (statistics[categoryName] ?? 0) + expense.amount;
        }
      }
      
      return statistics;
    } catch (e) {
      print('获取支出统计失败: $e');
      
      try {
        // 备用方法：获取所有支出并在客户端汇总
        final expenses = await getExpensesByTripId(tripId);
        final Map<String, double> statistics = {};
        for (final expense in expenses) {
          final categoryName = expense.categoryName ?? '未分类';
          statistics[categoryName] = (statistics[categoryName] ?? 0) + expense.amount;
        }
        return statistics;
      } catch (_) {
        return {};
      }
    }
  }

  /// 按日期统计支出
  Future<Map<DateTime, double>> getExpenseStatisticsByDate(String tripId) async {
    try {
      // 直接获取所有支出，然后在客户端按日期汇总
      final expenses = await getExpensesByTripId(tripId);
      
      // 按日期汇总
      final Map<DateTime, double> statistics = {};
      for (final expense in expenses) {
        // 只保留日期部分，忽略时间
        final DateTime dateOnly = DateTime(
          expense.date.year,
          expense.date.month,
          expense.date.day,
        );
        
        statistics[dateOnly] = (statistics[dateOnly] ?? 0) + expense.amount;
      }
      
      // 按日期排序
      final sortedEntries = statistics.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      
      return Map.fromEntries(sortedEntries);
    } catch (e) {
      print('获取支出统计失败: $e');
      return {};
    }
  }

  /// 更新旅行预算
  Future<double> updateTripBudget(String tripId, double budget) async {
    try {
      await _supabase
          .from('trips')
          .update({'budget': budget})
          .eq('id', tripId);
      
      return budget;
    } catch (e) {
      print('更新旅行预算失败: $e');
      rethrow;
    }
  }
}
