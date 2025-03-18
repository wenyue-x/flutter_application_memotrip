import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_memotrip/models/trip.dart';
import 'package:flutter_application_memotrip/models/expense.dart';
import 'package:flutter_application_memotrip/screens/expense_statistics_screen.dart';
import 'package:intl/intl.dart';

class TripExpenseScreen extends StatefulWidget {
  final Trip trip;

  const TripExpenseScreen({
    super.key,
    required this.trip,
  });

  @override
  State<TripExpenseScreen> createState() => _TripExpenseScreenState();
}

class _TripExpenseScreenState extends State<TripExpenseScreen> {
  late TripBudget _tripBudget;
  late List<Expense> _expenses;

  @override
  void initState() {
    super.initState();
    // 初始化旅行预算和消费数据
    _tripBudget = TripBudget(
      totalExpense: 25630,
      budget: 35000,
      remaining: 9370,
    );

    // 初始化消费记录
    _expenses = [
      Expense(
        id: '1',
        title: '寿司午餐',
        amount: 3200,
        date: DateTime(2024, 2, 15, 13, 20),
        category: '餐饮',
        icon: 'utensils',
      ),
      Expense(
        id: '2',
        title: '地铁票',
        amount: 500,
        date: DateTime(2024, 2, 15, 10, 30),
        category: '交通',
        icon: 'subway',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        '旅行账本',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const Spacer(),
                      // 统计按钮
                      Row(
                        children: [
                          const Icon(
                            Icons.pie_chart,
                            color: Color(0xFF3B82F6),
                            size: 18,
                          ),
                          TextButton(
                            onPressed: () {
                              // 跳转到统计页面
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExpenseStatisticsScreen(
                                    trip: widget.trip,
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              '统计',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 总支出卡片
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 总支出标签
                      const Opacity(
                        opacity: 0.8,
                        child: Text(
                          '总支出',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 总支出金额
                      Text(
                        '¥ ${_tripBudget.totalExpense.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 预算和剩余
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 预算
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Opacity(
                                opacity: 0.8,
                                child: Text(
                                  '预算',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                '¥${_tripBudget.budget.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                          // 剩余
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Opacity(
                                opacity: 0.8,
                                child: Text(
                                  '剩余',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                '¥${_tripBudget.remaining.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 消费记录列表
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return _buildExpenseItem(expense);
                    },
                  ),
                ),
              ],
            ),

            // 添加按钮
            Positioned(
              right: 24,
              bottom: 24,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    // 添加新的消费记录
                    _showAddExpenseBottomSheet(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建消费项
  Widget _buildExpenseItem(Expense expense) {
    // 根据类别选择不同的颜色和图标
    Color iconBgColor;
    Color iconColor;
    IconData iconData;

    switch (expense.category) {
      case '餐饮':
        iconBgColor = const Color(0xFFDBEAFE); // 蓝色背景
        iconColor = const Color(0xFF3B82F6); // 蓝色图标
        iconData = Icons.restaurant;
        break;
      case '交通':
        iconBgColor = const Color(0xFFF3E8FF); // 紫色背景
        iconColor = const Color(0xFFA855F7); // 紫色图标
        iconData = Icons.train;
        break;
      default:
        iconBgColor = const Color(0xFFDBEAFE);
        iconColor = const Color(0xFF3B82F6);
        iconData = Icons.receipt;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
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
          // 中间的标题和时间
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy.MM.dd HH:mm').format(expense.date),
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          // 右侧金额
          Text(
            '¥${expense.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  // 显示添加支出的底部表单
  void _showAddExpenseBottomSheet(BuildContext context) {
    final TextEditingController _amountController = TextEditingController();
    final TextEditingController _noteController = TextEditingController();
    String _selectedCategory = '餐饮'; // 默认选择餐饮类别

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 顶部标题和关闭按钮
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '添加支出',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF9CA3AF),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 金额部分
                        const Text(
                          '金额',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Text(
                                  '¥',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: '输入支出金额',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 分类部分
                        const Text(
                          '分类',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCategoryOption(
                                context,
                                '餐饮',
                                Icons.restaurant,
                                const Color(0xFFDBEAFE),
                                const Color(0xFF3B82F6),
                                _selectedCategory, (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }),
                            _buildCategoryOption(
                                context,
                                '住宿',
                                Icons.hotel,
                                const Color(0xFFF3E8FF),
                                const Color(0xFFA855F7),
                                _selectedCategory, (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }),
                            _buildCategoryOption(
                                context,
                                '交通',
                                Icons.directions_bus,
                                const Color(0xFFDCFCE7),
                                const Color(0xFF22C55E),
                                _selectedCategory, (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }),
                            _buildCategoryOption(
                                context,
                                '其他',
                                Icons.more_horiz,
                                const Color(0xFFFFEDD5),
                                const Color(0xFFF97316),
                                _selectedCategory, (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 备注部分
                        const Text(
                          '备注',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              hintText: '添加备注',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9CA3AF),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 保存按钮
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: ElevatedButton(
                    onPressed: () {
                      // 验证并保存支出
                      if (_amountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请输入支出金额')),
                        );
                        return;
                      }

                      // 创建新支出
                      final newExpense = Expense(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _noteController.text.isEmpty
                            ? '$_selectedCategory消费'
                            : _noteController.text,
                        amount: double.parse(_amountController.text),
                        date: DateTime.now(),
                        category: _selectedCategory,
                        icon: _getCategoryIcon(_selectedCategory),
                      );

                      // 添加到支出列表并更新总支出
                      setState(() {
                        _expenses.insert(0, newExpense);
                        _tripBudget = TripBudget(
                          totalExpense:
                              _tripBudget.totalExpense + newExpense.amount,
                          budget: _tripBudget.budget,
                          remaining: _tripBudget.budget -
                              (_tripBudget.totalExpense + newExpense.amount),
                        );
                      });

                      Navigator.pop(context);

                      // 刷新页面显示
                      this.setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '保存',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // 构建分类选项
  Widget _buildCategoryOption(
      BuildContext context,
      String category,
      IconData icon,
      Color bgColor,
      Color iconColor,
      String selectedCategory,
      Function(String) onSelected) {
    final isSelected = category == selectedCategory;

    return GestureDetector(
      onTap: () {
        onSelected(category);
      },
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 根据类别获取图标名称
  String _getCategoryIcon(String category) {
    switch (category) {
      case '餐饮':
        return 'restaurant';
      case '住宿':
        return 'hotel';
      case '交通':
        return 'directions_bus';
      case '其他':
        return 'more_horiz';
      default:
        return 'receipt';
    }
  }
}
