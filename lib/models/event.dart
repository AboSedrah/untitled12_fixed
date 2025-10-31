class Event {
  final String name;
  final String description;
  final DateTime date;

  Event({
    required this.name,
    this.description = '',
    required this.date,
  });
}