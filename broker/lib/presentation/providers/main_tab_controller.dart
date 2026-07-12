import 'package:flutter/foundation.dart';

/// Shared navigation state for the bottom tabs so any tab (e.g. the Home
/// quick-actions / search) can switch to another tab, and optionally pre-select
/// an inner tab on the Properties list.
class MainTabController extends ChangeNotifier {
  // Bottom-tab indices.
  static const int home = 0;
  static const int properties = 1;
  static const int favorites = 2;
  static const int schedule = 2; // the 3rd bottom tab is labelled "Schedule"
  static const int chat = 3;
  static const int profile = 4;

  // Inner Properties tabs.
  static const int listAligned = 0;
  static const int listAvailable = 1;
  static const int listLeads = 2;
  static const int listClients = 3;

  int _index = home;
  int _listTab = listAligned;
  int get index => _index;
  int get listTab => _listTab;

  /// Switch to [tabIndex]; optionally pre-select the Properties inner tab.
  void go(int tabIndex, {int? listTab}) {
    if (listTab != null) _listTab = listTab;
    if (_index != tabIndex || listTab != null) {
      _index = tabIndex;
      notifyListeners();
    }
  }

  /// Called by the bottom navigation bar on a manual tap.
  void setIndex(int tabIndex) {
    if (_index == tabIndex) return;
    _index = tabIndex;
    notifyListeners();
  }
}
