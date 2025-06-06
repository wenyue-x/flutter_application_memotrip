import 'package:intl/intl.dart';

class JournalEntry {
  final String id;
  final String tripId;
  final DateTime date;
  final String time;
  final String content;
  final List<String> images;
  final String? location;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.tripId,
    required this.date,
    required this.time,
    required this.content,
    required this.images,
    this.location,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 格式化的日期显示
  String get formattedDate {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  /// 从 JSON 数据创建 JournalEntry
  factory JournalEntry.fromJson(Map<String, dynamic> json, {List<String>? imageUrls}) {
    return JournalEntry(
      id: json['id'],
      tripId: json['trip_id'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      content: json['content'],
      images: imageUrls ?? [],
      location: json['location'],
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
      'time': time,
      'content': content,
      'location': location,
    };
  }

  /// 创建拷贝并更新某些字段
  JournalEntry copyWith({
    String? id,
    String? tripId,
    DateTime? date,
    String? time,
    String? content,
    List<String>? images,
    String? location,
    DateTime? createdAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      date: date ?? this.date,
      time: time ?? this.time,
      content: content ?? this.content,
      images: images ?? this.images,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
