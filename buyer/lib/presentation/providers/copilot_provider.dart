import 'package:flutter/foundation.dart';

import '../../core/di/injection_container.dart' as di;
import '../../domain/entities/property_model.dart';
import '../../domain/repositories/home_repository.dart';
import 'offers_provider.dart';
import 'visits_provider.dart';
import 'saved_units_provider.dart';
import 'lead_provider.dart';

/// A single Copilot chat message. Bot replies may carry property results to
/// render as tappable cards under the text.
class CopilotMessage {
  final bool isUser;
  final String text;
  final List<PropertyModel> properties;

  const CopilotMessage._(this.isUser, this.text, this.properties);
  factory CopilotMessage.user(String text) =>
      CopilotMessage._(true, text, const []);
  factory CopilotMessage.bot(String text,
          {List<PropertyModel> properties = const []}) =>
      CopilotMessage._(false, text, properties);
}

/// Buyer "Copilot" — an on-device assistant (no cloud, no LLM). It answers by
/// retrieving from the buyer's live data (offers, visits, saved, interests) and
/// by running budget-aware catalog search against the real `/buyer/projects`
/// filters. It never fabricates data.
class CopilotProvider extends ChangeNotifier {
  static const String _greetingText =
      "Hi! I'm your Copilot 🤖\n\nI can search properties and look up your activity — try:\n"
      "• \"Flats in Kondapur under 1cr\"\n"
      "• \"Villas in Bengaluru\"\n"
      "• \"My offers\"  • \"Upcoming visits\"\n"
      "• \"Saved properties\"  • \"Summary\"";

  final List<CopilotMessage> _messages = [CopilotMessage.bot(_greetingText)];
  List<CopilotMessage> get messages => List.unmodifiable(_messages);

  bool _thinking = false;
  bool get isThinking => _thinking;

  static const List<String> quickPrompts = [
    'Flats in Kondapur under 1cr',
    'My offers',
    'Upcoming visits',
    'Summary',
  ];

  HomeRepository get _home => di.sl<HomeRepository>();
  OffersProvider get _offers => di.sl<OffersProvider>();
  VisitsProvider get _visits => di.sl<VisitsProvider>();
  SavedUnitsProvider get _saved => di.sl<SavedUnitsProvider>();
  LeadProvider get _leads => di.sl<LeadProvider>();

  void reset() {
    _messages
      ..clear()
      ..add(CopilotMessage.bot(_greetingText));
    notifyListeners();
  }

  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _thinking) return;
    _messages.add(CopilotMessage.user(text));
    _thinking = true;
    notifyListeners();

    try {
      _messages.add(await _respond(text.toLowerCase()));
    } catch (_) {
      _messages.add(CopilotMessage.bot(
          "Sorry, something went wrong. Please try again."));
    } finally {
      _thinking = false;
      notifyListeners();
    }
  }

  // --- Intent router --------------------------------------------------------

  Future<CopilotMessage> _respond(String q) async {
    if (_any(q, ['hi', 'hello', 'hey', 'help', 'what can you', 'who are you'])) {
      return CopilotMessage.bot(_greetingText);
    }
    if (_any(q, ['summary', 'overview', 'snapshot', 'my activity', 'dashboard'])) {
      return _summary();
    }

    final isList = _any(q, ['show', 'list', 'my', 'view', 'display', 'get']);

    if (_any(q, ['offer', 'purchase', 'my sale'])) return _offersList();
    if (_any(q, ['visit', 'meeting', 'site visit', 'appointment'])) {
      return _visitsList();
    }
    if (_any(q, ['saved', 'favourite', 'favorite', 'shortlist', 'wishlist'])) {
      return _savedList();
    }
    if (_any(q, ['interested', 'interest', 'enquir', 'inquir']) && isList) {
      return _interestsList();
    }

    if (_looksLikeSearch(q)) return _search(q);

    return CopilotMessage.bot(
        "I'm not sure about that one yet. I can search properties (by type, "
        "location and budget) and pull up your offers, visits, saved list and "
        "interests.\n\nTry: \"flats in Kondapur under 1cr\", \"my offers\", or "
        "\"upcoming visits\".");
  }

  // --- Skills ---------------------------------------------------------------

  Future<CopilotMessage> _summary() async {
    await Future.wait([
      _offers.ensureLoaded(),
      _visits.ensureLoaded(),
      _saved.ensureLoaded(),
      _leads.ensureLoaded(),
    ]);
    return CopilotMessage.bot(
      "Here's your snapshot:\n"
      "• Offers: ${_offers.offers.length}  (Paid ${_offers.paidTotalLabel}, Pending ${_offers.pendingTotalLabel})\n"
      "• Upcoming visits: ${_visits.upcoming.length}\n"
      "• Saved properties: ${_saved.saved.length}\n"
      "• Interested in: ${_leads.interests.length}",
    );
  }

  Future<CopilotMessage> _offersList() async {
    await _offers.ensureLoaded();
    final offers = _offers.offers;
    if (offers.isEmpty) {
      return CopilotMessage.bot('You have no offers yet.');
    }
    final b = StringBuffer(
        'You have ${offers.length} offer${offers.length == 1 ? '' : 's'}:\n');
    for (final o in offers) {
      final status = o.status.isEmpty ? '' : ' · ${_titleCase(o.status)}';
      b.write('\n• ${o.projectName} — ${o.unitLabel} · ${o.totalCost}$status');
    }
    return CopilotMessage.bot(b.toString());
  }

  Future<CopilotMessage> _visitsList() async {
    await _visits.ensureLoaded();
    final visits = _visits.visits;
    if (visits.isEmpty) {
      return CopilotMessage.bot('You have no site visits scheduled.');
    }
    final b = StringBuffer(
        'You have ${visits.length} visit${visits.length == 1 ? '' : 's'}:\n');
    for (final v in visits) {
      b.write('\n• ${v.propertyLabel} — ${_dateLabel(v.scheduledFor)} · ${_titleCase(v.status)}');
    }
    return CopilotMessage.bot(b.toString());
  }

  Future<CopilotMessage> _savedList() async {
    await _saved.ensureLoaded();
    final saved = _saved.saved;
    if (saved.isEmpty) {
      return CopilotMessage.bot('You haven’t saved any properties yet.');
    }
    final b = StringBuffer(
        'You’ve saved ${saved.length} propert${saved.length == 1 ? 'y' : 'ies'}:\n');
    for (final u in saved) {
      final price = u.priceLabel.isEmpty ? '' : ' · ${u.priceLabel}';
      b.write('\n• ${u.title} — ${u.location}$price');
    }
    return CopilotMessage.bot(b.toString());
  }

  Future<CopilotMessage> _interestsList() async {
    await _leads.ensureLoaded();
    final interests = _leads.interests;
    if (interests.isEmpty) {
      return CopilotMessage.bot("You haven't expressed interest in any units yet.");
    }
    final b = StringBuffer(
        "You're interested in ${interests.length} unit${interests.length == 1 ? '' : 's'}:\n");
    for (final u in interests) {
      final price = u.priceLabel.isEmpty ? '' : ' · ${u.priceLabel}';
      b.write('\n• ${u.title} — ${u.location}$price');
    }
    return CopilotMessage.bot(b.toString());
  }

  Future<CopilotMessage> _search(String q) async {
    final type = _extractType(q);
    final loc = _extractLocation(q);
    final budget = _parseBudget(q);
    final mentionsBhk = RegExp(r'\d+\s*bhk').hasMatch(q) || q.contains('bedroom');

    final results = await _home.searchProjects(
      query: loc,
      projectType: type?.type,
      projectSubtype: type?.subtype,
      priceMax: budget,
      limit: 15,
    );

    final label = type?.label ?? 'properties';
    final inLoc = loc != null ? ' in ${_titleCase(loc)}' : '';
    final underBudget = budget != null ? ' under ${_budgetLabel(budget)}' : '';
    final bhkNote = mentionsBhk
        ? "\n\n(BHK is a unit-level detail, so I matched by type/location/budget — "
            "open a project to see its 3BHK units.)"
        : '';

    if (results.isEmpty) {
      return CopilotMessage.bot(
          "I couldn't find any $label$inLoc$underBudget.$bhkNote");
    }
    return CopilotMessage.bot(
      'Found ${results.length} $label$inLoc$underBudget:$bhkNote',
      properties: results,
    );
  }

  // --- Parsing helpers ------------------------------------------------------

  bool _any(String q, List<String> needles) =>
      needles.any((n) => q.contains(n));

  bool _looksLikeSearch(String q) =>
      _extractType(q) != null ||
      RegExp(r'\b(in|near|around|at)\s+[a-z]').hasMatch(q) ||
      _any(q, ['search', 'find', 'look for', 'properties', 'projects', 'flats', 'show me']);

  ({String? type, String? subtype, String label})? _extractType(String q) {
    if (RegExp(r'\b(flat|flats|apartment|apartments|apt)\b').hasMatch(q)) {
      return (type: null, subtype: 'apartment', label: 'apartments');
    }
    if (RegExp(r'\b(villa|villas)\b').hasMatch(q)) {
      return (type: null, subtype: 'villa', label: 'villas');
    }
    if (RegExp(r'\b(plot|plots|land|lands)\b').hasMatch(q)) {
      return (type: 'land', subtype: null, label: 'plots');
    }
    if (RegExp(r'\b(office|offices)\b').hasMatch(q)) {
      return (type: null, subtype: 'office', label: 'offices');
    }
    if (RegExp(r'\b(shop|shops|retail)\b').hasMatch(q)) {
      return (type: null, subtype: 'retail_shop', label: 'retail spaces');
    }
    if (RegExp(r'\bcommercial\b').hasMatch(q)) {
      return (type: 'commercial', subtype: null, label: 'commercial projects');
    }
    if (RegExp(r'\bresidential\b').hasMatch(q)) {
      return (type: 'residential', subtype: null, label: 'residential projects');
    }
    return null;
  }

  String? _extractLocation(String q) {
    final m = RegExp(r'\b(?:in|near|around|at)\s+([a-z][a-z\s]*)').firstMatch(q);
    var loc = m?.group(1)?.trim();
    if (loc == null || loc.isEmpty) return null;
    for (final w in ['with', 'under', 'below', 'budget', 'for', 'having', 'and', 'that', 'less']) {
      final i = loc!.indexOf(' $w');
      if (i >= 0) loc = loc.substring(0, i).trim();
    }
    return (loc == null || loc.isEmpty) ? null : loc;
  }

  /// Parses an Indian budget string ("1cr", "1.5 crore", "50 lakh", "₹80,00,000").
  double? _parseBudget(String q) {
    final m = RegExp(
            r'(\d+(?:\.\d+)?)\s*(crores|crore|cr|lakhs|lakh|lac|l|k)\b')
        .firstMatch(q);
    if (m != null) {
      final n = double.parse(m.group(1)!);
      switch (m.group(2)!) {
        case 'crores':
        case 'crore':
        case 'cr':
          return n * 10000000;
        case 'lakhs':
        case 'lakh':
        case 'lac':
        case 'l':
          return n * 100000;
        case 'k':
          return n * 1000;
      }
    }
    final raw = RegExp(r'₹\s*([\d,]{5,})').firstMatch(q);
    if (raw != null) {
      return double.tryParse(raw.group(1)!.replaceAll(',', ''));
    }
    return null;
  }

  String _budgetLabel(double v) {
    if (v >= 10000000) {
      final cr = v / 10000000;
      return '₹${_trim(cr)}Cr';
    }
    if (v >= 100000) {
      final l = v / 100000;
      return '₹${_trim(l)}L';
    }
    return '₹${v.round()}';
  }

  String _trim(double d) {
    final s = d.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  String _dateLabel(DateTime? dt) {
    if (dt == null) return 'Date TBD';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final l = dt.toLocal();
    final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
    final mm = l.minute.toString().padLeft(2, '0');
    final ap = l.hour < 12 ? 'AM' : 'PM';
    return '${l.day} ${months[l.month - 1]}, $h:$mm $ap';
  }

  String _titleCase(String s) => s
      .split(RegExp(r'[_\s]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
