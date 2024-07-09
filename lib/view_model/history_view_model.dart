import 'package:flutter/material.dart';
import '../model/history_model.dart';
import '../model/history_service.dart';

class HistoryViewModel extends ChangeNotifier {
  List<History> _histories = [];
  bool _isLoading = false;

  List<History> get histories => _histories;
  bool get isLoading => _isLoading;

  Future<void> fetchHistory(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _histories = await HistoryService().fetchHistory(userId);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
