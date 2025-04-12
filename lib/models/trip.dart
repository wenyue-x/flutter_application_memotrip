import 'package:intl/intl.dart';

class Trip {
  final String id;
  final String userId;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;
  final double? budget;
  final String? note;
  final DateTime createdAt;

  Trip({
    required this.id,
    required this.userId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
    this.budget,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 格式化的日期显示
  String get formattedDate {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return '${formatter.format(startDate)} 至 ${formatter.format(endDate)}';
  }

  /// 从 JSON 数据创建 Trip
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      userId: json['user_id'],
      destination: json['destination'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      imageUrl: json['image_url'],
      budget: json['budget'] != null ? double.parse(json['budget'].toString()) : null,
      note: json['note'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'destination': destination,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'image_url': imageUrl,
      'budget': budget,
      'note': note,
    };
  }

  /// 创建拷贝并更新某些字段
  Trip copyWith({
    String? id,
    String? userId,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? imageUrl,
    double? budget,
    String? note,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imageUrl: imageUrl ?? this.imageUrl,
      budget: budget ?? this.budget,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
