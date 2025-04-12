import 'dart:io';
import 'package:flutter_application_memotrip/models/journal_entry.dart';
import 'package:flutter_application_memotrip/services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// 负责处理日志相关数据操作的服务类
class JournalService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storageService = StorageService();
  final _uuid = const Uuid();

  /// 获取指定旅行的所有日志
  Future<List<JournalEntry>> getJournalEntriesByTripId(String tripId) async {
    try {
      // 获取日志条目
      final journals = await _supabase
          .from('journal_entries')
          .select()
          .eq('trip_id', tripId)
          .order('date', ascending: false);

      // 获取每个日志对应的图片
      final result = await Future.wait(
        journals.map((journal) async {
          final journalId = journal['id'];
          
          // 获取图片列表
          final images = await _supabase
              .from('journal_images')
              .select('image_url')
              .eq('journal_id', journalId);
          
          // 获取所有图片URL
          final imageUrls = images.map<String>((img) => img['image_url'] as String).toList();
          
          // 创建日志对象
          return JournalEntry.fromJson(journal, imageUrls: imageUrls);
        }),
      );
      
      return result;
    } catch (e) {
      print('获取日志列表失败: $e');
      rethrow;
    }
  }

  /// 根据ID获取单个日志
  Future<JournalEntry?> getJournalEntryById(String journalId) async {
    try {
      // 获取日志详情
      final journal = await _supabase
          .from('journal_entries')
          .select()
          .eq('id', journalId)
          .single();
      
      // 获取图片
      final images = await _supabase
          .from('journal_images')
          .select('image_url')
          .eq('journal_id', journalId);
      
      final imageUrls = images.map<String>((img) => img['image_url'] as String).toList();
      
      return JournalEntry.fromJson(journal, imageUrls: imageUrls);
    } catch (e) {
      print('获取日志详情失败: $e');
      return null;
    }
  }

  /// 创建新日志
  Future<JournalEntry> createJournalEntry({
    required String tripId,
    required DateTime date,
    required String content,
    required List<File> imageFiles,
    String? location,
    String? time,
  }) async {
    try {
      // 如果没有提供时间，使用当前时间
      final String formattedTime = time ?? DateFormat('HH:mm').format(DateTime.now());

      // 生成日志ID
      final journalId = _uuid.v4();
      
      // 创建日志记录
      final journalData = {
        'id': journalId,
        'trip_id': tripId,
        'date': date.toIso8601String().split('T').first,
        'time': formattedTime,
        'content': content,
        'location': location,
      };
      
      // 插入日志
      await _supabase.from('journal_entries').insert(journalData);
      
      // 上传图片并保存图片URL
      final List<String> imageUrls = [];
      for (final imageFile in imageFiles) {
        final imageUrl = await _storageService.uploadJournalImage(imageFile);
        
        // 插入图片记录
        await _supabase.from('journal_images').insert({
          'id': _uuid.v4(),
          'journal_id': journalId,
          'image_url': imageUrl,
        });
        
        imageUrls.add(imageUrl);
      }
      
      // 返回创建的日志
      return JournalEntry(
        id: journalId,
        tripId: tripId,
        date: date,
        time: formattedTime,
        content: content,
        images: imageUrls,
        location: location,
      );
    } catch (e) {
      print('创建日志失败: $e');
      rethrow;
    }
  }

  /// 更新日志
  Future<JournalEntry> updateJournalEntry({
    required String journalId,
    String? content,
    DateTime? date,
    String? time,
    String? location,
    List<File>? newImageFiles,
    List<String>? imagesToKeep,
  }) async {
    try {
      // 获取当前日志
      final currentJournal = await getJournalEntryById(journalId);
      if (currentJournal == null) {
        throw Exception('日志不存在');
      }
      
      // 准备更新日志数据
      final journalData = {
        if (content != null) 'content': content,
        if (date != null) 'date': date.toIso8601String().split('T').first,
        if (time != null) 'time': time,
        if (location != null) 'location': location,
      };
      
      // 如果有数据要更新，则更新日志
      if (journalData.isNotEmpty) {
        await _supabase.from('journal_entries').update(journalData).eq('id', journalId);
      }
      
      final List<String> finalImageUrls = [];
      
      // 处理要保留的图片
      if (imagesToKeep != null) {
        finalImageUrls.addAll(imagesToKeep);
        
        // 获取所有现有图片
        final existingImages = await _supabase
            .from('journal_images')
            .select('id, image_url')
            .eq('journal_id', journalId);
        
        // 删除不在保留列表中的图片
        for (final img in existingImages) {
          final String imgUrl = img['image_url'];
          if (!imagesToKeep.contains(imgUrl)) {
            // 从数据库删除
            await _supabase.from('journal_images').delete().eq('id', img['id']);
            
            // 从存储中删除
            await _storageService.deleteJournalImage(imgUrl);
          }
        }
      }
      
      // 处理新添加的图片
      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        for (final imageFile in newImageFiles) {
          // 上传图片
          final imageUrl = await _storageService.uploadJournalImage(imageFile);
          
          // 添加图片记录
          await _supabase.from('journal_images').insert({
            'id': _uuid.v4(),
            'journal_id': journalId,
            'image_url': imageUrl,
          });
          
          finalImageUrls.add(imageUrl);
        }
      }
      
      // 如果没有指定要保留的图片列表，则使用当前图片加上新图片
      if (imagesToKeep == null) {
        // 获取当前所有图片URL
        final currentImages = await _supabase
            .from('journal_images')
            .select('image_url')
            .eq('journal_id', journalId);
            
        final currentImageUrls = currentImages.map<String>((img) => img['image_url'] as String).toList();
        finalImageUrls.addAll(currentImageUrls);
      }
      
      // 返回更新后的日志
      return JournalEntry(
        id: journalId,
        tripId: currentJournal.tripId,
        date: date ?? currentJournal.date,
        time: time ?? currentJournal.time,
        content: content ?? currentJournal.content,
        images: finalImageUrls,
        location: location ?? currentJournal.location,
      );
    } catch (e) {
      print('更新日志失败: $e');
      rethrow;
    }
  }

  /// 删除日志
  Future<void> deleteJournalEntry(String journalId) async {
    try {
      // 获取日志对应的所有图片
      final images = await _supabase
          .from('journal_images')
          .select('image_url')
          .eq('journal_id', journalId);
      
      // 删除每张图片
      for (final img in images) {
        final String imageUrl = img['image_url'];
        await _storageService.deleteJournalImage(imageUrl);
      }
      
      // 删除日志记录（会通过外键级联删除图片记录）
      await _supabase.from('journal_entries').delete().eq('id', journalId);
    } catch (e) {
      print('删除日志失败: $e');
      rethrow;
    }
  }

  /// 添加图片到日志
  Future<List<String>> addImagesToJournal({
    required String journalId,
    required List<File> imageFiles,
  }) async {
    try {
      final List<String> newImageUrls = [];
      
      for (final imageFile in imageFiles) {
        // 上传图片
        final imageUrl = await _storageService.uploadJournalImage(imageFile);
        
        // 添加图片记录
        await _supabase.from('journal_images').insert({
          'id': _uuid.v4(),
          'journal_id': journalId,
          'image_url': imageUrl,
        });
        
        newImageUrls.add(imageUrl);
      }
      
      return newImageUrls;
    } catch (e) {
      print('添加图片失败: $e');
      rethrow;
    }
  }

  /// 从日志中删除图片
  Future<void> removeImageFromJournal({
    required String journalId,
    required String imageUrl,
  }) async {
    try {
      // 从数据库中删除图片记录
      await _supabase
          .from('journal_images')
          .delete()
          .eq('journal_id', journalId)
          .eq('image_url', imageUrl);
      
      // 从存储中删除图片
      await _storageService.deleteJournalImage(imageUrl);
    } catch (e) {
      print('删除图片失败: $e');
      rethrow;
    }
  }
}
