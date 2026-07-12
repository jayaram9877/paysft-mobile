import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/profile_provider.dart';
import '../../data/models/broker_model.dart';
import '../../data/models/user_model.dart';
import '../welcome_screen/onboarding_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ---- Static/demo values (no API source) --------------------------------
  static const double _rating = 4.8;
  static const int _reviews = 156;
  static const String _selfieScore = '98%';
  static const String _reraValidUntil = '31 Dec 2025';
  static const String _experience = '8 years';
  static const List<String> _languages = ['Hindi', 'English', 'Marathi'];
  static const List<String> _microMarkets = ['Powai', 'Bandra', 'Andheri West'];
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProfileProvider>();
      if (!p.loadedOnce) p.load();
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out',
                style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await context.read<ProfileProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingPage()),
      (route) => false,
    );
  }

  Future<void> _openEdit() async {
    final user = context.read<ProfileProvider>().user;
    if (user == null) return;
    final nameController = TextEditingController(text: user.fullName);
    final mobileController = TextEditingController(
        text: user.mobile.replaceFirst(RegExp(r'^\+91'), ''));
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: _EditSheet(
            nameController: nameController, mobileController: mobileController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FB),
        elevation: 0,
        foregroundColor: AppColors.textDark,
        automaticallyImplyLeading: false,
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
        actions: [
          if (p.user != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'edit') _openEdit();
                if (v == 'logout') _logout();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit profile')),
                PopupMenuItem(value: 'logout', child: Text('Log out')),
              ],
            ),
        ],
      ),
      body: _body(p),
    );
  }

  Widget _body(ProfileProvider p) {
    if (p.isLoading && !p.loadedOnce) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 48, color: AppColors.textGrayMedium),
            const SizedBox(height: 12),
            Text(p.errorMessage ?? 'Could not load your profile.'),
            const SizedBox(height: 12),
            TextButton(
                onPressed: () => context.read<ProfileProvider>().load(),
                child: const Text('Retry')),
          ],
        ),
      );
    }

    final user = p.user!;
    final broker = p.broker;

    return RefreshIndicator(
      onRefresh: () => context.read<ProfileProvider>().load(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _headerCard(user, broker),
          const SizedBox(height: 16),
          _verificationSection(broker),
          const SizedBox(height: 16),
          _contactSection(user),
          const SizedBox(height: 16),
          _professionalSection(broker),
        ],
      ),
    );
  }

  // ---- Header (gradient) --------------------------------------------------
  Widget _headerCard(UserModel user, BrokerModel? broker) {
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.white),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white24,
              backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl!) : null,
              child: hasAvatar
                  ? null
                  : Text(user.initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          Text(user.fullName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(broker?.legalName ?? '—',
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Color(0xFFFBBF24), size: 18),
              const SizedBox(width: 4),
              Text('$_rating',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              const SizedBox(width: 6),
              Text('($_reviews reviews)',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Digital Business Card — coming soon'))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.badge_outlined, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('Show Digital Business Card',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Verification & Compliance -----------------------------------------
  Widget _verificationSection(BrokerModel? broker) {
    final active = broker?.isActive ?? false;
    return _card(
      title: 'Verification & Compliance',
      titleIcon: Icons.verified_user_outlined,
      child: Column(
        children: [
          _verifyRow(
            title: 'Aadhaar eKYC',
            subtitle: active ? 'Verified & Active' : 'Pending review',
            badge: active ? 'Verified' : 'Pending',
            ok: active,
          ),
          const SizedBox(height: 10),
          _verifyRow(
            title: 'Live Selfie Match',
            subtitle: 'Score: $_selfieScore',
            badge: 'Matched',
            ok: true,
          ),
          const SizedBox(height: 10),
          _reraRow(broker),
        ],
      ),
    );
  }

  Widget _verifyRow({
    required String title,
    required String subtitle,
    required String badge,
    required bool ok,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ok ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: ok ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle,
              color: ok ? const Color(0xFF16A34A) : const Color(0xFFD97706),
              size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGrayMedium)),
              ],
            ),
          ),
          _pill(badge, ok),
        ],
      ),
    );
  }

  Widget _reraRow(BrokerModel? broker) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrayLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('RERA Registration',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(height: 8),
                _kv('Number', broker?.reraAgentNumber ?? '—'),
                _kv('State', broker?.reraAgentState ?? '—'),
                _kv('Valid Until', _reraValidUntil),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            SizedBox(
                width: 92,
                child: Text(k,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGrayMedium))),
            Expanded(
                child: Text(v,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark))),
          ],
        ),
      );

  // ---- Contact Information -----------------------------------------------
  Widget _contactSection(UserModel user) {
    return _card(
      title: 'Contact Information',
      child: Column(
        children: [
          _contactRow(Icons.phone_outlined, 'Mobile',
              user.mobile.isEmpty ? '—' : user.mobile),
          const SizedBox(height: 12),
          _contactRow(Icons.mail_outline, 'Email', user.email),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.bluePrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.bluePrimary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textGrayMedium)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
      ],
    );
  }

  // ---- Professional Details ----------------------------------------------
  Widget _professionalSection(BrokerModel? broker) {
    // Areas of operation from the registered address (real data).
    final areas = (broker?.registeredAddress ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return _card(
      title: 'Professional Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow(Icons.work_outline, 'Experience', _experience),
          const SizedBox(height: 16),
          _chipsBlock(Icons.translate, 'Languages', _languages,
              const Color(0xFFEFF6FF), AppColors.bluePrimary),
          const SizedBox(height: 16),
          _chipsBlock(
              Icons.place_outlined,
              'Areas of Operation',
              areas.isEmpty ? ['—'] : areas,
              const Color(0xFFF0FDF4),
              const Color(0xFF16A34A)),
          const SizedBox(height: 16),
          _chipsBlock(Icons.location_city_outlined, 'Micro Markets',
              _microMarkets, const Color(0xFFFAF5FF), const Color(0xFF9333EA)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textGrayMedium),
        const SizedBox(width: 8),
        Text('$label  ',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textGrayMedium)),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
      ],
    );
  }

  Widget _chipsBlock(IconData icon, String label, List<String> items,
      Color bg, Color fg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textGrayMedium),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textGrayMedium)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((t) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                        color: bg, borderRadius: BorderRadius.circular(999)),
                    child: Text(t,
                        style: TextStyle(
                            color: fg,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ---- Shared -------------------------------------------------------------
  Widget _card({
    required String title,
    IconData? titleIcon,
    required Widget child,
  }) {
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
            children: [
              if (titleIcon != null) ...[
                Icon(titleIcon, size: 20, color: AppColors.bluePrimary),
                const SizedBox(width: 8),
              ],
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _pill(String text, bool ok) {
    final fg = ok ? const Color(0xFF027A48) : const Color(0xFFB54708);
    final bg = ok ? const Color(0xFFECFDF3) : const Color(0xFFFFFAEB);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EditSheet extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController mobileController;
  const _EditSheet(
      {required this.nameController, required this.mobileController});

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  String? _error;

  bool get _valid =>
      widget.nameController.text.trim().isNotEmpty &&
      RegExp(r'^[6-9]\d{9}$').hasMatch(widget.mobileController.text.trim());

  Future<void> _save() async {
    setState(() => _error = null);
    if (!_valid) {
      setState(() => _error = 'Enter a valid name and 10-digit mobile (6-9).');
      return;
    }
    final err = await context.read<ProfileProvider>().updateProfile(
          fullName: widget.nameController.text.trim(),
          mobile: '+91${widget.mobileController.text.trim()}',
        );
    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')));
    } else {
      setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<ProfileProvider>().isSaving;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Edit Profile',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark)),
        const SizedBox(height: 16),
        const Text('Full Name',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: widget.nameController,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
          decoration: _dec('Your name'),
        ),
        const SizedBox(height: 14),
        const Text('Mobile',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: widget.mobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
          decoration: _dec('9876543210', prefix: '+91 ', counter: ''),
        ),
        if (_error != null) ...[
          const SizedBox(height: 4),
          Text(_error!,
              style: const TextStyle(color: AppColors.errorRed, fontSize: 13)),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bluePrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppColors.backgroundWhite))
                : const Text('Save',
                    style: TextStyle(
                        color: AppColors.backgroundWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  InputDecoration _dec(String hint, {String? prefix, String? counter}) =>
      InputDecoration(
        hintText: hint,
        prefixText: prefix,
        counterText: counter,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bluePrimary, width: 2),
        ),
      );
}
