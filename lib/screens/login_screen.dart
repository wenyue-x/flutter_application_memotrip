import 'package:flutter/material.dart';
import 'package:flutter_application_memotrip/screens/home_screen.dart';
import 'package:flutter_application_memotrip/screens/register_screen.dart';
import 'package:flutter_application_memotrip/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 旅记标题
              const Text(
                '旅记',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 48),

              // 邮箱输入框
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: '邮箱',
                    hintStyle: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // OTP输入框 - 只在OTP已发送时显示
              if (_otpSent)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '验证码',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // 登录按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                      : Text(
                          _otpSent ? '验证并登录' : '获取验证码',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Apple登录按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loginWithApple,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.apple, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        '使用Apple账号登录',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 注册链接
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '还没有账号？',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  TextButton(
                    onPressed: _goToRegister,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '立即注册',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 登录流程
  Future<void> _login() async {
    if (!_otpSent) {
      // 第一步：发送OTP
      await _sendOTP();
    } else {
      // 第二步：验证OTP
      await _verifyOTPAndLogin();
    }
  }
  
  // 发送OTP
  Future<void> _sendOTP() async {
    // 简单验证
    if (_emailController.text.isEmpty) {
      _showMessage('请输入邮箱');
      return;
    }
    
    // 邮箱格式验证
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(_emailController.text)) {
      _showMessage('请输入有效的邮箱地址');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _authService.signInWithOTP(
        email: _emailController.text.trim(),
      );
      
      setState(() {
        _otpSent = true;
      });
      
      _showMessage('验证码已发送至您的邮箱');
    } catch (e) {
      _showMessage('发送验证码失败：${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // 验证OTP并登录
  Future<void> _verifyOTPAndLogin() async {
    if (_otpController.text.isEmpty) {
      _showMessage('请输入验证码');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await _authService.verifyOTP(
        email: _emailController.text.trim(),
        token: _otpController.text.trim(),
      );
      
      if (response.user != null) {
        _navigateToHome();
      } else {
        _showMessage('登录失败，请检查验证码');
      }
    } catch (e) {
      _showMessage('登录失败：${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 使用Apple账号登录
  void _loginWithApple() {
    // 此处应实现Apple账号登录逻辑
    _showMessage('Apple登录功能正在开发中');
  }

  // 前往注册页面
  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  // 导航到首页
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  // 显示消息
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
