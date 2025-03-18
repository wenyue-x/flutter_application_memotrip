class Trip {
  final String id;
  final String destination;
  final String date;
  final String imageUrl;
  final String? budget;
  final String? note;

  Trip({
    required this.id,
    required this.destination,
    required this.date,
    required this.imageUrl,
    this.budget,
    this.note,
  });
}
