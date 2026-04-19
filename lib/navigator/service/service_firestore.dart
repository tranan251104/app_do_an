import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_do_an/navigator/model/workout.dart';

class WorkoutService {
  final CollectionReference _workouts =
      FirebaseFirestore.instance.collection('workouts');

  Future<void> addWorkout(Workout workout) async {
    await _workouts.add(workout.toJson());
  }

  Stream<List<Workout>> getAllWorkouts() {
    return _workouts.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Workout.fromJson(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Stream<List<Workout>> getWorkoutsByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _workouts
      .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
      .where('date', isLessThan: end.toIso8601String())
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) =>
        Workout.fromJson(doc.data() as Map<String, dynamic>, doc.id))
      .toList());
  }
}
