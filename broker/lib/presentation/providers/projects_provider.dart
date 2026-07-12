import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../data/datasources/remote/broker_projects_remote_data_source.dart';
import '../../data/datasources/remote/broker_assignments_remote_data_source.dart';
import '../../data/models/broker_project_model.dart';
import '../../data/models/broker_assignment_model.dart';
import '../../data/models/broker_offer_model.dart';
import '../../data/models/broker_client_model.dart';

/// Loads the broker's live projects (Explore / Properties list), their
/// alignments, and routed lead offers. Drives the Aligned + Leads tabs.
class ProjectsProvider with ChangeNotifier {
  final BrokerProjectsRemoteDataSource remoteDataSource;
  final BrokerAssignmentsRemoteDataSource assignmentsDataSource;

  ProjectsProvider({
    required this.remoteDataSource,
    required this.assignmentsDataSource,
  });

  bool _loading = false;
  String? _errorMessage;
  List<BrokerProjectModel> _projects = [];
  List<BrokerAssignmentModel> _assignments = [];
  List<BrokerOfferModel> _leads = [];
  List<BrokerClientModel> _clients = [];
  final Set<String> _aligningIds = {}; // align calls currently in flight
  final Set<String> _leadActionIds = {}; // accept/reject in flight
  final Set<String> _updatingIds = {}; // pause/resume/unalign in flight
  bool _loadedOnce = false;
  String _query = '';
  bool _searching = false; // server search in flight
  Timer? _searchDebounce;

  bool get isLoading => _loading;
  bool get isSearching => _searching;
  String? get errorMessage => _errorMessage;
  List<BrokerProjectModel> get projects => _projects;
  List<BrokerOfferModel> get leads => _leads;
  List<BrokerClientModel> get clients => _clients;
  bool isLeadBusy(String leadId) => _leadActionIds.contains(leadId);
  bool get loadedOnce => _loadedOnce;
  String get query => _query;
  bool get hasQuery => _query.isNotEmpty;

  /// The broker's active (non-revoked) assignment for a project, if any.
  BrokerAssignmentModel? assignmentFor(String projectId) {
    for (final a in _assignments) {
      if (a.projectId == projectId && a.status != 'revoked') return a;
    }
    return null;
  }

  /// Status of the broker's assignment to a project: 'aligned', 'paused', or
  /// null when the broker is not attached.
  String? assignmentStatusFor(String projectId) =>
      assignmentFor(projectId)?.status;

  /// Project ids the broker is attached to (aligned OR paused).
  Set<String> get _attachedIds => _assignments
      .where((a) => a.status == 'aligned' || a.status == 'paused')
      .map((a) => a.projectId)
      .toSet();

  bool isAttached(String projectId) => _attachedIds.contains(projectId);
  bool isAligned(String projectId) =>
      assignmentStatusFor(projectId) == 'aligned';
  bool isPaused(String projectId) => assignmentStatusFor(projectId) == 'paused';
  bool isAligning(String projectId) => _aligningIds.contains(projectId);
  bool isUpdating(String projectId) => _updatingIds.contains(projectId);

  int get alignedCount => _attachedIds.length;

  /// Projects matching the current search query (name / locality / city /
  /// state). The broker API has no server-side search, so this filters the
  /// already-fetched list.
  /// Search is performed server-side (the API's `q` param), so the loaded list
  /// is already filtered.
  List<BrokerProjectModel> get filteredProjects => _projects;

  /// Projects the broker is attached to — aligned or paused (matching the
  /// search query). The "Aligned" tab.
  List<BrokerProjectModel> get alignedProjects {
    final attached = _attachedIds;
    return filteredProjects.where((p) => attached.contains(p.id)).toList();
  }

  /// Projects the broker is not attached to (matching the search query). The
  /// "Available" tab.
  List<BrokerProjectModel> get availableProjects {
    final attached = _attachedIds;
    return filteredProjects.where((p) => !attached.contains(p.id)).toList();
  }

  int get availableCount => availableProjects.length;

  /// Human-readable project name for an offer/assignment, resolved from the
  /// loaded projects list. Falls back to a short id when not found.
  String projectNameFor(String projectId) {
    for (final p in _projects) {
      if (p.id == projectId) return p.name;
    }
    final short = projectId.length > 8 ? projectId.substring(0, 8) : projectId;
    return 'Project $short';
  }

  /// Updates the search query and re-fetches matching projects from the server
  /// (debounced so we don't fire a request per keystroke).
  void setQuery(String value) {
    final q = value.trim();
    if (q == _query) return;
    _query = q;
    notifyListeners();
    _searchDebounce?.cancel();
    _searchDebounce =
        Timer(const Duration(milliseconds: 400), _reloadProjects);
  }

  /// Re-fetches only the project catalog for the current query (assignments and
  /// leads are unaffected by search).
  Future<void> _reloadProjects() async {
    final queryAtStart = _query;
    _searching = true;
    notifyListeners();
    try {
      final results = await remoteDataSource.listProjects(
        q: queryAtStart.isEmpty ? null : queryAtStart,
      );
      // Ignore stale responses if the query changed while in flight.
      if (queryAtStart == _query) _projects = results;
    } catch (_) {
      // Keep the previous results on a transient search failure.
    }
    _searching = false;
    notifyListeners();
  }

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        remoteDataSource.listProjects(q: _query.isEmpty ? null : _query),
        assignmentsDataSource.listAssignments(),
        assignmentsDataSource.listLeads(),
        assignmentsDataSource.listClients(),
      ]);
      _projects = results[0] as List<BrokerProjectModel>;
      _assignments = results[1] as List<BrokerAssignmentModel>;
      _leads = results[2] as List<BrokerOfferModel>;
      _clients = results[3] as List<BrokerClientModel>;
    } catch (e) {
      _errorMessage = 'Could not load properties.';
    }
    _loading = false;
    _loadedOnce = true;
    notifyListeners();
  }

  /// Aligns the broker to [projectId] via POST /brokers/me/assignments.
  /// Returns null on success, or an error message to surface to the user.
  Future<String?> align(String projectId) async {
    if (isAligned(projectId) || isAligning(projectId)) return null;
    _aligningIds.add(projectId);
    notifyListeners();
    try {
      final assignment = await assignmentsDataSource.alignProject(projectId);
      _assignments = [
        ..._assignments.where((a) => a.projectId != projectId),
        assignment,
      ];
      return null;
    } on ServerException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not align this property. Please try again.';
    } finally {
      _aligningIds.remove(projectId);
      notifyListeners();
    }
  }

  /// Pauses the broker's alignment (status -> paused). Returns null on success
  /// or an error message.
  Future<String?> pause(String projectId) =>
      _setStatus(projectId, 'paused', 'Could not pause this alignment.');

  /// Resumes a paused alignment (status -> aligned).
  Future<String?> resume(String projectId) =>
      _setStatus(projectId, 'aligned', 'Could not resume this alignment.');

  Future<String?> _setStatus(
      String projectId, String status, String fallback) async {
    final assignment = assignmentFor(projectId);
    if (assignment == null) return 'You are not aligned to this project.';
    if (isUpdating(projectId)) return null;
    _updatingIds.add(projectId);
    notifyListeners();
    try {
      final updated = await assignmentsDataSource.updateAssignmentStatus(
          assignment.id, status);
      _assignments = [
        ..._assignments.where((a) => a.id != assignment.id),
        updated,
      ];
      return null;
    } on ServerException catch (e) {
      return e.message;
    } catch (_) {
      return fallback;
    } finally {
      _updatingIds.remove(projectId);
      notifyListeners();
    }
  }

  /// Revokes (unaligns) the broker's assignment to a project. Returns null on
  /// success or an error message.
  Future<String?> unalign(String projectId) async {
    final assignment = assignmentFor(projectId);
    if (assignment == null) return 'You are not aligned to this project.';
    if (isUpdating(projectId)) return null;
    _updatingIds.add(projectId);
    notifyListeners();
    try {
      await assignmentsDataSource.revokeAssignment(assignment.id);
      _assignments =
          _assignments.where((a) => a.id != assignment.id).toList();
      return null;
    } on ServerException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not unalign this property. Please try again.';
    } finally {
      _updatingIds.remove(projectId);
      notifyListeners();
    }
  }

  /// Accepts a lead offer: it moves out of Leads and into Clients. Returns null
  /// on success or an error message.
  Future<String?> acceptLead(String leadId) async {
    if (isLeadBusy(leadId)) return null;
    _leadActionIds.add(leadId);
    notifyListeners();
    try {
      final client = await assignmentsDataSource.acceptLead(leadId);
      _leads = _leads.where((l) => l.leadId != leadId).toList();
      _clients = [
        client,
        ..._clients.where((c) => c.leadId != leadId),
      ];
      return null;
    } on ServerException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not accept this lead. Please try again.';
    } finally {
      _leadActionIds.remove(leadId);
      notifyListeners();
    }
  }

  /// Rejects a lead offer (it drops off the Leads list).
  Future<String?> rejectLead(String leadId, {String? reason}) async {
    if (isLeadBusy(leadId)) return null;
    _leadActionIds.add(leadId);
    notifyListeners();
    try {
      await assignmentsDataSource.rejectLead(leadId, reason: reason);
      _leads = _leads.where((l) => l.leadId != leadId).toList();
      return null;
    } on ServerException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not reject this lead. Please try again.';
    } finally {
      _leadActionIds.remove(leadId);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
