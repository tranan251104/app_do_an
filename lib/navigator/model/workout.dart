class Workout{
  final String id;
  final String name;
  final String detail;
  final DateTime date;
  final bool isCompleted;
  final int calories;

  Workout({
    required this.id,
    required this.name,
    required this.detail,
    required this.date,
    required this.isCompleted,
    required this.calories
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'detail': detail,
    'date': date.toIso8601String(),
    'isCompleted': isCompleted,
    'calories': calories,
  };

  factory Workout.fromJson(Map<String, dynamic> json, String id) => Workout(
    id: id,
    name: json['name'] ?? "",
    detail: json['detail'] ?? "",
    date: DateTime.parse(json['date']),
    isCompleted: json['isCompleted'] ?? false,
    calories: json['calories'] ?? 0,
  );
}

