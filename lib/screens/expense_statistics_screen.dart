import 'package:flutter/material.dart';
import 'package:flutter_application_memotrip/models/trip.dart';
import 'package:flutter_application_memotrip/models/expense_statistics.dart';
import 'package:flutter_application_memotrip/services/expense_service.dart';
import 'dart:math' as math;

class ExpenseStatisticsScreen extends StatefulWidget {
  final Trip trip;

  const ExpenseStatisticsScreen({
    super.key,
    required this.trip,
  });

  @override
  State<ExpenseStatisticsScreen> createState() =>
      _ExpenseStatisticsScreenState();
}

class _ExpenseStatisticsScreenState extends State<ExpenseStatisticsScreen> {
  final ExpenseService _expenseService = ExpenseService();
  ExpenseStatistics? _statistics;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }
  
  // 加载统计数据
  Future<void> _loadStatistics() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      
      // 获取支出统计
      final categoryStats = await _expenseService.getExpenseStatisticsByCategory(widget.trip.id);
      
      // 获取总支出
      final budget = await _expenseService.getTripBudget(widget.trip.id);
      final totalAmount = budget.totalExpense;
      
      // 转换为ExpenseCategory列表
      final List<ExpenseCategory> categories = [];
      
      categoryStats.forEach((name, amount) {
        // 计算百分比
        final percentage = totalAmount > 0 ? (amount / totalAmount * 100) : 0.0;
        
        // 根据类别名称设置图标和颜色
        String iconName;
        String colorCode;
        
        if (name.contains('餐') || name.contains('食')) {
          iconName = 'restaurant';
          colorCode = '#3B82F6'; // 蓝色
        } else if (name.contains('住') || name.contains('宿') || name.contains('酒店')) {
          iconName = 'hotel';
          colorCode = '#A855F7'; // 紫色
        } else if (name.contains('交') || name.contains('车') || name.contains('机票')) {
          iconName = 'directions_bus';
          colorCode = '#22C55E'; // 绿色
        } else if (name.contains('票') || name.contains('门票')) {
          iconName = 'confirmation_number';
          colorCode = '#F59E0B'; // 黄色
        } else if (name.contains('购') || name.contains('商品')) {
          iconName = 'shopping_bag';
          colorCode = '#EF4444'; // 红色
        } else {
          iconName = 'category';
          colorCode = '#6B7280'; // 灰色
        }
        
        categories.add(ExpenseCategory(
          id: name,
          name: name,
          amount: amount,
          percentage: double.parse(percentage.toStringAsFixed(1)),
          iconName: iconName,
          colorCode: colorCode,
        ));
      });
      
      // 按金额排序
      categories.sort((a, b) => b.amount.compareTo(a.amount));
      
      if (mounted) {
        setState(() {
          _statistics = ExpenseStatistics(
            totalAmount: totalAmount,
            categories: categories,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = '加载统计数据失败: $e';
        });
      }
      print('加载统计数据失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // 返回按钮
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 标题
                  const Text(
                    '支出统计',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),

            if (_isLoading)
              // 加载指示器
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('加载统计数据...'),
                    ],
                  ),
                ),
              )
            else if (_hasError)
              // 错误提示
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStatistics,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_statistics == null || _statistics!.categories.isEmpty)
              // 没有数据
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bar_chart,
                        color: Colors.grey,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '暂无支出数据',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '添加一些支出记录，这里将显示统计信息',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // 环形图表
              SizedBox(
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 环形图
                    CustomPaint(
                      size: const Size(200, 200),
                      painter: DonutChartPainter(
                        categories: _statistics!.categories,
                      ),
                    ),
                    // 中间的文字
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '总支出',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '¥${_statistics!.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 分类列表
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadStatistics,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _statistics!.categories.length,
                    itemBuilder: (context, index) {
                      final category = _statistics!.categories[index];
                      return _buildCategoryItem(category);
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 构建分类项
  Widget _buildCategoryItem(ExpenseCategory category) {
    // 解析颜色代码
    Color colorFromHex;
    try {
      final colorInt = int.parse(category.colorCode.replaceAll('#', '0xff'));
      colorFromHex = Color(colorInt);
    } catch (e) {
      colorFromHex = const Color(0xFF3B82F6); // 默认蓝色
    }
    
    // 设置背景色为主色的淡色版本
    final iconBgColor = colorFromHex.withOpacity(0.1);
    final iconColor = colorFromHex;
    final progressColor = colorFromHex;
    
    // 根据图标名称选择图标
    IconData iconData;
    switch (category.iconName) {
      case 'restaurant':
      case 'food':
        iconData = Icons.restaurant;
        break;
      case 'hotel':
      case 'lodging':
        iconData = Icons.hotel;
        break;
      case 'directions_bus':
      case 'transportation':
        iconData = Icons.directions_bus;
        break;
      case 'confirmation_number':
      case 'ticket':
        iconData = Icons.confirmation_number;
        break;
      case 'shopping_bag':
      case 'shopping':
        iconData = Icons.shopping_bag;
        break;
      default:
        iconData = Icons.category;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 左侧图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              // 类别名称
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              // 金额和百分比
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥${category.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    '${category.percentage}%',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: category.percentage / 100,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// 环形图表绘制类
class DonutChartPainter extends CustomPainter {
  final List<ExpenseCategory> categories;

  DonutChartPainter({required this.categories});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 30.0;

    // 设置起始角度
    double startAngle = -math.pi / 2;

    for (var category in categories) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // 从colorCode解析颜色
      try {
        final colorInt = int.parse(category.colorCode.replaceAll('#', '0xff'));
        paint.color = Color(colorInt);
      } catch (e) {
        // 如果解析失败，使用默认蓝色
        paint.color = const Color(0xFF3B82F6);
      }

      // 计算每个类别的扇区角度
      final sweepAngle = 2 * math.pi * (category.percentage / 100);

      // 绘制环形扇区
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      // 更新起始角度
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
