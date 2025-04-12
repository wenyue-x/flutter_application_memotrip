import 'package:flutter/material.dart';
import 'package:flutter_application_memotrip/models/trip.dart';
import 'package:flutter_application_memotrip/models/journal_entry.dart';
import 'package:flutter_application_memotrip/screens/trip_detail_info_screen.dart';
import 'package:flutter_application_memotrip/screens/trip_expense_screen.dart';
import 'package:flutter_application_memotrip/screens/add_journal_entry_screen.dart';
import 'package:flutter_application_memotrip/services/journal_service.dart';
import 'package:flutter_application_memotrip/services/trip_service.dart';
import 'package:intl/intl.dart';

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
  final JournalService _journalService = JournalService();
  final TripService _tripService = TripService();
  
  List<JournalEntry> _journalEntries = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }
  
  // 加载旅行日志数据
  Future<void> _loadJournalEntries() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      
      final entries = await _journalService.getJournalEntriesByTripId(widget.trip.id);
      
      setState(() {
        _journalEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = '加载日志失败: $e';
      });
      print('加载日志数据失败: $e');
    }
  }

  // 添加新的旅行日志
  Future<void> _addJournalEntry() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddJournalEntryScreen(
            trip: widget.trip,
          ),
        ),
      );

      // 如果返回了新的日志条目或返回true（表示已添加），刷新日志列表
      if (result != null && (result is JournalEntry || result == true)) {
        _loadJournalEntries();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadJournalEntries,
        child: SafeArea(
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
                    widget.trip.formattedDate,
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
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError) {
      return Expanded(
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
                onPressed: _loadJournalEntries,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (_journalEntries.isEmpty) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.note_add_outlined,
                color: Colors.grey,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                '还没有日志记录',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '点击 + 添加你的第一篇日志吧！',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
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

    // 从日期中提取日
    final String day = DateFormat('dd').format(entry.date);

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
                day,
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
                        final String imageUrl = entry.images[index];
                        return Container(
                          width: 80,
                          height: 80,
                          margin: EdgeInsets.only(
                              right: index != entry.images.length - 1 ? 8 : 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imageUrl.startsWith('http')
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  )
                                : Image.asset(
                                    imageUrl,
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
