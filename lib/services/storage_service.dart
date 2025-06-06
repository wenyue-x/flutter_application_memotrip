import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// 负责处理 Supabase 存储相关操作的服务类
class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();
  
  // 存储桶名称
  static const String _tripBucket = 'trip';
  static const String _journalBucket = 'journal';
  static const String _profileBucket = 'profile';

  /// 上传旅行图片
  Future<String> uploadTripImage(File imageFile) async {
    return _uploadImage(imageFile, _tripBucket);
  }

  /// 上传日志图片
  Future<String> uploadJournalImage(File imageFile) async {
    return _uploadImage(imageFile, _journalBucket);
  }

  /// 上传个人头像
  Future<String> uploadProfileImage(File imageFile) async {
    return _uploadImage(imageFile, _profileBucket);
  }

  /// 通用上传图片方法
  Future<String> _uploadImage(File imageFile, String bucket) async {
    try {
      // 检查用户是否已登录
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('用户未登录，无法上传图片');
      }

      // 生成唯一的文件名 - 强制使用.jpg格式
      final String fileName = '${const Uuid().v4()}.jpg';
      
      // 上传文件到 Supabase Storage (携带JWT令牌)
       await _supabase
          .storage
          .from(bucket)
          .upload(
            fileName, 
            imageFile,
            fileOptions: const FileOptions(
              upsert: false,
              contentType: 'image/jpeg',
              cacheControl: '3600',
            ),
          );
      
      // 获取公共访问 URL 并添加优化参数
      final imageUrl = _supabase.storage.from(bucket).getPublicUrl(fileName);
      
      return '$imageUrl?width=1080&quality=80';
    } catch (e) {
      debugPrint('上传图片失败: $e');
      rethrow;
    }
  }

  /// 删除图片
  Future<void> deleteImage(String imageUrl, String bucket) async {
    try {
      // 从 URL 中提取文件路径
      final Uri uri = Uri.parse(imageUrl);
      final String filePath = path.basename(uri.path);
      
      // 从 Storage 中删除文件
      await _supabase.storage.from(bucket).remove([filePath]);
    } catch (e) {
      debugPrint('删除图片失败: $e');
      rethrow;
    }
  }

  /// 删除旅行图片
  Future<void> deleteTripImage(String imageUrl) async {
    await deleteImage(imageUrl, _tripBucket);
  }

  /// 删除日志图片
  Future<void> deleteJournalImage(String imageUrl) async {
    await deleteImage(imageUrl, _journalBucket);
  }

  /// 删除个人头像
  Future<void> deleteProfileImage(String imageUrl) async {
    await deleteImage(imageUrl, _profileBucket);
  }
}
