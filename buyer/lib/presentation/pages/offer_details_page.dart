import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/date_time_format.dart';
import '../../domain/entities/buyer_offer.dart';
import '../providers/offers_provider.dart';
import '../widgets/common/app_loader_widget.dart';
import '../widgets/home/buyer_offer_card.dart';

void openOfferDetails(BuildContext context, BuyerOfferSummary offer) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => OfferDetailsPage(summary: offer)),
  );
}

class OfferDetailsPage extends StatefulWidget {
  final BuyerOfferSummary summary;

  const OfferDetailsPage({super.key, required this.summary});

  @override
  State<OfferDetailsPage> createState() => _OfferDetailsPageState();
}

class _OfferDetailsPageState extends State<OfferDetailsPage> {
  BuyerOfferDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail =
          await context.read<OffersProvider>().loadDetail(widget.summary.saleId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } on ServerException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } on NetworkException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load this offer';
        _loading = false;
      });
    }
  }

  BuyerOfferDetail get _current {
    if (_detail != null) return _detail!;
    final s = widget.summary;
    return BuyerOfferDetail(
      saleId: s.saleId,
      status: s.status,
      projectId: '',
      projectName: s.projectName,
      projectLocation: null,
      projectRera: null,
      projectType: '',
      projectSubtype: '',
      unitNumber: s.unitLabel,
      unitTitle: s.unitLabel,
      builderName: '',
      totalCost: s.totalCost,
      costBreakdown: const {},
      milestones: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final busy = context.watch<OffersProvider>().isBusy(widget.summary.saleId);
    final detail = _current;
    final canAct = detail.canRespond;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrayLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(AppStrings.offerDetails, style: themeManager.titleMediumStyle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_loading && _error == null)
            IconButton(
              tooltip: AppStrings.offerPreview,
              icon: const Icon(Icons.visibility_outlined, color: AppColors.textBlack),
              onPressed: busy ? null : () => _preview(context),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: AppLoaderWidget())
          : _error != null
              ? _errorView()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.bluePrimary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16, 16, 16, canAct ? 100 : 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _headerCard(detail),
                        const SizedBox(height: 16),
                        if (_hasTimeline(detail)) ...[
                          _timelineCard(detail),
                          const SizedBox(height: 16),
                        ],
                        if (_infoRows(detail).isNotEmpty) ...[
                          _infoCard(detail),
                          const SizedBox(height: 16),
                        ],
                        if (detail.costBreakdown.isNotEmpty) ...[
                          _breakdownCard(detail.costBreakdown),
                          const SizedBox(height: 16),
                        ],
                        if (detail.milestones.isNotEmpty) ...[
                          _milestonesCard(detail.milestones),
                          const SizedBox(height: 16),
                        ],
                        if (detail.escrow != null) ...[
                          _escrowCard(detail.escrow!),
                          const SizedBox(height: 16),
                        ],
                        if (detail.relationshipManager != null)
                          _rmCard(detail.relationshipManager!),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: canAct && !_loading && _error == null
          ? _bottomActions(context, busy)
          : null,
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _load,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard(BuyerOfferDetail detail) {
    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.backgroundBlueVeryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: AppColors.bluePrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.projectName.isNotEmpty
                      ? detail.projectName
                      : 'Property offer',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    height: 1.25,
                  ),
                ),
                if (detail.unitLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    detail.unitLabel,
                    style: TextStyle(fontSize: 14, color: AppColors.textGray70),
                  ),
                ],
                const SizedBox(height: 10),
                OfferStatusChip(status: detail.status),
              ],
            ),
          ),
        ],
      ),
      footer: detail.totalCost.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total cost',
                    style: TextStyle(fontSize: 14, color: AppColors.textGray70),
                  ),
                  Text(
                    detail.totalCost,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.bluePrimary,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  bool _hasTimeline(BuyerOfferDetail d) =>
      d.sentAt != null ||
      d.viewedAt != null ||
      d.acceptedAt != null ||
      d.declinedAt != null;

  Widget _timelineCard(BuyerOfferDetail detail) {
    final events = <MapEntry<String, DateTime>>[
      if (detail.sentAt != null) MapEntry('Sent', detail.sentAt!),
      if (detail.viewedAt != null) MapEntry('Viewed', detail.viewedAt!),
      if (detail.acceptedAt != null) MapEntry('Accepted', detail.acceptedAt!),
      if (detail.declinedAt != null) MapEntry('Declined', detail.declinedAt!),
    ];
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Offer timeline'),
          const SizedBox(height: 8),
          ...events.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.bluePrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.key,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    DateTimeFormat.dateTime(e.value),
                    style: TextStyle(fontSize: 13, color: AppColors.textGray70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<MapEntry<String, String>> _infoRows(BuyerOfferDetail detail) => [
        if (detail.builderName.isNotEmpty)
          MapEntry(AppStrings.offerBuilder, detail.builderName),
        if ((detail.projectLocation ?? '').isNotEmpty)
          MapEntry(AppStrings.offerLocation, detail.projectLocation!),
        if ((detail.projectRera ?? '').isNotEmpty)
          MapEntry(AppStrings.offerRera, detail.projectRera!),
        if (detail.projectType.isNotEmpty)
          MapEntry('Project type', _pretty(detail.projectType)),
        if (detail.projectSubtype.isNotEmpty)
          MapEntry('Subtype', _pretty(detail.projectSubtype)),
      ];

  Widget _infoCard(BuyerOfferDetail detail) {
    final rows = _infoRows(detail);
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(AppStrings.offerOverview),
          const SizedBox(height: 4),
          ...rows.map((r) => _labelValue(r.key, r.value)),
        ],
      ),
    );
  }

  Widget _breakdownCard(Map<String, dynamic> breakdown) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(AppStrings.offerCostBreakdown),
          const SizedBox(height: 4),
          ...breakdown.entries.map((e) {
            final value = e.value;
            final formatted = value is num || double.tryParse('$value') != null
                ? CurrencyFormat.inr(value)
                : '$value';
            return _labelValue(_pretty('${e.key}'), formatted);
          }),
          if (_current.totalCost.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  _current.totalCost,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.bluePrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _milestonesCard(List<Map<String, dynamic>> milestones) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(AppStrings.offerMilestones),
          const SizedBox(height: 8),
          ...milestones.asMap().entries.map((entry) {
            final m = entry.value;
            final title =
                '${m['title'] ?? m['name'] ?? 'Milestone ${entry.key + 1}'}';
            final amount = m['amount'] ?? m['value'];
            final status = m['status'];
            final amountStr = amount != null ? CurrencyFormat.inr(amount) : '';
            final isLast = entry.key == milestones.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundBlueVeryLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.bluePrimary),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.bluePrimary,
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: AppColors.borderGrayLightNew,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (amountStr.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              amountStr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.bluePrimary,
                              ),
                            ),
                          ],
                          if (status != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _pretty('$status'),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textGray70,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _escrowCard(Map<String, dynamic> escrow) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined,
                  size: 20, color: AppColors.bluePrimary),
              const SizedBox(width: 8),
              _sectionTitle(AppStrings.escrowAccount),
            ],
          ),
          const SizedBox(height: 8),
          if (escrow['status'] != null)
            _labelValue('Status', _pretty('${escrow['status']}')),
          if (escrow['bank_name'] != null)
            _labelValue('Bank', '${escrow['bank_name']}'),
          if (escrow['account_number'] != null)
            _labelValue('Account', '${escrow['account_number']}'),
        ],
      ),
    );
  }

  Widget _rmCard(Map<String, dynamic> rm) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(AppStrings.offerRelationshipManager),
          const SizedBox(height: 4),
          _labelValue('Name', '${rm['name'] ?? ''}'),
          if (rm['rera_number'] != null)
            _labelValue('RERA', '${rm['rera_number']}'),
        ],
      ),
    );
  }

  Widget _bottomActions(BuildContext context, bool busy) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          border: Border(top: BorderSide(color: AppColors.borderGrayLightNew)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textBlack.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: busy ? null : () => _accept(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.bluePrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.offerAccept,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 10),
            PopupMenuButton<String>(
              enabled: !busy,
              icon: const Icon(Icons.more_horiz, color: AppColors.textDark),
              onSelected: (value) {
                switch (value) {
                  case 'preview':
                    _preview(context);
                  case 'claim':
                    _claim(context);
                  case 'decline':
                    _decline(context);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'preview',
                  child: Text(AppStrings.offerPreview),
                ),
                const PopupMenuItem(
                  value: 'claim',
                  child: Text(AppStrings.offerClaim),
                ),
                PopupMenuItem(
                  value: 'decline',
                  child: Text(
                    AppStrings.offerDecline,
                    style: TextStyle(color: AppColors.errorRed),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _preview(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final preview =
          await context.read<OffersProvider>().loadPreview(widget.summary.saleId);
      if (!context.mounted || preview == null) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.backgroundWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          builder: (_, scroll) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: ListView(
              controller: scroll,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderGrayLightNew,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.offerPreview,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  preview.projectName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (preview.unitTitle != null || preview.unitNumber.isNotEmpty)
                  Text(
                    preview.unitTitle ?? preview.unitNumber,
                    style: TextStyle(color: AppColors.textGray70),
                  ),
                if (preview.builderName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Builder: ${preview.builderName}'),
                ],
                if (preview.totalCost.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    preview.totalCost,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.bluePrimary,
                    ),
                  ),
                ],
                if (preview.costBreakdown.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.offerCostBreakdown,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ...preview.costBreakdown.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_pretty('${e.key}')),
                          Text(
                            CurrencyFormat.inr(e.value),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (preview.milestones.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.offerMilestones,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ...preview.milestones.map((m) {
                    final title = '${m['title'] ?? m['name'] ?? 'Milestone'}';
                    final amount = m['amount'] ?? m['value'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(child: Text(title)),
                          if (amount != null)
                            Text(
                              CurrencyFormat.inr(amount),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      );
    } on ServerException catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } on NetworkException catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _accept(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.offerAcceptTitle),
        content: const Text(AppStrings.offerAcceptMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.offerAccept),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await _runAction(
      context,
      () => context.read<OffersProvider>().accept(widget.summary.saleId),
      AppStrings.offerAccepted,
    );
  }

  Future<void> _decline(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.offerDeclineTitle),
        content: const Text(AppStrings.offerDeclineMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text(AppStrings.offerDecline),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await _runAction(
      context,
      () => context.read<OffersProvider>().decline(widget.summary.saleId),
      AppStrings.offerDeclined,
    );
  }

  Future<void> _claim(BuildContext context) async {
    final controller = TextEditingController();
    final token = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.offerClaim),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: AppStrings.offerClaimToken,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text(AppStrings.offerClaim),
          ),
        ],
      ),
    );
    if (token == null || !context.mounted) return;
    await _runAction(
      context,
      () => context.read<OffersProvider>().claim(widget.summary.saleId, token),
      AppStrings.offerClaimed,
    );
  }

  Future<void> _runAction(
    BuildContext context,
    Future<String?> Function() action,
    String successMessage,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final error = await action();
      if (!context.mounted) return;
      if (error != null) {
        messenger.showSnackBar(SnackBar(content: Text(error)));
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
      await _load();
    } on ServerException catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } on NetworkException catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  String _pretty(String v) => v
      .split(RegExp(r'[_\s]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  Widget _card({required Widget child, Widget? footer}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayLightNew),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          child,
          if (footer != null) footer,
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      );

  Widget _labelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: AppColors.textGray70)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
