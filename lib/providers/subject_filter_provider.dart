import 'package:flutter/foundation.dart';
import '../models/subject.dart';

enum SubjectFilter { all, pass, fail }

/// Owns the Subject List screen's filter chip + search query so the screen
/// no longer needs to call setState when the user types or taps a chip.
class SubjectFilterProvider extends ChangeNotifier {
  SubjectFilter _filter = SubjectFilter.all;
  String _query = '';

  SubjectFilter get filter => _filter;
  String get query => _query;

  void setFilter(SubjectFilter next) {
    if (_filter == next) return;
    _filter = next;
    notifyListeners();
  }

  void setQuery(String next) {
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  void clearQuery() {
    if (_query.isEmpty) return;
    _query = '';
    notifyListeners();
  }

  /// Apply the active filter + search query to a source list.
  List<Subject> apply(List<Subject> source) {
    Iterable<Subject> list = source;
    switch (_filter) {
      case SubjectFilter.pass:
        list = list.where((s) => s.isPassing);
        break;
      case SubjectFilter.fail:
        list = list.where((s) => !s.isPassing);
        break;
      case SubjectFilter.all:
        break;
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((s) => s.name.toLowerCase().contains(q));
    }
    return list.toList();
  }
}
