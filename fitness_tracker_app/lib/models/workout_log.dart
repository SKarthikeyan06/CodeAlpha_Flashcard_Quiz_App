import 'package:uuid/uuid.dart';

class WorkoutLog {
  final String id;
  final String date;          // format: YYYY-MM-DD
  final String exerciseType;  // Running, Walking, Cycling, Gym, Yoga, Swimming, Other
  final int durationMins;
  final int calories;
  final int steps;
  final String notes;
  final bool isSynced;

  WorkoutLog({
    String? id,
    required this.date,
    required this.exerciseType,
    required this.durationMins,
    required this.calories,
    this.steps = 0,
    this.notes = '',
    this.isSynced = false,
  }) : id = id ?? const Uuid().v4();

  factory WorkoutLog.fromMap(Map<String, dynamic> map) => WorkoutLog(
        id:           map['id'],
        date:         map['date'],
        exerciseType: map['exercise_type'],
        durationMins: map['duration_mins'],
        calories:     map['calories'],
        steps:        map['steps'] ?? 0,
        notes:        map['notes'] ?? '',
        isSynced:     map['is_synced'] == 1,
      );

  Map<String, dynamic> toMap() => {
        'id':            id,
        'date':          date,
        'exercise_type': exerciseType,
        'duration_mins': durationMins,
        'calories':      calories,
        'steps':         steps,
        'notes':         notes,
        'is_synced':     isSynced ? 1 : 0,
      };

  // Used when pushing to Firestore — no is_synced field needed in cloud
  Map<String, dynamic> toFirestore() => {
        'date':          date,
        'exercise_type': exerciseType,
        'duration_mins': durationMins,
        'calories':      calories,
        'steps':         steps,
        'notes':         notes,
        'created_at':    DateTime.now().toIso8601String(),
      };
}
