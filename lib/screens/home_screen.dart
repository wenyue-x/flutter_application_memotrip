import 'package:flutter/material.dart';
import 'package:flutter_application_memotrip/models/trip.dart';
import 'package:flutter_application_memotrip/screens/trip_detail_screen.dart';
import 'package:flutter_application_memotrip/screens/create_trip_screen.dart';
import 'package:flutter_application_memotrip/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 示例旅行数据
  List<Trip> trips = [
    Trip(
      id: '1',
      destination: '巴黎',
      date: '2024.03',
      imageUrl: 'assets/images/paris.jpg',
    ),
    Trip(
      id: '2',
      destination: '东京',
      date: '2024.02',
      imageUrl: 'assets/images/tokyo.jpg',
    ),
  ];

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
                          trips.sort((a, b) => b.date.compareTo(a.date));
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
                      onTap: () {
                        // 跳转到旅行详情页
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripDetailScreen(
                              trip: trips[index],
                            ),
                          ),
                        );
                      },
                      child: buildTripCard(trips[index]),
                    );
                  },
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
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
                child: Icon(
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图片
            Image.asset(
              trip.imageUrl,
              fit: BoxFit.cover,
            ),

            // 渐变遮罩
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
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
                  Text(
                    trip.destination,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trip.date,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
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
