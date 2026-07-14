import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../providers/home_dashboard_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/main_tab_controller.dart';
import 'my_documents_page.dart';
import 'copilot_page.dart';
import '../../data/models/broker_model.dart';
import '../../data/models/user_model.dart';
import '../widgets/home/search_bar_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ThemeManager _theme = ThemeManager();

  // ---- Static/demo values (no API source) --------------------------------
  static const double _rating = 4.8;
  static const int _complianceScore = 92;
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeDashboardProvider>().load();
      final pp = context.read<ProfileProvider>();
      if (!pp.loadedOnce) pp.load();
    });
  }

  void _comingSoon([String label = 'This']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — coming soon')),
    );
  }

  void _goTab(int index, {int? listTab}) =>
      context.read<MainTabController>().go(index, listTab: listTab);

  /// Routes a quick-action tile to its screen.
  void _onQuickAction(String label) {
    switch (label) {
      case 'Documents':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MyDocumentsPage()),
        );
        break;
      case 'Profile':
        _goTab(MainTabController.profile);
        break;
      case 'Leads':
        _goTab(MainTabController.properties,
            listTab: MainTabController.listLeads);
        break;
      case 'Schedules':
        _goTab(MainTabController.schedule);
        break;
      default:
        _comingSoon(label);
    }
  }

  String _location(BrokerModel? broker) {
    final addr = broker?.registeredAddress;
    if (addr != null && addr.isNotEmpty) {
      final parts =
          addr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (parts.length >= 2) return '${parts[parts.length - 2]}, ${parts.last}';
      if (parts.isNotEmpty) return parts.last;
    }
    return AppStrings.selectLocation;
  }

  int _completion(UserModel? user, BrokerModel? broker) {
    if (user == null) return 0;
    final checks = <bool>[
      user.fullName.isNotEmpty,
      user.mobile.isNotEmpty,
      user.email.isNotEmpty,
      (user.avatarUrl ?? '').isNotEmpty,
      (broker?.legalName ?? '').isNotEmpty,
      (broker?.pan ?? '').isNotEmpty,
      (broker?.reraAgentNumber ?? '').isNotEmpty,
      (broker?.registeredAddress ?? '').isNotEmpty,
    ];
    final filled = checks.where((c) => c).length;
    return ((filled / checks.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<HomeDashboardProvider>();
    final profile = context.watch<ProfileProvider>();
    final broker = profile.broker;
    final user = profile.user;
    final c = dash.counts;
    String v(int? n) => dash.isLoading || c == null ? '--' : '$n';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CopilotPage()),
        ),
        backgroundColor: AppColors.bluePrimary,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text('Copilot',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _header(broker),
            const SizedBox(height: 12),
            SizedBox(
              height: _theme.searchBarHeight,
              child: SearchBarWidget(
                hintText: AppStrings.homeSearchHint,
                onTap: () => _goTab(MainTabController.properties,
                    listTab: MainTabController.listAvailable),
                onFilterTap: () => _goTab(MainTabController.properties,
                    listTab: MainTabController.listAvailable),
              ),
            ),
            const SizedBox(height: 16),
            _profileCompletionCard(_completion(user, broker)),
            const SizedBox(height: 16),
            _statGrid(v(c?.leads), v(c?.projects), v(c?.clients)),
            const SizedBox(height: 16),
            _verificationStatusCard(broker),
            const SizedBox(height: 16),
            _quickActions(),
            const SizedBox(height: 16),
            _ratingCard(),
          ],
        ),
      ),
    );
  }

  Widget _header(BrokerModel? broker) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _comingSoon('Location selection'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Location',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textGrayLight)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down,
                        size: 18, color: AppColors.bluePrimary),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on,
                        size: 18, color: AppColors.bluePrimary),
                    const SizedBox(width: 4),
                    Text(_location(broker),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                  ],
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _comingSoon('Notifications'),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.backgroundWhite,
              border: Border.all(color: AppColors.borderGrayLight),
            ),
            child: const Icon(Icons.notifications_none,
                color: AppColors.textDark, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _profileCompletionCard(int pct) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profile Completion',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              Text('$pct%',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bluePrimary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.bluePrimary),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _goTab(MainTabController.profile),
            child: const Text('Complete your profile  →',
                style: TextStyle(
                    color: AppColors.bluePrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _statGrid(String leads, String projects, String clients) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _statCard('Active Leads', leads, const Color(0xFF2563EB),
                    Icons.people_alt_outlined, locked: true)),
            const SizedBox(width: 12),
            Expanded(
                child: _statCard('Total Earnings', '₹0',
                    const Color(0xFF059669), Icons.account_balance_wallet_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _statCard('Live Projects', projects,
                    const Color(0xFF7C3AED), Icons.apartment_outlined,
                    locked: true)),
            const SizedBox(width: 12),
            Expanded(
                child: _statCard('Clients', clients, const Color(0xFFEA580C),
                    Icons.handshake_outlined)),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon,
      {bool locked = false}) {
    return Container(
      height: 116,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              if (locked)
                const Icon(Icons.lock_outline, color: Colors.white70, size: 16),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _verificationStatusCard(BrokerModel? broker) {
    final active = broker?.isActive ?? false;
    final hasRera = (broker?.reraAgentNumber ?? '').isNotEmpty;
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Verification Status',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 12),
          _verifyRow('Aadhaar eKYC', active, active ? 'Verified' : 'Pending'),
          const Divider(height: 20, color: AppColors.borderGrayLight),
          _verifyRow('RERA Registration', active && hasRera,
              (active && hasRera) ? 'Active' : 'Pending'),
          const Divider(height: 20, color: AppColors.borderGrayLight),
          _verifyRow('Bank Account', broker?.hasBankDetails ?? false,
              (broker?.hasBankDetails ?? false) ? 'Added' : 'Pending'),
        ],
      ),
    );
  }

  Widget _verifyRow(String title, bool ok, String badge) {
    final fg = ok ? const Color(0xFF16A34A) : const Color(0xFFD97706);
    final bg = ok ? const Color(0xFFECFDF3) : const Color(0xFFFFFAEB);
    return Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.schedule, color: fg, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
          child: Text(badge,
              style: TextStyle(
                  color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _quickActions() {
    final actions = <_QA>[
      _QA('Documents', Icons.description_outlined),
      _QA('Profile', Icons.person_outline),
      _QA('Leads', Icons.people_alt_outlined),
      _QA('Schedules', Icons.calendar_today_outlined),
    ];
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: actions
                .map((a) => GestureDetector(
                      onTap: () => _onQuickAction(a.label),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppColors.borderGrayLight),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(a.icon, color: AppColors.bluePrimary, size: 24),
                            const SizedBox(height: 8),
                            Text(a.label,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textDark)),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _ratingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_outlined,
                  color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Broker Rating',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    Text('Based on customer feedback',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('$_rating',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  Text('★★★★★',
                      style: TextStyle(color: Color(0xFFFBBF24), fontSize: 12)),
                ],
              ),
            ],
          ),
          const Divider(height: 26, color: Colors.white24),
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Compliance Score',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    Text('AI Generated: $_complianceScore/100',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _whiteCard({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrayLight),
        ),
        child: child,
      );
}

class _QA {
  final String label;
  final IconData icon;
  _QA(this.label, this.icon);
}
