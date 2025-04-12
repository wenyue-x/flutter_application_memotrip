import 'dart:io';
import 'package:flutter_application_memotrip/models/trip.dart';
import 'package:flutter_application_memotrip/services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// 负责处理旅行相关数据操作的服务类
class TripService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storageService = StorageService();
  final _uuid = const Uuid();

  /// 获取当前用户的所有旅行
  Future<List<Trip>> getTrips() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final data = await _supabase
          .from('trips')
          .select()
          .eq('user_id', userId)
          .order('start_date', ascending: false);

      return data.map((trip) => Trip.fromJson(trip)).toList();
    } catch (e) {
      print('获取旅行列表失败: $e');
      rethrow;
    }
  }

  /// 根据ID获取单个旅行
  Future<Trip?> getTripById(String tripId) async {
    try {
      final data = await _supabase
          .from('trips')
          .select()
          .eq('id', tripId)
          .single();

      return Trip.fromJson(data);
    } catch (e) {
      print('获取旅行详情失败: $e');
      return null;
    }
  }

  /// 创建新旅行
  Future<Trip> createTrip({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    File? imageFile,
    double? budget,
    String? note,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('用户未登录');
      }

      // 上传图片(如果有)
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storageService.uploadTripImage(imageFile);
      }

      // 生成唯一ID
      final tripId = _uuid.v4();

      // 创建旅行数据
      final tripData = {
        'id': tripId,
        'user_id': userId,
        'destination': destination,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'image_url': imageUrl,
        'budget': budget,
        'note': note,
      };

      // 插入数据库
      await _supabase.from('trips').insert(tripData);

      // 返回创建的旅行对象
      return Trip(
        id: tripId,
        userId: userId,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        imageUrl: imageUrl,
        budget: budget,
        note: note,
      );
    } catch (e) {
      print('创建旅行失败: $e');
      rethrow;
    }
  }

  /// 更新旅行
  Future<Trip> updateTrip({
    required String tripId,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    File? newImageFile,
    String? currentImageUrl,
    bool removeImage = false,
    double? budget,
    String? note,
  }) async {
    try {
      // 先获取当前旅行数据
      final currentTrip = await getTripById(tripId);
      if (currentTrip == null) {
        throw Exception('旅行不存在');
      }

      // 处理图片更新
      String? imageUrl = currentImageUrl;
      if (removeImage) {
        // 如果要移除图片
        if (currentTrip.imageUrl != null) {
          await _storageService.deleteTripImage(currentTrip.imageUrl!);
        }
        imageUrl = null;
      } else if (newImageFile != null) {
        // 如果有新图片，先删除旧图片
        if (currentTrip.imageUrl != null) {
          await _storageService.deleteTripImage(currentTrip.imageUrl!);
        }
        // 上传新图片
        imageUrl = await _storageService.uploadTripImage(newImageFile);
      }

      // 准备更新数据
      final tripData = {
        if (destination != null) 'destination': destination,
        if (startDate != null) 'start_date': startDate.toIso8601String().split('T').first,
        if (endDate != null) 'end_date': endDate.toIso8601String().split('T').first,
        'image_url': imageUrl,
        if (budget != null) 'budget': budget,
        if (note != null) 'note': note,
      };

      // 更新数据库
      await _supabase.from('trips').update(tripData).eq('id', tripId);

      // 返回更新后的旅行对象
      return Trip(
        id: tripId,
        userId: currentTrip.userId,
        destination: destination ?? currentTrip.destination,
        startDate: startDate ?? currentTrip.startDate,
        endDate: endDate ?? currentTrip.endDate,
        imageUrl: imageUrl,
        budget: budget ?? currentTrip.budget,
        note: note ?? currentTrip.note,
      );
    } catch (e) {
      print('更新旅行失败: $e');
      rethrow;
    }
  }

  /// 删除旅行
  Future<void> deleteTrip(String tripId) async {
    try {
      // 先获取旅行数据
      final trip = await getTripById(tripId);
      if (trip == null) return;

      // 如果有图片，先删除图片
      if (trip.imageUrl != null) {
        await _storageService.deleteTripImage(trip.imageUrl!);
      }

      // 删除数据库记录 (级联删除会自动删除相关的日志和支出)
      await _supabase.from('trips').delete().eq('id', tripId);
    } catch (e) {
      print('删除旅行失败: $e');
      rethrow;
    }
  }
}
