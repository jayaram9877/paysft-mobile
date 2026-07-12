import '../../domain/entities/property_details_model.dart';

/// Buyer-side filters for the property units tab.
class UnitFilterState {
  final String search;
  final bool availableOnly;
  final Set<String> bhk;
  final Set<String> unitTypes;
  final Set<String> facing;
  final Set<String> towers;
  final double? minPrice;
  final double? maxPrice;
  final double? minArea;
  final double? maxArea;

  const UnitFilterState({
    this.search = '',
    this.availableOnly = false,
    this.bhk = const {},
    this.unitTypes = const {},
    this.facing = const {},
    this.towers = const {},
    this.minPrice,
    this.maxPrice,
    this.minArea,
    this.maxArea,
  });

  factory UnitFilterState.defaultsFor(int unitCount) => UnitFilterState(
        availableOnly: unitCount > 20,
      );

  bool get hasActiveFilters =>
      search.isNotEmpty ||
      availableOnly ||
      bhk.isNotEmpty ||
      unitTypes.isNotEmpty ||
      facing.isNotEmpty ||
      towers.isNotEmpty ||
      minPrice != null ||
      maxPrice != null ||
      minArea != null ||
      maxArea != null;

  int get activeChipCount {
    var n = 0;
    if (availableOnly) n++;
    n += bhk.length;
    n += unitTypes.length;
    n += facing.length;
    n += towers.length;
    if (minPrice != null || maxPrice != null) n++;
    if (minArea != null || maxArea != null) n++;
    return n;
  }

  UnitFilterState copyWith({
    String? search,
    bool? availableOnly,
    Set<String>? bhk,
    Set<String>? unitTypes,
    Set<String>? facing,
    Set<String>? towers,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    bool clearPrice = false,
    bool clearArea = false,
  }) {
    return UnitFilterState(
      search: search ?? this.search,
      availableOnly: availableOnly ?? this.availableOnly,
      bhk: bhk ?? this.bhk,
      unitTypes: unitTypes ?? this.unitTypes,
      facing: facing ?? this.facing,
      towers: towers ?? this.towers,
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      minArea: clearArea ? null : (minArea ?? this.minArea),
      maxArea: clearArea ? null : (maxArea ?? this.maxArea),
    );
  }

  UnitFilterState cleared() => UnitFilterState(
        search: search,
        availableOnly: false,
      );
}

class UnitFilterOptions {
  final List<String> bhk;
  final List<String> unitTypes;
  final List<String> facing;
  final List<String> towers;
  final double minPrice;
  final double maxPrice;
  final double minArea;
  final double maxArea;
  final int availableCount;

  const UnitFilterOptions({
    required this.bhk,
    required this.unitTypes,
    required this.facing,
    required this.towers,
    required this.minPrice,
    required this.maxPrice,
    required this.minArea,
    required this.maxArea,
    required this.availableCount,
  });
}

class UnitFilterLogic {
  const UnitFilterLogic._();

  static UnitFilterOptions optionsFor(List<UnitInfo> units) {
    final bhk = <String>{};
    final types = <String>{};
    final facing = <String>{};
    final towers = <String>{};
    var minPrice = double.infinity;
    var maxPrice = 0.0;
    var minArea = double.infinity;
    var maxArea = 0.0;
    var availableCount = 0;

    for (final u in units) {
      if (u.isAvailable) availableCount++;
      final label = u.filterBhkLabel;
      if (label.isNotEmpty) bhk.add(label);
      if (u.unitType.isNotEmpty) types.add(u.unitType);
      if (u.filterFacing.isNotEmpty) facing.add(u.filterFacing);
      if (u.filterTower.isNotEmpty) towers.add(u.filterTower);
      final price = u.filterPrice;
      if (price != null) {
        minPrice = price < minPrice ? price : minPrice;
        maxPrice = price > maxPrice ? price : maxPrice;
      }
      final area = u.filterArea;
      if (area != null) {
        minArea = area < minArea ? area : minArea;
        maxArea = area > maxArea ? area : maxArea;
      }
    }

    int sortBhk(String a, String b) {
      final na = int.tryParse(a.split(' ').first) ?? 0;
      final nb = int.tryParse(b.split(' ').first) ?? 0;
      return na.compareTo(nb);
    }

    final bhkList = bhk.toList()..sort(sortBhk);

    return UnitFilterOptions(
      bhk: bhkList,
      unitTypes: types.toList()..sort(),
      facing: facing.toList()..sort(),
      towers: towers.toList()..sort(),
      minPrice: minPrice.isFinite ? minPrice : 0,
      maxPrice: maxPrice > 0 ? maxPrice : 0,
      minArea: minArea.isFinite ? minArea : 0,
      maxArea: maxArea > 0 ? maxArea : 0,
      availableCount: availableCount,
    );
  }

  static List<UnitInfo> apply(List<UnitInfo> units, UnitFilterState filter) {
    final q = filter.search.trim().toLowerCase();
    return units.where((u) {
      if (filter.availableOnly && !u.isAvailable) return false;
      if (q.isNotEmpty) {
        final haystack = [
          u.unitNumber,
          u.title,
          u.unitType,
          u.filterBhkLabel,
          u.filterTower,
          u.filterFacing,
        ].join(' ').toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      if (filter.bhk.isNotEmpty && !filter.bhk.contains(u.filterBhkLabel)) {
        return false;
      }
      if (filter.unitTypes.isNotEmpty && !filter.unitTypes.contains(u.unitType)) {
        return false;
      }
      if (filter.facing.isNotEmpty && !filter.facing.contains(u.filterFacing)) {
        return false;
      }
      if (filter.towers.isNotEmpty && !filter.towers.contains(u.filterTower)) {
        return false;
      }
      final price = u.filterPrice;
      if (filter.minPrice != null && (price == null || price < filter.minPrice!)) {
        return false;
      }
      if (filter.maxPrice != null && (price == null || price > filter.maxPrice!)) {
        return false;
      }
      final area = u.filterArea;
      if (filter.minArea != null && (area == null || area < filter.minArea!)) {
        return false;
      }
      if (filter.maxArea != null && (area == null || area > filter.maxArea!)) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }
}
