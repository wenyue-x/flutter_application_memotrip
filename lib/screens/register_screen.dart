import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_application_memotrip/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 返回按钮
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF1F2937),
                    size: 24,
                  ),
                ),

                const SizedBox(height: 24),

                // 标题
                const Center(
                  child: Text(
                    '创建账号',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 副标题
                const Center(
                  child: Text(
                    '开启你的旅行记录之旅',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 邮箱输入框
                _buildInputField(
                  controller: _emailController,
                  hintText: '邮箱',
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                // 昵称输入框
                _buildInputField(
                  controller: _nicknameController,
                  hintText: '昵称',
                ),

                const SizedBox(height: 16),

                // 密码输入框
                _buildInputField(
                  controller: _passwordController,
                  hintText: '密码',
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF9CA3AF),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // 确认密码输入框
                _buildInputField(
                  controller: _confirmPasswordController,
                  hintText: '确认密码',
                  obscureText: !_isConfirmPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF9CA3AF),
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 服务协议和隐私政策
                Row(
                  children: [
                    // 复选框
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    // 文本
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                          children: [
                            const TextSpan(
                              text: '我已阅读并同意',
                            ),
                            TextSpan(
                              text: '服务协议',
                              style: const TextStyle(
                                color: Color(0xFF3B82F6),
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // 打开服务协议
                                  _showMessage('服务协议功能正在开发中');
                                },
                            ),
                            const TextSpan(
                              text: '和',
                            ),
                            TextSpan(
                              text: '隐私政策',
                              style: const TextStyle(
                                color: Color(0xFF3B82F6),
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // 打开隐私政策
                                  _showMessage('隐私政策功能正在开发中');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // OTP输入框（仅当OTP已发送时显示）
                if (_otpSent) ...[
                  const SizedBox(height: 16),
                  
                  // OTP输入框
                  _buildInputField(
                    controller: _otpController,
                    hintText: '验证码',
                    keyboardType: TextInputType.number,
                  ),
                ],

                const SizedBox(height: 24),

                // 注册按钮
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                            _otpSent ? '验证并完成注册' : '获取验证码',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30), // 底部留白
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建输入框
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }


  // 注册
  Future<void> _register() async {
    if (!_otpSent) {
      // 第一步：发送OTP
      await _sendOTP();
    } else {
      // 第二步：验证OTP并完成注册
      await _verifyOTPAndRegister();
    }
  }

  // 发送OTP
  Future<void> _sendOTP() async {
    // 验证输入
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

    if (_nicknameController.text.isEmpty) {
      _showMessage('请输入昵称');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showMessage('请输入密码');
      return;
    }

    if (_confirmPasswordController.text.isEmpty) {
      _showMessage('请确认密码');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('两次输入的密码不一致');
      return;
    }

    if (!_agreeToTerms) {
      _showMessage('请同意服务协议和隐私政策');
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

  // 验证OTP并完成注册
  Future<void> _verifyOTPAndRegister() async {
    if (_otpController.text.isEmpty) {
      _showMessage('请输入验证码');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await _authService.verifyOTPAndSignUp(
        email: _emailController.text.trim(),
        token: _otpController.text.trim(),
        password: _passwordController.text,
        username: _nicknameController.text.trim(),
      );
      
      if (response.user != null) {
        _showMessage('注册成功');
        Navigator.pop(context); // 回到登录页面
      } else {
        _showMessage('注册失败，请稍后重试');
      }
    } catch (e) {
      _showMessage('注册失败：${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 显示消息
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
