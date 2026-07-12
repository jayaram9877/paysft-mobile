import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/unit_filter_logic.dart';
import '../../../domain/entities/property_details_model.dart';
import '../../../domain/entities/visit_meeting.dart';
import '../../pages/unit_details_page.dart';
import '../../providers/lead_provider.dart';
import '../../providers/saved_units_provider.dart';
import '../../providers/visits_provider.dart';
import 'interest_button.dart';
import '../meetings/meeting_card.dart';
import '../meetings/meetings_view.dart' show openMeetingDetails;

/// Units tab with search + filters. Use [asSliver] inside [CustomScrollView].
class PropertyUnitsSliverList extends StatefulWidget {
  final List<UnitInfo> units;
  final bool asSliver;

  const PropertyUnitsSliverList({
    super.key,
    required this.units,
    this.asSliver = true,
  });

  @override
  State<PropertyUnitsSliverList> createState() =>
      _PropertyUnitsSliverListState();
}

/// Column-based units list for pages that are not sliver-driven.
class PropertyUnitsSection extends StatelessWidget {
  final List<UnitInfo> units;

  const PropertyUnitsSection({super.key, required this.units});

  @override
  Widget build(BuildContext context) {
    return PropertyUnitsSliverList(units: units, asSliver: false);
  }
}

class _PropertyUnitsSliverListState extends State<PropertyUnitsSliverList> {
  late UnitFilterState _filter;
  late UnitFilterOptions _options;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filter = UnitFilterState.defaultsFor(widget.units.length);
    _options = UnitFilterLogic.optionsFor(widget.units);
    _searchController.text = _filter.search;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeadProvider>().ensureLoaded();
      context.read<SavedUnitsProvider>().ensureLoaded();
      context.read<VisitsProvider>().ensureLoaded();
    });
  }

  @override
  void didUpdateWidget(PropertyUnitsSliverList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.units != widget.units) {
      _options = UnitFilterLogic.optionsFor(widget.units);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setFilter(UnitFilterState next) {
    setState(() => _filter = next);
  }

  List<UnitInfo> get _filtered =>
      UnitFilterLogic.apply(widget.units, _filter);

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<UnitFilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _UnitFilterSheet(
        initial: _filter,
        options: _options,
      ),
    );
    if (result != null) _setFilter(result.copyWith(search: _filter.search));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final list = filtered.isEmpty
        ? [_buildEmptyState()]
        : filtered.map((u) => _UnitCard(unit: u)).toList();

    if (!widget.asSliver) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFilterHeader(filtered.length),
          ...list,
        ],
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: _buildFilterHeader(filtered.length)),
        if (filtered.isEmpty)
          SliverToBoxAdapter(child: _buildEmptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _UnitCard(unit: filtered[index]),
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterHeader(int shown) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.unitFilters,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.backgroundBlueVeryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.units.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bluePrimary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${AppStrings.unitsShowing} $shown ${AppStrings.unitsOf} ${widget.units.length}',
                style: TextStyle(fontSize: 12, color: AppColors.textGray70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => _setFilter(_filter.copyWith(search: v)),
                  decoration: InputDecoration(
                    hintText: AppStrings.unitSearchHint,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGray70,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textGray70,
                      size: 22,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundGrayLight,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: AppColors.backgroundBlueVeryLight,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _openFilterSheet,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.tune_rounded,
                          color: AppColors.bluePrimary,
                        ),
                        if (_filter.activeChipCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 16,
                              height: 16,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: AppColors.bluePrimary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${_filter.activeChipCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: _options.availableCount > 0
                      ? '${AppStrings.unitsAvailableOnly} (${_options.availableCount})'
                      : AppStrings.unitsAvailableOnly,
                  selected: _filter.availableOnly,
                  onTap: () => _setFilter(
                    _filter.copyWith(availableOnly: !_filter.availableOnly),
                  ),
                ),
                ..._options.bhk.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _FilterChip(
                      label: b,
                      selected: _filter.bhk.contains(b),
                      onTap: () {
                        final next = Set<String>.from(_filter.bhk);
                        if (next.contains(b)) {
                          next.remove(b);
                        } else {
                          next.add(b);
                        }
                        _setFilter(_filter.copyWith(bhk: next));
                      },
                    ),
                  ),
                ),
                if (_filter.hasActiveFilters)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ActionChip(
                      label: Text(AppStrings.clearFilters),
                      avatar: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        _setFilter(const UnitFilterState());
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 48, color: AppColors.textGray70.withValues(alpha: 0.6)),
          const SizedBox(height: 16),
          Text(
            AppStrings.unitNoMatches,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.unitNoMatchesHint,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textGray70),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              _searchController.clear();
              _setFilter(const UnitFilterState());
            },
            child: Text(AppStrings.clearFilters),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: selected ? AppColors.bluePrimary : AppColors.textDark,
      ),
      selectedColor: AppColors.backgroundBlueVeryLight,
      backgroundColor: AppColors.backgroundWhite,
      side: BorderSide(
        color: selected ? AppColors.bluePrimary : AppColors.borderGrayLightNew,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => onTap(),
    );
  }
}

class _UnitFilterSheet extends StatefulWidget {
  final UnitFilterState initial;
  final UnitFilterOptions options;

  const _UnitFilterSheet({
    required this.initial,
    required this.options,
  });

  @override
  State<_UnitFilterSheet> createState() => _UnitFilterSheetState();
}

class _UnitFilterSheetState extends State<_UnitFilterSheet> {
  late UnitFilterState _draft;
  late RangeValues _priceRange;
  late RangeValues _areaRange;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    _priceRange = RangeValues(
      _draft.minPrice ?? widget.options.minPrice,
      _draft.maxPrice ?? widget.options.maxPrice,
    );
    _areaRange = RangeValues(
      _draft.minArea ?? widget.options.minArea,
      _draft.maxArea ?? widget.options.maxArea,
    );
  }

  bool get _hasPrice =>
      widget.options.maxPrice > widget.options.minPrice;

  bool get _hasArea => widget.options.maxArea > widget.options.minArea;

  void _toggleUnitType(String value) {
    final next = Set<String>.from(_draft.unitTypes);
    next.contains(value) ? next.remove(value) : next.add(value);
    setState(() => _draft = _draft.copyWith(unitTypes: next));
  }

  void _toggleFacing(String value) {
    final next = Set<String>.from(_draft.facing);
    next.contains(value) ? next.remove(value) : next.add(value);
    setState(() => _draft = _draft.copyWith(facing: next));
  }

  void _toggleTower(String value) {
    final next = Set<String>.from(_draft.towers);
    next.contains(value) ? next.remove(value) : next.add(value);
    setState(() => _draft = _draft.copyWith(towers: next));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (_, scroll) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderGrayLightNew,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  AppStrings.filters,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _draft = UnitFilterState(search: _draft.search);
                      _priceRange = RangeValues(
                        widget.options.minPrice,
                        widget.options.maxPrice,
                      );
                      _areaRange = RangeValues(
                        widget.options.minArea,
                        widget.options.maxArea,
                      );
                    });
                  },
                  child: Text(AppStrings.clearFilters),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                controller: scroll,
                children: [
                  if (_hasPrice) ...[
                    _sectionTitle(AppStrings.unitPriceRange),
                    RangeSlider(
                      values: _priceRange,
                      min: widget.options.minPrice,
                      max: widget.options.maxPrice,
                      divisions: 20,
                      labels: RangeLabels(
                        CurrencyFormat.inr(_priceRange.start.round()),
                        CurrencyFormat.inr(_priceRange.end.round()),
                      ),
                      onChanged: (v) => setState(() => _priceRange = v),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(CurrencyFormat.inr(_priceRange.start.round())),
                        Text(CurrencyFormat.inr(_priceRange.end.round())),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (_hasArea) ...[
                    _sectionTitle(AppStrings.unitAreaRange),
                    RangeSlider(
                      values: _areaRange,
                      min: widget.options.minArea,
                      max: widget.options.maxArea,
                      divisions: 20,
                      labels: RangeLabels(
                        '${_areaRange.start.round()}',
                        '${_areaRange.end.round()}',
                      ),
                      onChanged: (v) => setState(() => _areaRange = v),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (widget.options.unitTypes.isNotEmpty) ...[
                    _sectionTitle(AppStrings.unitType),
                    _chipWrap(
                      widget.options.unitTypes,
                      _draft.unitTypes,
                      _toggleUnitType,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (widget.options.facing.isNotEmpty) ...[
                    _sectionTitle(AppStrings.unitFacing),
                    _chipWrap(
                      widget.options.facing,
                      _draft.facing,
                      _toggleFacing,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (widget.options.towers.isNotEmpty) ...[
                    _sectionTitle(AppStrings.unitTower),
                    _chipWrap(
                      widget.options.towers,
                      _draft.towers,
                      _toggleTower,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    _draft.copyWith(
                      minPrice: _hasPrice ? _priceRange.start : null,
                      maxPrice: _hasPrice ? _priceRange.end : null,
                      minArea: _hasArea ? _areaRange.start : null,
                      maxArea: _hasArea ? _areaRange.end : null,
                      clearPrice: !_hasPrice,
                      clearArea: !_hasArea,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.bluePrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(AppStrings.applyFilters),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      );

  Widget _chipWrap(
    List<String> options,
    Set<String> selected,
    ValueChanged<String> onTap,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options
          .map(
            (o) => FilterChip(
              label: Text(o),
              selected: selected.contains(o),
              showCheckmark: false,
              selectedColor: AppColors.backgroundBlueVeryLight,
              onSelected: (_) => onTap(o),
            ),
          )
          .toList(),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final UnitInfo unit;

  const _UnitCard({required this.unit});

  VisitMeeting? _scheduledVisit(BuildContext context) {
    final visits = context.watch<VisitsProvider>().visits;
    final matches = visits
        .where((v) => v.unitId == unit.id && v.status == 'scheduled')
        .toList()
      ..sort((a, b) {
        final ad = a.scheduledFor;
        final bd = b.scheduledFor;
        if (ad == null || bd == null) return 0;
        return ad.compareTo(bd);
      });
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Widget build(BuildContext context) {
    final visit = _scheduledVisit(context);
    final meta = <String>[
      if (unit.filterBhkLabel.isNotEmpty) unit.filterBhkLabel,
      if (unit.unitType.isNotEmpty) unit.unitType,
      if (unit.filterFacing.isNotEmpty) unit.filterFacing,
      if (unit.filterTower.isNotEmpty) unit.filterTower,
      if (unit.unitNumber.isNotEmpty) 'No. ${unit.unitNumber}',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => UnitDetailsPage(unit: unit)),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGrayLightNew),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (meta.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              meta.join('  •  '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textGray70,
                              ),
                            ),
                          ],
                          if (unit.priceLabel.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              unit.priceLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.bluePrimary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _statusChip(unit.inventoryStatus),
                        const SizedBox(height: 8),
                        _SaveButton(unitId: unit.id),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InterestButton(unitId: unit.id),
                if (visit != null)
                  MeetingScheduledBanner(
                    visit: visit,
                    onTap: () => openMeetingDetails(context, visit),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _statusChip(String status) {
    final label = status.isEmpty
        ? ''
        : status
            .split('_')
            .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
    if (label.isEmpty) return const SizedBox.shrink();

    final s = status.toLowerCase();
    Color bg;
    Color fg;
    if (s == 'available') {
      bg = AppColors.tokenPaidGreen.withValues(alpha: 0.12);
      fg = AppColors.tokenPaidGreen;
    } else if (s.startsWith('sold')) {
      bg = AppColors.errorRed.withValues(alpha: 0.10);
      fg = AppColors.errorRed;
    } else {
      bg = AppColors.textGray70.withValues(alpha: 0.10);
      fg = AppColors.textGray70;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String unitId;

  const _SaveButton({required this.unitId});

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedUnitsProvider>();
    final isSaved = saved.isSaved(unitId);
    final busy = saved.isBusy(unitId);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: busy
          ? null
          : () async {
              final msg =
                  await context.read<SavedUnitsProvider>().toggleSaved(unitId);
              if (msg != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                size: 22,
                color: isSaved ? AppColors.bluePrimary : AppColors.textGray70,
              ),
      ),
    );
  }
}
