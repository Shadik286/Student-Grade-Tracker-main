import 'package:flutter/foundation.dart';

/// Holds per-form UI state for the Add Subject screen so that screen can
/// rebuild through Provider instead of calling setState directly.
///
/// - [autoValidate] is flipped on the first time the user submits an invalid
///   form, then turned back off after each successful add so the cleared
///   fields don't immediately repaint with "cannot be empty" errors.
/// - [reloadKey] is bumped after each successful add; the Add Subject screen
///   wraps its Form subtree in a `KeyedSubtree(key: ValueKey(reloadKey))`
///   so a key bump forces Flutter to rebuild the fields from scratch —
///   the only 100% reliable way to wipe TextFormField value + error state.
class SubjectFormProvider extends ChangeNotifier {
  bool _autoValidate = false;
  int _reloadKey = 0;

  bool get autoValidate => _autoValidate;
  int get reloadKey => _reloadKey;
  Object get reloadKeyValue => _reloadKey;

  void markInteraction() {
    if (_autoValidate) return;
    _autoValidate = true;
    notifyListeners();
  }

  void resetAfterAdd() {
    _autoValidate = false;
    _reloadKey++;
    notifyListeners();
  }
}
