import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  // 倒计时逻辑
  int _countdownSeconds = 0;
  bool get _isCountingDown => _countdownSeconds > 0;

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

                // 手机号输入框
                _buildInputField(
                  controller: _phoneController,
                  hintText: '手机号',
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 16),

                // 验证码输入框和按钮
                Row(
                  children: [
                    // 验证码输入框
                    Expanded(
                      flex: 2,
                      child: _buildInputField(
                        controller: _verificationCodeController,
                        hintText: '验证码',
                        keyboardType: TextInputType.number,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // 获取验证码按钮
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              _isCountingDown ? null : _getVerificationCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF9FAFB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: const Color(0xFFF9FAFB),
                          ),
                          child: Text(
                            _isCountingDown ? '$_countdownSeconds秒' : '获取验证码',
                            style: TextStyle(
                              fontSize: 14,
                              color: _isCountingDown
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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

                // 注册按钮
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '注册',
                      style: TextStyle(
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

  // 获取验证码
  void _getVerificationCode() {
    // 验证手机号
    if (_phoneController.text.isEmpty) {
      _showMessage('请输入手机号');
      return;
    }

    // 模拟发送验证码
    setState(() {
      _countdownSeconds = 60;
    });

    // 启动倒计时
    _startCountdown();

    _showMessage('验证码已发送');
  }

  // 倒计时
  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
        _startCountdown();
      }
    });
  }

  // 注册
  void _register() {
    // 验证输入
    if (_phoneController.text.isEmpty) {
      _showMessage('请输入手机号');
      return;
    }

    if (_verificationCodeController.text.isEmpty) {
      _showMessage('请输入验证码');
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

    // 模拟注册成功
    _showMessage('注册成功');

    // 回到登录页面
    Navigator.pop(context);
  }

  // 显示消息
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
