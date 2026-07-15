import 'package:flutter/material.dart';
import '../models/subject.dart';

class SubjectProvider extends ChangeNotifier {
  final List<Subject> _subjects = [];

  List<Subject> get subjects => List.unmodifiable(_subjects);

  List<Subject> get passingSubjects =>
      _subjects.where((s) => s.isPassing).toList();

  List<Subject> get failingSubjects =>
      _subjects.where((s) => !s.isPassing).toList();

  int get totalSubjects => _subjects.length;

  double get averageMark {
    if (_subjects.isEmpty) return 0.0;
    final total = _subjects.map((s) => s.mark).reduce((a, b) => a + b);
    return total / _subjects.length;
  }

  String get overallGrade {
    final avg = averageMark;
    if (avg >= 80) return 'A';
    if (avg >= 65) return 'B';
    if (avg >= 50) return 'C';
    return 'F';
  }

  void addSubject(Subject subject) {
    _subjects.add(subject);
    notifyListeners();
  }

  void removeSubject(int index) {
    _subjects.removeAt(index);
    notifyListeners();
  }

  bool subjectExists(String name) {
    return _subjects.any(
          (s) => s.name.toLowerCase() == name.toLowerCase(),
    );
  }
}