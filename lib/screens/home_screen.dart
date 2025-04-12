import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_memotrip/models/trip.dart';
import 'package:flutter_application_memotrip/screens/trip_detail_screen.dart';
import 'package:flutter_application_memotrip/screens/create_trip_screen.dart';
import 'package:flutter_application_memotrip/screens/settings_screen.dart';
import 'package:flutter_application_memotrip/services/trip_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TripService _tripService = TripService();
  List<Trip> trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  // 加载旅行数据
  Future<void> _loadTrips() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final tripList = await _tripService.getTrips();
      
      setState(() {
        trips = tripList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('加载旅行列表失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行 - 包含"我的旅程"标题和添加按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '我的旅程',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // 添加按钮
                  ElevatedButton(
                    onPressed: () async {
                      // 导航到创建旅程页面，并等待返回结果
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateTripScreen()),
                      );

                      // 如果返回了新旅程数据，添加到旅程列表
                      if (result != null && result is Trip) {
                        setState(() {
                          trips.add(result);
                          // 按日期排序（如果需要）
                          trips.sort((a, b) => b.startDate.compareTo(a.startDate));
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6), // 蓝色
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      elevation: 0,
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 旅行卡片网格
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : trips.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon( // Can be const if color is const
                                  Icons.flight_takeoff,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text( // Cannot be const due to TextStyle
                                  '还没有旅行记录',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text( // Cannot be const due to TextStyle
                                  '点击 + 按钮创建您的第一次旅行',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadTrips,
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.8, // 控制卡片高宽比
                              ),
                              itemCount: trips.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    // 跳转到旅行详情页
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TripDetailScreen(
                                          trip: trips[index],
                                        ),
                                      ),
                                    );
                                    
                                    // 如果从详情页返回结果，刷新列表
                                    if (result == true) {
                                      _loadTrips();
                                    }
                                  },
                                  child: buildTripCard(trips[index]),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      // 底部导航栏
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [ // Can be const
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1), // Use const Color
                blurRadius: 15,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon( // Cannot be const due to color
                Icons.home,
                color: Colors.blue[600],
                size: 24,
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                },
                child: Icon( // Can be const if color is const
                  Icons.settings,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建旅行卡片的方法
  Widget buildTripCard(Trip trip) {
    // Cannot make the root Container const because trip is variable
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [ // Can be const
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1), // Use const Color
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图片 - 根据是否有图片URL选择网络图片或默认图片
            trip.imageUrl != null && trip.imageUrl!.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: trip.imageUrl!,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, progress) => Center(
                      child: CircularProgressIndicator(
                        value: progress.progress,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : trip.imageUrl != null
                    ? Image.asset( // Cannot be const due to trip.imageUrl!
                        trip.imageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container( // Cannot be const due to color
                        color: Colors.grey[300],
                        child: Icon( // Can be const if color is const
                          Icons.travel_explore,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                      ),

            // 渐变遮罩
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container( // Cannot be const due to BoxDecoration
                height: 60,
                decoration: const BoxDecoration( // Can be const
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [ // Can be const
                      Color.fromRGBO(0, 0, 0, 0.7), // Use const Color
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 目的地和日期文本
            Positioned(
              bottom: 12,
              left: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text( // Cannot be const due to trip.destination
                    trip.destination,
                    style: const TextStyle( // Style can be const
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text( // Cannot be const due to trip.formattedDate and style
                    trip.formattedDate,
                    style: const TextStyle( // Cannot be const due to withOpacity
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
