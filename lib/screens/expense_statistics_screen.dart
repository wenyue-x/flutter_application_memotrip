import 'package:flutter/material.dart';
import 'package:flutter_application_memotrip/models/trip.dart';
import 'package:flutter_application_memotrip/models/expense_statistics.dart';
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
  late ExpenseStatistics _statistics;

  @override
  void initState() {
    super.initState();

    // 初始化消费统计数据
    _statistics = ExpenseStatistics(
      totalAmount: 25630,
      categories: [
        ExpenseCategory(
          id: '1',
          name: '餐饮美食',
          amount: 12500,
          percentage: 48.8,
          iconName: 'restaurant',
          colorCode: '#3B82F6', // 蓝色
        ),
        ExpenseCategory(
          id: '2',
          name: '住宿',
          amount: 8630,
          percentage: 33.7,
          iconName: 'hotel',
          colorCode: '#A855F7', // 紫色
        ),
        ExpenseCategory(
          id: '3',
          name: '交通',
          amount: 4500,
          percentage: 17.5,
          iconName: 'directions_bus',
          colorCode: '#22C55E', // 绿色
        ),
      ],
    );
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
                      categories: _statistics.categories,
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
                        '¥${_statistics.totalAmount.toStringAsFixed(0)}',
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
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _statistics.categories.length,
                itemBuilder: (context, index) {
                  final category = _statistics.categories[index];
                  return _buildCategoryItem(category);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建分类项
  Widget _buildCategoryItem(ExpenseCategory category) {
    // 根据不同类别选择不同的颜色和图标
    Color iconBgColor;
    Color iconColor;
    IconData iconData;
    Color progressColor;

    switch (category.name) {
      case '餐饮美食':
        iconBgColor = const Color(0xFFDBEAFE); // 蓝色背景
        iconColor = const Color(0xFF3B82F6); // 蓝色图标
        iconData = Icons.restaurant;
        progressColor = const Color(0xFF3B82F6);
        break;
      case '住宿':
        iconBgColor = const Color(0xFFF3E8FF); // 紫色背景
        iconColor = const Color(0xFFA855F7); // 紫色图标
        iconData = Icons.hotel;
        progressColor = const Color(0xFFA855F7);
        break;
      case '交通':
        iconBgColor = const Color(0xFFDCFCE7); // 绿色背景
        iconColor = const Color(0xFF22C55E); // 绿色图标
        iconData = Icons.directions_bus;
        progressColor = const Color(0xFF22C55E);
        break;
      default:
        iconBgColor = const Color(0xFFDBEAFE);
        iconColor = const Color(0xFF3B82F6);
        iconData = Icons.category;
        progressColor = const Color(0xFF3B82F6);
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

      // 根据类别设置颜色
      switch (category.name) {
        case '餐饮美食':
          paint.color = const Color(0xFF3B82F6);
          break;
        case '住宿':
          paint.color = const Color(0xFFA855F7);
          break;
        case '交通':
          paint.color = const Color(0xFF22C55E);
          break;
        default:
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
