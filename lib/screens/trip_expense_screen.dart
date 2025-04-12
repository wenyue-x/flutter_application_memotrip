import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_memotrip/models/trip.dart';
import 'package:flutter_application_memotrip/models/expense.dart';
import 'package:flutter_application_memotrip/screens/expense_statistics_screen.dart';
import 'package:flutter_application_memotrip/services/expense_service.dart';
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
  final ExpenseService _expenseService = ExpenseService();
  
  TripBudget? _tripBudget;
  List<Expense> _expenses = [];
  List<ExpenseCategory> _categories = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadExpenseData();
  }
  
  // 加载支出数据
  Future<void> _loadExpenseData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      
      // 获取旅行预算信息
      final budget = await _expenseService.getTripBudget(widget.trip.id);
      
      // 获取支出列表
      final expenses = await _expenseService.getExpensesByTripId(widget.trip.id);
      
      // 获取支出类别
      final categories = await _expenseService.getExpenseCategories();
      
      if (mounted) {
        setState(() {
          _tripBudget = budget;
          _expenses = expenses;
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = '加载支出数据失败: $e';
        });
      }
      print('加载支出数据失败: $e');
    }
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

                if (_isLoading)
                  // 加载指示器
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('加载支出数据...'),
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
                            onPressed: _loadExpenseData,
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
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
                          _tripBudget!.formattedTotalExpense,
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
                                  _tripBudget!.formattedBudget,
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
                                  _tripBudget!.formattedRemaining,
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
                        
                        // 预算进度条
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: _tripBudget!.usagePercentage,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            color: Colors.white,
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 支出记录列表
                  _expenses.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  '暂无支出记录',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '点击 + 添加您的第一笔支出',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadExpenseData,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _expenses.length,
                              itemBuilder: (context, index) {
                                final expense = _expenses[index];
                                return Dismissible(
                                  key: Key(expense.id),
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20.0),
                                    color: Colors.red,
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (direction) async {
                                    return await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('确认删除'),
                                        content: const Text('确定要删除这条支出记录吗？'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('取消'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text('删除'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  onDismissed: (direction) async {
                                    try {
                                      // 删除支出
                                      await _expenseService.deleteExpense(expense.id);
                                      // 刷新预算信息
                                      final newBudget = await _expenseService.getTripBudget(widget.trip.id);
                                      
                                      setState(() {
                                        _expenses.removeAt(index);
                                        _tripBudget = newBudget;
                                      });
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('支出已删除')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('删除失败: $e')),
                                      );
                                    }
                                  },
                                  child: _buildExpenseItem(expense),
                                );
                              },
                            ),
                          ),
                        ),
                ],
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

    // 默认颜色和图标
    iconBgColor = const Color(0xFFDBEAFE);
    iconColor = const Color(0xFF3B82F6);
    iconData = Icons.receipt;
    
    // 如果有颜色代码，尝试解析它
    if (expense.colorCode != null) {
      try {
        final colorInt = int.parse(expense.colorCode!.replaceAll('#', '0xff'));
        iconBgColor = Color(colorInt).withOpacity(0.1);
        iconColor = Color(colorInt);
      } catch (e) {
        print('颜色代码解析失败: ${expense.colorCode}');
      }
    }
    
    // 根据图标名称选择图标
    if (expense.iconName != null) {
      switch (expense.iconName) {
        case 'restaurant':
        case 'food':
          iconData = Icons.restaurant;
          break;
        case 'hotel':
        case 'lodging':
          iconData = Icons.hotel;
          break;
        case 'train':
        case 'transportation':
        case 'directions_bus':
          iconData = Icons.directions_bus;
          break;
        case 'shopping':
        case 'shopping_bag':
          iconData = Icons.shopping_bag;
          break;
        case 'ticket':
        case 'confirmation_number':
          iconData = Icons.confirmation_number;
          break;
        default:
          iconData = Icons.receipt;
      }
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
                    onPressed: () async {
                      // 验证并保存支出
                      if (_amountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请输入支出金额')),
                        );
                        return;
                      }

                      try {
                        // 获取与所选类别名称匹配的类别ID
                        String categoryId = '';
                        for (var category in _categories) {
                          if (category.name == _selectedCategory) {
                            categoryId = category.id;
                            break;
                          }
                        }
                        
                        if (categoryId.isEmpty && _categories.isNotEmpty) {
                          // 如果没找到匹配的类别，使用第一个类别
                          categoryId = _categories.first.id;
                        }

                        // 使用 ExpenseService 创建新支出
                        final newExpense = await _expenseService.createExpense(
                          tripId: widget.trip.id,
                          title: _noteController.text.isEmpty
                              ? '$_selectedCategory消费'
                              : _noteController.text,
                          amount: double.parse(_amountController.text),
                          date: DateTime.now(),
                          categoryId: categoryId,
                        );

                        // 关闭底部表单
                        Navigator.pop(context);
                        
                        // 刷新预算和支出列表
                        await _loadExpenseData();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('支出已添加')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('添加支出失败: $e')),
                        );
                      }
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
