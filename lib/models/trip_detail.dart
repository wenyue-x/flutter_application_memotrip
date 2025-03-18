class TripDetail {
  final String startDate;
  final String endDate;
  final int totalDays;
  final double totalExpense;
  final List<ScheduleItem> scheduleItems;

  TripDetail({
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.totalExpense,
    required this.scheduleItems,
  });
}

class ScheduleItem {
  final String date;
  final String day;
  final String location;
  final String imageUrl;
  final String description;

  ScheduleItem({
    required this.date,
    required this.day,
    required this.location,
    required this.imageUrl,
    required this.description,
  });
}
