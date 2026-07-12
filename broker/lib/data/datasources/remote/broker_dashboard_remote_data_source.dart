import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';

/// Counts derived from the broker's list endpoints (no single analytics API).
class DashboardCounts {
  final int listings; // aligned assignments
  final int leads; // offers
  final int clients; // accepted leads
  final int projects; // live projects available

  const DashboardCounts({
    required this.listings,
    required this.leads,
    required this.clients,
    required this.projects,
  });
}

abstract class BrokerDashboardRemoteDataSource {
  Future<DashboardCounts> getCounts();
}

class BrokerDashboardRemoteDataSourceImpl
    implements BrokerDashboardRemoteDataSource {
  final Dio dio;

  BrokerDashboardRemoteDataSourceImpl(this.dio);

  /// Returns the length of an array endpoint, or 0 if it fails / isn't a list.
  Future<int> _count(String path) async {
    try {
      final res = await dio.get(path);
      final status = res.statusCode ?? 0;
      if (status >= 200 && status < 300 && res.data is List) {
        return (res.data as List).length;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<DashboardCounts> getCounts() async {
    final results = await Future.wait([
      _count(ApiConstants.brokersMeAssignments),
      _count(ApiConstants.brokersMeLeads),
      _count(ApiConstants.brokersMeClients),
      _count(ApiConstants.brokersMeProjects),
    ]);
    return DashboardCounts(
      listings: results[0],
      leads: results[1],
      clients: results[2],
      projects: results[3],
    );
  }
}
