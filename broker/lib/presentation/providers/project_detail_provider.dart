import 'package:flutter/foundation.dart';
import '../../data/datasources/remote/broker_projects_remote_data_source.dart';
import '../../data/models/broker_project_model.dart';
import '../../data/models/broker_unit_model.dart';
import '../../data/models/broker_project_media_model.dart';

/// Loads a single project's full detail, its units, and its media for the
/// project-detail view.
class ProjectDetailProvider with ChangeNotifier {
  final BrokerProjectsRemoteDataSource remoteDataSource;

  ProjectDetailProvider({required this.remoteDataSource});

  bool _loading = false;
  String? _errorMessage;
  BrokerProjectModel? _project;
  List<BrokerUnitModel> _units = [];
  List<BrokerProjectMediaModel> _media = [];

  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  BrokerProjectModel? get project => _project;
  List<BrokerUnitModel> get units => _units;
  List<BrokerProjectMediaModel> get media => _media;

  List<BrokerProjectMediaModel> get imageMedia =>
      _media.where((m) => m.isImage).toList();

  int get availableUnitsCount => _units.where((u) => u.isAvailable).length;

  /// [seed] is the project already loaded in the list, used for an instant
  /// header render while the full detail + units + media are fetched.
  Future<void> load(String projectId, {BrokerProjectModel? seed}) async {
    _project ??= seed;
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        remoteDataSource.getProject(projectId),
        remoteDataSource.getUnits(projectId),
        remoteDataSource.getMedia(projectId),
      ]);
      _project = results[0] as BrokerProjectModel;
      _units = results[1] as List<BrokerUnitModel>;
      _media = results[2] as List<BrokerProjectMediaModel>;
    } catch (e) {
      // Keep the seed header if we have it; only show error when nothing to show.
      if (_project == null) _errorMessage = 'Could not load project details.';
    }
    _loading = false;
    notifyListeners();
  }
}
