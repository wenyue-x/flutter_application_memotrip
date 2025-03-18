class JournalEntry {
  final String id;
  final String time;
  final String content;
  final List<String> images;
  final String date;
  final String? location;

  JournalEntry({
    required this.id,
    required this.time,
    required this.content,
    required this.images,
    required this.date,
    this.location,
  });
}
