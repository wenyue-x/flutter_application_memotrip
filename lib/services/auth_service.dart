import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 负责处理 Supabase 认证相关操作的服务类
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 获取当前登录用户
  User? get currentUser => _supabase.auth.currentUser;

  /// 判断用户是否已登录
  bool get isLoggedIn => currentUser != null;

  /// 获取当前用户ID
  String? get currentUserId => currentUser?.id;

  /// 发送OTP验证码（适用于注册和登录）
  Future<void> signInWithOTP({
    required String email,
  }) async {
    await _supabase.auth.signInWithOtp(
      email: email,
    );
  }

  /// 验证OTP并登录
  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
  }) async {
    final AuthResponse res = await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
    
    return res;
  }

  /// 验证OTP并完成注册
  Future<AuthResponse> verifyOTPAndSignUp({
    required String email, 
    required String token,
    required String password,
    String? username,
  }) async {
    // 使用OTP验证注册
    final AuthResponse res = await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
    
    // 如果注册成功，向users表插入用户数据
    if (res.user != null) {
      try {
        await _supabase.from('users').insert({
          'id': res.user!.id,
          'email': email,
          'password': password, // 注意：在实际项目中应该加密存储
          'username': username,
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('向users表插入数据失败: $e');
        // 此处不抛出异常，因为Auth注册已经成功
      }
    }
    
    return res;
  }

  /// 退出登录
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// 更新用户信息
  Future<void> updateUserProfile({
    String? username,
    String? avatarUrl,
  }) async {
    final String? userId = currentUserId;
    if (userId == null) return;
    
    await _supabase.from('users').update({
      if (username != null) 'username': username,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    }).eq('id', userId);
  }

  /// 发送重置密码邮件
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
