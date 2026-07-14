import 'package:flutter/foundation.dart';

import '../../data/models/broker_project_model.dart';
import 'projects_provider.dart';

/// A single Copilot chat message. Bot replies may carry a list of project
/// results to render as cards under the text.
class CopilotMessage {
  final bool isUser;
  final String text;
  final List<BrokerProjectModel> projects;

  const CopilotMessage._(this.isUser, this.text, this.projects);
  factory CopilotMessage.user(String text) =>
      CopilotMessage._(true, text, const []);
  factory CopilotMessage.bot(String text,
          {List<BrokerProjectModel> projects = const []}) =>
      CopilotMessage._(false, text, projects);
}

/// Broker "Copilot" — a lightweight, on-device (no cloud, no LLM) assistant.
///
/// It answers by *retrieving* from the broker's already-loaded live data
/// (projects, alignments, leads, clients) via [ProjectsProvider] and by doing
/// rule-based intent + entity parsing on the query. It never fabricates data.
class CopilotProvider extends ChangeNotifier {
  static const String _greetingText =
      "Hi! I'm your Copilot 🤖\n\nI can look things up from your live data — try:\n"
      "• \"Show my leads\"  • \"How many clients?\"\n"
      "• \"Pending approvals\"  • \"Aligned properties\"\n"
      "• \"Apartments in Kondapur\"  • \"Portfolio summary\"";

  final List<CopilotMessage> _messages = [CopilotMessage.bot(_greetingText)];
  List<CopilotMessage> get messages => List.unmodifiable(_messages);

  bool _thinking = false;
  bool get isThinking => _thinking;

  static const List<String> quickPrompts = [
    'Portfolio summary',
    'Show my leads',
    'Pending approvals',
    'Apartments in Kondapur',
  ];

  void reset() {
    _messages
      ..clear()
      ..add(CopilotMessage.bot(_greetingText));
    notifyListeners();
  }

  Future<void> send(String raw, ProjectsProvider data) async {
    final text = raw.trim();
    if (text.isEmpty || _thinking) return;
    _messages.add(CopilotMessage.user(text));
    _thinking = true;
    notifyListeners();

    // Ground answers in fresh data.
    if (!data.loadedOnce) {
      await data.load();
    }
    // A short beat so it reads like the assistant is "thinking".
    await Future<void>.delayed(const Duration(milliseconds: 250));

    _messages.add(_respond(text.toLowerCase(), data));
    _thinking = false;
    notifyListeners();
  }

  // --- Intent router --------------------------------------------------------

  CopilotMessage _respond(String q, ProjectsProvider d) {
    if (_any(q, ['hi', 'hello', 'hey', 'help', 'what can you', 'who are you'])) {
      return CopilotMessage.bot(_greetingText);
    }

    if (_any(q, ['summary', 'overview', 'portfolio', 'snapshot', 'dashboard'])) {
      return _summary(d);
    }

    final pendingProjects =
        d.projects.where((p) => d.isPending(p.id)).toList();
    final alignedProjects = d.projects
        .where((p) => d.isAligned(p.id) || d.isPaused(p.id))
        .toList();

    // Counts ("how many …").
    if (_any(q, ['how many', 'count', 'number of', 'total'])) {
      if (q.contains('lead')) {
        return CopilotMessage.bot(
            'You have ${d.leads.length} active lead offer(s).');
      }
      if (q.contains('client')) {
        return CopilotMessage.bot('You have ${d.clients.length} client(s).');
      }
      if (q.contains('pending') || q.contains('approval')) {
        return CopilotMessage.bot(
            '${pendingProjects.length} alignment request(s) awaiting builder approval.');
      }
      if (q.contains('align')) {
        return CopilotMessage.bot(
            '${alignedProjects.length} aligned propert${_plural(alignedProjects.length, 'y', 'ies')}'
            '${pendingProjects.isNotEmpty ? ' (plus ${pendingProjects.length} pending approval)' : ''}.');
      }
      if (q.contains('available')) {
        return CopilotMessage.bot(
            '${d.availableProjects.length} available propert${_plural(d.availableProjects.length, 'y', 'ies')} to align.');
      }
      return CopilotMessage.bot(
          '${d.projects.length} live project(s) are visible to you.');
    }

    // List intents.
    final isList = _any(q, ['show', 'list', 'my', 'view', 'display', 'get']);
    if (q.contains('lead') && isList) return _leadsList(d);
    if (q.contains('client') && isList) return _clientsList(d);
    if (_any(q, ['pending', 'approval', 'awaiting'])) {
      return _projectList(
        pendingProjects,
        '${pendingProjects.length} request(s) awaiting builder approval:',
        'No pending approvals — all your alignment requests are resolved.',
      );
    }
    if (q.contains('available') && (isList || q.contains('propert'))) {
      return _projectList(
        d.availableProjects,
        '${d.availableProjects.length} available propert${_plural(d.availableProjects.length, 'y', 'ies')} you can align to:',
        "You've aligned to every available property.",
      );
    }
    if (q.contains('align') && !q.contains('available')) {
      return _projectList(
        alignedProjects,
        '${alignedProjects.length} aligned propert${_plural(alignedProjects.length, 'y', 'ies')}:',
        'No aligned properties yet — align from the Available tab.',
      );
    }

    // Property search ("flats near Kondapur", "villas in Bengaluru", …).
    if (_looksLikeSearch(q)) return _search(q, d);

    return CopilotMessage.bot(
        "I'm not sure about that one yet. I can help with your leads, clients, "
        "aligned/pending properties, and searching live projects.\n\n"
        "Try: \"show my leads\", \"how many clients\", \"pending approvals\", "
        "or \"apartments in Kondapur\".");
  }

  // --- Skills ---------------------------------------------------------------

  CopilotMessage _summary(ProjectsProvider d) {
    final pending = d.projects.where((p) => d.isPending(p.id)).length;
    final aligned =
        d.projects.where((p) => d.isAligned(p.id) || d.isPaused(p.id)).length;
    return CopilotMessage.bot(
      "Here's your snapshot:\n"
      "• Live projects visible: ${d.projects.length}\n"
      "• Aligned: $aligned${pending > 0 ? '  (+$pending pending approval)' : ''}\n"
      "• Available to align: ${d.availableProjects.length}\n"
      "• Active leads: ${d.leads.length}\n"
      "• Clients: ${d.clients.length}",
    );
  }

  CopilotMessage _leadsList(ProjectsProvider d) {
    if (d.leads.isEmpty) {
      return CopilotMessage.bot(
          'No active lead offers right now. Align to more projects to receive leads.');
    }
    final b = StringBuffer(
        'You have ${d.leads.length} lead offer${d.leads.length == 1 ? '' : 's'}:\n');
    for (final l in d.leads) {
      final unit = (l.unitTitle?.isNotEmpty == true)
          ? l.unitTitle!
          : (l.unitNumber.isNotEmpty ? 'Unit ${l.unitNumber}' : 'Unit');
      final where = l.location.isEmpty ? '' : ' · ${l.location}';
      b.write('\n• ${l.projectName.isEmpty ? 'New lead' : l.projectName} — $unit$where');
    }
    return CopilotMessage.bot(b.toString());
  }

  CopilotMessage _clientsList(ProjectsProvider d) {
    if (d.clients.isEmpty) {
      return CopilotMessage.bot(
          'No clients yet. Accept a lead to convert it into a client.');
    }
    final b = StringBuffer(
        'You have ${d.clients.length} client${d.clients.length == 1 ? '' : 's'}:\n');
    for (final c in d.clients) {
      b.write('\n• ${c.buyerFullName} — ${c.projectName} · ${c.unitLabel}');
    }
    return CopilotMessage.bot(b.toString());
  }

  CopilotMessage _projectList(
    List<BrokerProjectModel> items,
    String header,
    String emptyMessage,
  ) {
    if (items.isEmpty) return CopilotMessage.bot(emptyMessage);
    return CopilotMessage.bot(header, projects: items.take(10).toList());
  }

  CopilotMessage _search(String q, ProjectsProvider d) {
    final type = _extractType(q);
    final loc = _extractLocation(q);
    final mentionsBudgetOrBhk = q.contains('budget') ||
        q.contains('bhk') ||
        RegExp(r'\d+\s*(cr|crore|lakh|lac|\bl\b|\bk\b)').hasMatch(q);

    var results = d.projects;
    if (type != null) {
      results = results.where((p) => _typeMatches(p, type)).toList();
    }
    if (loc != null) {
      final l = loc.toLowerCase();
      results = results
          .where((p) =>
              p.location.toLowerCase().contains(l) ||
              p.name.toLowerCase().contains(l) ||
              p.city.toLowerCase().contains(l) ||
              p.state.toLowerCase().contains(l))
          .toList();
    }

    final label = type ?? 'properties';
    final inLoc = loc != null ? ' in ${_titleCase(loc)}' : '';
    final budgetNote = mentionsBudgetOrBhk
        ? "\n\nNote: the broker catalog doesn't include unit price/BHK, so I can't "
            "filter by budget or configuration yet — matched by type & location."
        : '';

    if (results.isEmpty) {
      return CopilotMessage.bot(
          "I couldn't find any $label$inLoc in your live projects.$budgetNote");
    }
    return CopilotMessage.bot(
      'Found ${results.length} $label$inLoc:$budgetNote',
      projects: results.take(10).toList(),
    );
  }

  // --- Parsing helpers ------------------------------------------------------

  bool _any(String q, List<String> needles) =>
      needles.any((n) => q.contains(n));

  bool _looksLikeSearch(String q) =>
      _extractType(q) != null ||
      RegExp(r'\b(in|near|around|at)\s+[a-z]').hasMatch(q) ||
      _any(q, ['search', 'find', 'look for', 'properties', 'projects', 'flats']);

  String? _extractType(String q) {
    if (RegExp(r'\b(flat|flats|apartment|apartments|apt)\b').hasMatch(q)) {
      return 'apartments';
    }
    if (RegExp(r'\b(villa|villas)\b').hasMatch(q)) return 'villas';
    if (RegExp(r'\b(plot|plots|land|lands|gated)\b').hasMatch(q)) return 'plots';
    if (RegExp(r'\b(office|offices)\b').hasMatch(q)) return 'offices';
    if (RegExp(r'\b(shop|shops|retail)\b').hasMatch(q)) return 'retail spaces';
    if (RegExp(r'\bcommercial\b').hasMatch(q)) return 'commercial projects';
    if (RegExp(r'\bresidential\b').hasMatch(q)) return 'residential projects';
    return null;
  }

  String? _extractLocation(String q) {
    final m = RegExp(r'\b(?:in|near|around|at)\s+([a-z][a-z\s]*)').firstMatch(q);
    var loc = m?.group(1)?.trim();
    if (loc == null || loc.isEmpty) return null;
    // Cut at connective words that follow a location.
    for (final w in ['with', 'under', 'below', 'budget', 'for', 'having', 'and', 'that']) {
      final i = loc!.indexOf(' $w');
      if (i >= 0) loc = loc.substring(0, i).trim();
    }
    return (loc == null || loc.isEmpty) ? null : loc;
  }

  bool _typeMatches(BrokerProjectModel p, String type) {
    final t =
        '${p.projectType ?? ''} ${p.projectSubtype ?? ''} ${p.typeLabel}'
            .toLowerCase();
    switch (type) {
      case 'apartments':
        return t.contains('apartment') || t.contains('flat');
      case 'villas':
        return t.contains('villa');
      case 'plots':
        return t.contains('plot') || t.contains('land') || t.contains('gated');
      case 'offices':
        return t.contains('office');
      case 'retail spaces':
        return t.contains('retail') || t.contains('shop');
      case 'commercial projects':
        return (p.projectType ?? '').toLowerCase() == 'commercial' ||
            t.contains('office') ||
            t.contains('retail');
      case 'residential projects':
        return (p.projectType ?? '').toLowerCase() == 'residential' ||
            t.contains('apartment') ||
            t.contains('villa');
      default:
        return true;
    }
  }

  String _plural(int n, String one, String many) => n == 1 ? one : many;

  String _titleCase(String s) => s
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
