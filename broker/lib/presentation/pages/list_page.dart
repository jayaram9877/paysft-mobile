import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/projects_provider.dart';
import '../providers/main_tab_controller.dart';
import '../../data/models/broker_project_model.dart';
import '../../data/models/broker_offer_model.dart';
import '../../data/models/broker_client_model.dart';
import '../widgets/common/app_svg_icon.dart';
import 'project_detail_page.dart';
import 'client_detail_page.dart';

// Aligned-state accent (matches the green "Live" badge).
const Color _alignedGreen = Color(0xFF12B76A);
const Color _alignedGreenBg = Color(0xFFE7F8F0);
const Color _pausedAmber = Color(0xFFB54708);
const Color _pausedAmberBg = Color(0xFFFFF4E5);
// Pending builder-approval accent (blue).
const Color _pendingBlue = Color(0xFF1570EF);
const Color _pendingBlueBg = Color(0xFFEFF4FF);
const Color _dangerRed = Color(0xFFD92D20);

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final TabController _tabController =
      TabController(length: 4, vsync: this);
  MainTabController? _tabCtrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProjectsProvider>();
      if (!p.loadedOnce) p.load();
      _searchController.text = p.query;
      // Sync the inner tab with requests coming from other screens (e.g. the
      // Home "Leads" quick action).
      _tabCtrl = context.read<MainTabController>();
      _applyRequestedTab();
      _tabCtrl!.addListener(_applyRequestedTab);
    });
  }

  void _applyRequestedTab() {
    final wanted = _tabCtrl?.listTab ?? 0;
    if (wanted != _tabController.index) _tabController.animateTo(wanted);
  }

  @override
  void dispose() {
    _tabCtrl?.removeListener(_applyRequestedTab);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Properties',
          style: TextStyle(
            color: Color(0xFF1D2939),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _buildSearchBar(),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: false,
                indicator: const _GradientTabIndicator(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.blueGradientStart,
                      AppColors.blueGradientEnd,
                    ],
                  ),
                  indicatorHeight: 3,
                ),
                labelColor: AppColors.bluePrimary,
                unselectedLabelColor: const Color(0xFF667085),
                labelStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'Aligned'),
                  Tab(text: 'Available'),
                  Tab(text: 'Leads'),
                  Tab(text: 'Clients'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AlignedTab(),
          _AvailableTab(),
          _LeadsTab(),
          _ClientsTab(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrayLight),
      ),
      child: Row(
        children: [
          const AppSvgIcon(
            assetPath: 'assets/images/search.svg',
            width: 20,
            height: 20,
            color: AppColors.textGrayMedium,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) {
                context.read<ProjectsProvider>().setQuery(v);
                setState(() {}); // refresh clear/filter icon
              },
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDarkSecondary,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search by name or location',
                hintStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textGrayMedium,
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                context.read<ProjectsProvider>().setQuery('');
                setState(() {});
              },
              child: const Icon(Icons.close,
                  size: 18, color: AppColors.textGrayMedium),
            )
          else
            const AppSvgIcon(
              assetPath: 'assets/images/filter.svg',
              width: 20,
              height: 20,
              color: AppColors.bluePrimary,
            ),
        ],
      ),
    );
  }
}

class _AlignedTab extends StatelessWidget {
  const _AlignedTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectsProvider>();
    return _ProjectListView(
      items: provider.alignedProjects,
      countLabel: 'Aligned',
      countColor: _alignedGreen,
      emptyIcon: Icons.handshake_outlined,
      emptyMessage:
          'No aligned properties yet.\nAlign properties from the Available tab.',
    );
  }
}

class _AvailableTab extends StatelessWidget {
  const _AvailableTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectsProvider>();
    return _ProjectListView(
      items: provider.availableProjects,
      countLabel: 'Available',
      countColor: AppColors.textDarkSecondary,
      emptyIcon: Icons.home_work_outlined,
      emptyMessage: provider.projects.isEmpty
          ? 'No properties available yet.'
          : "You've aligned to every available property.",
    );
  }
}

/// Shared renderer for the Aligned / Available tabs: handles loading, error,
/// empty and search-empty states, plus the property card list.
class _ProjectListView extends StatelessWidget {
  final List<BrokerProjectModel> items;
  final String countLabel;
  final Color countColor;
  final IconData emptyIcon;
  final String emptyMessage;

  const _ProjectListView({
    required this.items,
    required this.countLabel,
    required this.countColor,
    required this.emptyIcon,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectsProvider>();

    if (provider.isLoading && !provider.loadedOnce) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && provider.projects.isEmpty) {
      return _StateMessage(
        icon: Icons.cloud_off_outlined,
        message: provider.errorMessage!,
        actionLabel: 'Retry',
        onAction: () => context.read<ProjectsProvider>().load(),
      );
    }

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<ProjectsProvider>().load(),
        child: ListView(
          children: [
            const SizedBox(height: 110),
            _StateMessage(
              icon: provider.hasQuery ? Icons.search_off_outlined : emptyIcon,
              message: provider.hasQuery
                  ? 'No properties match "${provider.query}".'
                  : emptyMessage,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ProjectsProvider>().load(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (provider.isSearching)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textGray70,
              ),
              children: [
                TextSpan(
                  text: '${items.length} ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: countColor,
                  ),
                ),
                TextSpan(
                  text: items.length == 1
                      ? '$countLabel property'
                      : '$countLabel properties',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PropertyCard(
                item: item,
                isAligned: provider.isAligned(item.id),
                isPaused: provider.isPaused(item.id),
                isPending: provider.isPending(item.id),
                isAligning: provider.isAligning(item.id),
                isUpdating: provider.isUpdating(item.id),
                onAlign: () => _alignProject(context, item),
                onPause: () => _runUpdate(context, item,
                    context.read<ProjectsProvider>().pause,
                    '${item.name} paused'),
                onResume: () => _runUpdate(context, item,
                    context.read<ProjectsProvider>().resume,
                    '${item.name} resumed'),
                onUnalign: () => _confirmUnalign(context, item),
                onTap: () => _openDetail(context, item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _alignProject(BuildContext context, BrokerProjectModel item) async {
  final provider = context.read<ProjectsProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final error = await provider.align(item.id);
  if (!context.mounted) return;
  // Projects that require builder approval come back as `pending` — tell the
  // broker their request was sent rather than claiming it's aligned.
  final pending = provider.isPending(item.id);
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        error ??
            (pending
                ? 'Request sent to the builder — awaiting approval.'
                : '${item.name} aligned'),
      ),
      backgroundColor:
          error == null ? (pending ? _pendingBlue : _alignedGreen) : null,
    ),
  );
}

Future<void> _runUpdate(
  BuildContext context,
  BrokerProjectModel item,
  Future<String?> Function(String) action,
  String successMessage,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final error = await action(item.id);
  if (!context.mounted) return;
  messenger.showSnackBar(
    SnackBar(
      content: Text(error ?? successMessage),
      backgroundColor: error == null ? _alignedGreen : null,
    ),
  );
}

Future<void> _confirmUnalign(BuildContext context, BrokerProjectModel item) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Unalign from project?'),
      content: Text(
        "You'll stop receiving leads for ${item.name}. "
        'You can align again anytime.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: _dangerRed),
          child: const Text('Unalign'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  await _runUpdate(
    context,
    item,
    context.read<ProjectsProvider>().unalign,
    '${item.name} unaligned',
  );
}

void _openDetail(BuildContext context, BrokerProjectModel item) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ProjectDetailPage(seed: item)),
  );
}

Future<void> _acceptLead(BuildContext context, BrokerOfferModel lead) async {
  final messenger = ScaffoldMessenger.of(context);
  final error = await context.read<ProjectsProvider>().acceptLead(lead.leadId);
  if (!context.mounted) return;
  messenger.showSnackBar(
    SnackBar(
      content: Text(error ?? 'Lead accepted — moved to Clients'),
      backgroundColor: error == null ? _alignedGreen : null,
    ),
  );
}

Future<void> _rejectLead(BuildContext context, BrokerOfferModel lead) async {
  final controller = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Reject this lead?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Optionally tell us why (sent to the system).'),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Reason (optional)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: _dangerRed),
          child: const Text('Reject'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final reason = controller.text.trim();
  final messenger = ScaffoldMessenger.of(context);
  final error = await context
      .read<ProjectsProvider>()
      .rejectLead(lead.leadId, reason: reason.isEmpty ? null : reason);
  if (!context.mounted) return;
  messenger.showSnackBar(
    SnackBar(content: Text(error ?? 'Lead rejected')),
  );
}

void _openClient(BuildContext context, BrokerClientModel client) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ClientDetailPage(client: client)),
  );
}

class _PropertyCard extends StatelessWidget {
  final BrokerProjectModel item;
  final bool isAligned;
  final bool isPaused;
  final bool isPending;
  final bool isAligning;
  final bool isUpdating;
  final VoidCallback onAlign;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onUnalign;
  final VoidCallback onTap;
  const _PropertyCard({
    required this.item,
    required this.isAligned,
    required this.isPaused,
    required this.isPending,
    required this.isAligning,
    required this.isUpdating,
    required this.onAlign,
    required this.onPause,
    required this.onResume,
    required this.onUnalign,
    required this.onTap,
  });

  bool get _attached => isAligned || isPaused || isPending;

  // Status descriptor shared by the header badge and the bottom status chip.
  IconData get _statusIcon => isPending
      ? Icons.hourglass_top
      : isPaused
          ? Icons.pause_circle_outline
          : Icons.check_circle;
  String get _statusLabel =>
      isPending ? 'Pending' : (isPaused ? 'Paused' : 'Aligned');
  Color get _statusColor =>
      isPending ? _pendingBlue : (isPaused ? _pausedAmber : _alignedGreen);
  Color get _statusBg =>
      isPending ? _pendingBlueBg : (isPaused ? _pausedAmberBg : _alignedGreenBg);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _attached ? _statusColor : AppColors.borderGrayMedium,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageHeader(),
            const SizedBox(height: 12),
            _titleRow(),
            const SizedBox(height: 6),
            _typeChip(),
            const SizedBox(height: 8),
            _locationRow(),
            const SizedBox(height: 12),
            _metaRow(),
            const SizedBox(height: 12),
            _bottomRow(context),
          ],
        ),
      ),
    );
  }

  Widget _imageHeader() {
    final hasImage = item.coverImageUrl != null && item.coverImageUrl!.isNotEmpty;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: hasImage
              ? Image.network(
                  item.coverImageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imageFallback(),
                )
              : _imageFallback(),
        ),
        Positioned(
          left: 10,
          top: 10,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF12B76A),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
              if (_attached) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Icon(_statusIcon, size: 14, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.textWhite,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: AppSvgIcon(
                assetPath: 'assets/images/heart.svg',
                width: 18,
                height: 18,
                color: AppColors.bluePrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blueGradientStart, AppColors.blueGradientEnd],
        ),
      ),
      child: const Center(
        child: Icon(Icons.apartment, color: AppColors.textWhite, size: 48),
      ),
    );
  }

  Widget _titleRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            item.name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderGrayMedium),
          ),
          child: const Center(
            child: AppSvgIcon(
              assetPath: 'assets/images/badge.svg',
              width: 16,
              height: 16,
              color: AppColors.bluePrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _typeChip() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.backgroundBlueSelectedVeryLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 6,
                height: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.bluePrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.typeLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bluePrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _locationRow() {
    return Row(
      children: [
        const AppSvgIcon(
          assetPath: 'assets/images/location.svg',
          width: 16,
          height: 16,
          color: AppColors.textGrayMedium,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            item.location.isEmpty ? '—' : item.location,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textGray80,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _metaRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.borderGrayMedium),
        ),
      ),
      child: Row(
        children: [
          _metaItem('Status', item.statusLabel),
          _metaDivider(),
          _metaItem(
              'Units',
              item.totalUnitsPlanned == null
                  ? '—'
                  : '${item.totalUnitsPlanned}'),
          _metaDivider(),
          _metaItem('City', item.city.isEmpty ? '—' : item.city),
        ],
      ),
    );
  }

  Widget _metaItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textGray70,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDarkSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _metaDivider() {
    return Container(
      width: 1,
      height: 34,
      color: AppColors.borderDivider,
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }

  Widget _bottomRow(BuildContext context) {
    if (!_attached) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [_alignButton()],
      );
    }
    // Pending builder approval: show the status + a way to withdraw the request.
    if (isPending) {
      return Row(
        children: [
          _statusChip(),
          const Spacer(),
          if (isUpdating)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            _smallButton(
              label: 'Cancel',
              icon: Icons.close,
              color: _dangerRed,
              onTap: onUnalign,
            ),
        ],
      );
    }
    // Aligned / paused: status chip + manage actions on the card itself.
    return Row(
      children: [
        _statusChip(),
        const Spacer(),
        if (isUpdating)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else ...[
          isPaused
              ? _smallButton(
                  label: 'Resume',
                  icon: Icons.play_arrow,
                  color: _alignedGreen,
                  onTap: onResume,
                )
              : _smallButton(
                  label: 'Pause',
                  icon: Icons.pause,
                  color: _pausedAmber,
                  onTap: onPause,
                ),
          const SizedBox(width: 8),
          _smallButton(
            label: 'Unalign',
            icon: Icons.link_off,
            color: _dangerRed,
            onTap: onUnalign,
          ),
        ],
      ],
    );
  }

  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _statusBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(_statusIcon, size: 14, color: _statusColor),
          const SizedBox(width: 6),
          Text(
            isPending ? 'Pending approval' : _statusLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _alignButton() {
    return GestureDetector(
      onTap: isAligning ? null : onAlign,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isAligning ? AppColors.bluePrimary.withOpacity(0.6)
              : AppColors.bluePrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAligning) ...[
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Aligning…',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
            ] else ...[
              const Text(
                'Align',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios,
                  size: 10, color: AppColors.textWhite),
            ],
          ],
        ),
      ),
    );
  }
}

class _LeadsTab extends StatelessWidget {
  const _LeadsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectsProvider>();

    if (provider.isLoading && !provider.loadedOnce) {
      return const Center(child: CircularProgressIndicator());
    }

    final leads = provider.leads;
    if (leads.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<ProjectsProvider>().load(),
        child: ListView(
          children: const [
            SizedBox(height: 120),
            _StateMessage(
              icon: Icons.inbox_outlined,
              message: 'No lead offers yet.\n'
                  'Align to projects to start receiving leads.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ProjectsProvider>().load(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textGray70,
              ),
              children: [
                TextSpan(
                  text: '${leads.length} ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDarkSecondary,
                  ),
                ),
                TextSpan(
                    text: leads.length == 1
                        ? 'Lead offer'
                        : 'Lead offers'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...leads.map(
            (lead) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LeadCard(
                lead: lead,
                busy: provider.isLeadBusy(lead.leadId),
                onAccept: () => _acceptLead(context, lead),
                onReject: () => _rejectLead(context, lead),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  final BrokerOfferModel lead;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  const _LeadCard({
    required this.lead,
    required this.busy,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final unit = lead.unitTitle?.isNotEmpty == true
        ? lead.unitTitle!
        : (lead.unitNumber.isNotEmpty ? 'Unit ${lead.unitNumber}' : 'Unit');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.backgroundBlueSelectedVeryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_outline,
                    color: AppColors.bluePrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.projectName.isEmpty ? 'New lead' : lead.projectName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$unit · ${lead.location.isEmpty ? 'New lead offer' : lead.location}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGray70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB54708),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _leadMeta('Offered', _formatDate(lead.offeredAt)),
              ),
              Expanded(
                child: _leadMeta('Expires', _formatDate(lead.expiresAt)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderGrayLight),
          const SizedBox(height: 12),
          if (busy)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _dangerRed,
                      side: const BorderSide(color: _dangerRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Reject',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _alignedGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Accept',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _leadMeta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textGray70,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDarkSecondary,
          ),
        ),
      ],
    );
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final mm = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    return '${local.day} ${_months[local.month - 1]} ${local.year}, '
        '$h:$mm $ampm';
  }
}

class _ClientsTab extends StatelessWidget {
  const _ClientsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectsProvider>();
    if (provider.isLoading && !provider.loadedOnce) {
      return const Center(child: CircularProgressIndicator());
    }
    final clients = provider.clients;
    if (clients.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<ProjectsProvider>().load(),
        child: ListView(
          children: const [
            SizedBox(height: 120),
            _StateMessage(
              icon: Icons.people_outline,
              message: 'No clients yet.\n'
                  'Accept a lead to add a client and schedule visits.',
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<ProjectsProvider>().load(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textGray70,
              ),
              children: [
                TextSpan(
                  text: '${clients.length} ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDarkSecondary,
                  ),
                ),
                TextSpan(text: clients.length == 1 ? 'Client' : 'Clients'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...clients.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ClientCard(
                  client: c,
                  onTap: () => _openClient(context, c),
                ),
              )),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final BrokerClientModel client;
  final VoidCallback onTap;
  const _ClientCard({required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrayMedium),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.backgroundBlueSelectedVeryLight,
                shape: BoxShape.circle,
              ),
              child: Text(
                client.initials,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bluePrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.buyerFullName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101828),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${client.projectName} · ${client.unitLabel}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGray70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textGrayMedium),
          ],
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _StateMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textGrayMedium),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGray70, fontSize: 14),
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _GradientTabIndicator extends Decoration {
  final Gradient gradient;
  final double indicatorHeight;

  const _GradientTabIndicator({
    required this.gradient,
    required this.indicatorHeight,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _GradientPainter(gradient, indicatorHeight, onChanged);
  }
}

class _GradientPainter extends BoxPainter {
  final Gradient gradient;
  final double indicatorHeight;

  _GradientPainter(this.gradient, this.indicatorHeight, [VoidCallback? onChanged])
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = Offset(
          offset.dx,
          offset.dy + configuration.size!.height - indicatorHeight,
        ) &
        Size(configuration.size!.width, indicatorHeight);
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);
  }
}
