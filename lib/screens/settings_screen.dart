import 'package:flutter/material.dart';
import 'package:flutter_application_memotrip/screens/edit_profile_screen.dart'; // 导入编辑资料页面
import 'package:flutter_application_memotrip/screens/login_screen.dart'; // 导入登录页面
import 'package:flutter_application_memotrip/services/auth_service.dart'; // 导入认证服务
import 'package:supabase_flutter/supabase_flutter.dart'; // 导入 Supabase

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _iCloudSyncEnabled = true;
  bool _isLoading = true;
  String? _username;
  String? _email;
  int? _tripCount; // 添加状态变量存储旅程数量

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        final data = await _supabase
            .from('users')
            .select('username, email')
            .eq('id', userId)
            .single(); // 使用 single() 获取单条记录

        // 查询旅程数量 (修正语法)
        final tripCount = await _supabase
            .from('trips')
            .count(CountOption.exact) // 使用 .count() 方法
            .eq('user_id', userId);

        if (mounted) {
          setState(() {
            _username = data['username'] as String?;
            _email = data['email'] as String?; // 保留邮箱，以备后用或调试
            _tripCount = tripCount; // 更新旅程数量
            _isLoading = false;
          });
        }
      } else {
         if (mounted) {
          setState(() {
            _isLoading = false; // 用户未登录
          });
         }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载用户信息失败: $e')),
        );
      }
      debugPrint('加载用户信息错误: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // 标题
              const Text(
                '设置',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),

              const SizedBox(height: 24),

              // 用户信息
              _buildUserInfoSection(), // 提取为单独的方法

              const SizedBox(height: 24),

              // iCloud同步
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // iCloud图标
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.cloud,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 文本
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'iCloud 同步',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '自动同步旅行数据',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 开关
                    Switch(
                      value: _iCloudSyncEnabled,
                      onChanged: (value) {
                        setState(() {
                          _iCloudSyncEnabled = value;
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 通知设置
              _buildSettingItem(
                icon: Icons.notifications,
                iconBgColor: Colors.purple[100]!,
                iconColor: Colors.purple,
                title: '通知设置',
                subtitle: '管理应用通知',
                onTap: () {
                  // 导航到通知设置页面
                },
              ),

              const SizedBox(height: 16),

              // 隐私设置
              _buildSettingItem(
                icon: Icons.shield,
                iconBgColor: Colors.green[100]!,
                iconColor: Colors.green,
                title: '隐私设置',
                subtitle: '管理数据和隐私',
                onTap: () {
                  // 导航到隐私设置页面
                },
              ),

              const SizedBox(height: 16),

              // 帮助与反馈
              _buildSettingItem(
                icon: Icons.help,
                iconBgColor: Colors.orange[100]!,
                iconColor: Colors.orange,
                title: '帮助与反馈',
                subtitle: '获取帮助或提供反馈',
                onTap: () {
                  // 导航到帮助与反馈页面
                },
              ),

              const Spacer(),

              // 退出登录按钮
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      // 退出登录逻辑
                      _showLogoutConfirmDialog(context);
                    },
                    child: const Text(
                      '退出登录',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建用户信息部分
  Widget _buildUserInfoSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 用户头像 (保持不变)
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 用户名和邮箱/记录数
          Expanded( // 使用 Expanded 避免溢出
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username ?? '用户名加载失败', // 显示获取到的用户名
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis, // 处理长用户名
                ),
                const SizedBox(height: 4),
                Text(
                  // 显示旅程数量
                  _tripCount != null ? '$_tripCount 段旅程' : '旅程数量加载中...',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                   overflow: TextOverflow.ellipsis, // 处理长邮箱
                ),
              ],
            ),
          ),
          // 添加编辑按钮
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF9CA3AF)),
            onPressed: () {
              // 导航到编辑页面 (稍后实现)
              _navigateToEditProfile();
            },
            tooltip: '编辑资料', // 添加提示
          ),
        ],
      ),
    );
  }

  // 导航到编辑资料页面
  Future<void> _navigateToEditProfile() async { // 改为 async
    // 导航到编辑页面，并等待返回结果
    final result = await Navigator.push<bool>( // 指定返回类型为 bool
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );

    // 如果从编辑页面返回的结果是 true (表示保存成功)
    if (result == true && mounted) {
      // 重新加载用户信息以刷新显示
      _loadUserProfile();
    }
  }


  // 构建设置项
  Widget _buildSettingItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            // 文本
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            // 箭头
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  // 退出登录确认对话框
  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认退出登录'),
          content: const Text('您确定要退出登录吗?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                // 在 pop 之前捕获 NavigatorState
                final navigator = Navigator.of(context);
                // 捕获 ScaffoldMessengerState 以便在正确的 context 显示 SnackBar
                final scaffoldMessenger = ScaffoldMessenger.of(this.context);

                navigator.pop(); // 关闭对话框

                try {
                  final authService = AuthService();
                  await authService.signOut();
                  // 退出成功后，跳转到登录页并移除所有历史路由
                  // 使用捕获的 navigator 进行操作
                  if (mounted) { // 检查 widget 是否还在树中
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false, // 移除所有路由
                    );
                  }
                } catch (e) {
                  // 处理退出登录错误
                  // 使用捕获的 scaffoldMessenger 显示 SnackBar
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('退出登录失败: $e')),
                    );
                  }
                  debugPrint('退出登录错误: $e');
                }
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }
}
