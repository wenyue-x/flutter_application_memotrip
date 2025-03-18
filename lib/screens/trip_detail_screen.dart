import 'package:flutter/material.dart';
import 'package:flutter_application_memotrip/models/trip.dart';
import 'package:flutter_application_memotrip/models/journal_entry.dart';
import 'package:flutter_application_memotrip/screens/trip_detail_info_screen.dart';
import 'package:flutter_application_memotrip/screens/trip_expense_screen.dart';
import 'package:flutter_application_memotrip/screens/add_journal_entry_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({
    super.key,
    required this.trip,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  // 模拟的日志数据
  late List<JournalEntry> _journalEntries;

  @override
  void initState() {
    super.initState();
    // 根据不同目的地生成不同的模拟数据
    if (widget.trip.destination == '东京') {
      _journalEntries = _getTokyoJournalEntries();
    } else {
      _journalEntries = [];
    }
  }

  // 获取东京旅行的模拟日志数据
  List<JournalEntry> _getTokyoJournalEntries() {
    return [
      JournalEntry(
        id: '1',
        time: '上午 9:30',
        content: '到达成田机场，开始我的东京之旅！这是我第一次来到日本，非常激动。机场很大，但标识清晰，很容易找到出口。',
        images: [
          'assets/images/tokyo_airport.jpg',
          'assets/images/tokyo_street.jpg',
          'assets/images/tokyo_food.jpg',
        ],
        date: '15',
        location: '成田国际机场',
      ),
      JournalEntry(
        id: '2',
        time: '下午 3:15',
        content: '参观了东京塔，真的很壮观。从塔顶可以俯瞰整个东京市区，风景太美了！',
        images: [],
        date: '15',
        location: '东京塔',
      ),
    ];
  }

  // 添加新的旅行记录
  Future<void> _addJournalEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddJournalEntryScreen(
          trip: widget.trip,
        ),
      ),
    );

    // 如果返回了新的日志条目，添加到列表中
    if (result != null && result is JournalEntry) {
      setState(() {
        _journalEntries.add(result);
        // 按日期排序（如果需要）
        _journalEntries
            .sort((a, b) => int.parse(b.date).compareTo(int.parse(a.date)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildJournalSection(),
            ],
          ),
        ),
      ),
      // 底部导航栏 - 完全符合设计图
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.only(bottom: 16.0),
        alignment: Alignment.center,
        child: Container(
          width: 190, // 固定宽度，根据设计图尺寸
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 详情页图标
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripDetailInfoScreen(
                        trip: widget.trip,
                      ),
                    ),
                  );
                },
                child: const Icon(
                  Icons.article_outlined, // 详情页图标
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
              ),
              // 中间的加号按钮
              GestureDetector(
                onTap: _addJournalEntry,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // 记账页图标
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripExpenseScreen(
                        trip: widget.trip,
                      ),
                    ),
                  );
                },
                child: const Icon(
                  Icons.account_balance_wallet_outlined, // 记账页图标
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建页面头部
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部导航栏和标题
        Row(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.trip.destination}之旅',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2024.02.15 - 2024.02.20',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 构建日志部分
  Widget _buildJournalSection() {
    if (_journalEntries.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text('还没有日志记录，点击 + 添加你的第一篇日志吧！'),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        itemCount: _journalEntries.length,
        itemBuilder: (context, index) {
          final entry = _journalEntries[index];
          return _buildJournalEntryItem(entry);
        },
      ),
    );
  }

  // 构建单个日志条目 - 根据设计图调整布局
  Widget _buildJournalEntryItem(JournalEntry entry) {
    // 计算内容预估高度，用于动态调整垂直线长度
    final bool hasImages = entry.images.isNotEmpty;
    final bool hasLocation =
        entry.location != null && entry.location!.isNotEmpty;

    // 基础高度 + 内容预估高度 + 图片高度(如果有) + 位置信息高度(如果有)
    final double estimatedHeight = 100 +
        (entry.content.length / 30) * 20 +
        (hasImages ? 96 : 0) +
        (hasLocation ? 40 : 0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧日期和垂直线
        Column(
          children: [
            // 日期圆圈
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
              child: Text(
                entry.date,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            // 垂直连接线 - 动态高度
            Container(
              height: estimatedHeight,
              width: 1,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey[300],
            ),
          ],
        ),
        const SizedBox(width: 16),
        // 右侧内容部分
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 时间
                Text(
                  entry.time,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                // 内容 - 移除了位置图标
                Text(
                  entry.content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                ),

                // 图片网格 - 如果有图片则显示
                if (hasImages) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.images.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 80,
                          height: 80,
                          margin: EdgeInsets.only(
                              right: index != entry.images.length - 1 ? 8 : 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: AssetImage(entry.images[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // 位置信息 - 如果有位置信息则显示
                if (hasLocation) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          entry.location!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
