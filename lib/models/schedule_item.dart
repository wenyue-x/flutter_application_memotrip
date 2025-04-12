import 'package:intl/intl.dart';

class ScheduleItem {
  final String id;
  final String tripId;
  final DateTime date;
  final String location;
  final String? imageUrl;
  final String? description;
  final DateTime createdAt;
  final List<String> images; // 用于存储多张图片

  ScheduleItem({
    required this.id,
    required this.tripId,
    required this.date,
    required this.location,
    this.imageUrl,
    this.description,
    required this.images,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 格式化的日期显示
  String get formattedDate {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  /// 从 JSON 数据创建 ScheduleItem
  factory ScheduleItem.fromJson(Map<String, dynamic> json, {List<String>? imageUrls}) {
    return ScheduleItem(
      id: json['id'],
      tripId: json['trip_id'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      imageUrl: json['image_url'],
      description: json['description'],
      images: imageUrls ?? [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'date': date.toIso8601String().split('T').first,
      'location': location,
      'image_url': imageUrl,
      'description': description,
    };
  }

  /// 创建拷贝并更新某些字段
  ScheduleItem copyWith({
    String? id,
    String? tripId,
    DateTime? date,
    String? location,
    String? imageUrl,
    String? description,
    List<String>? images,
    DateTime? createdAt,
  }) {
    return ScheduleItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      date: date ?? this.date,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
