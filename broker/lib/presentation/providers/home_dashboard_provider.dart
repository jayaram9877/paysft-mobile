import 'package:flutter/foundation.dart';
import '../../data/datasources/remote/broker_dashboard_remote_data_source.dart';

/// Loads the broker dashboard counts from the API.
class HomeDashboardProvider with ChangeNotifier {
  final BrokerDashboardRemoteDataSource remoteDataSource;

  HomeDashboardProvider({required this.remoteDataSource});

  bool _loading = false;
  String? _errorMessage;
  DashboardCounts? _counts;

  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  DashboardCounts? get counts => _counts;

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _counts = await remoteDataSource.getCounts();
    } catch (e) {
      _errorMessage = 'Could not load dashboard data.';
    }
    _loading = false;
    notifyListeners();
  }
}
