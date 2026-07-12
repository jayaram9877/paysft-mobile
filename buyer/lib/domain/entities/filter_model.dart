import 'package:syncfusion_flutter_sliders/sliders.dart';

class FilterModel {
  final bool isResidential;
  final bool isCommercial;
  final String selectedCategory;
  final SfRangeValues priceRange;
  final String selectedBedrooms;
  final String selectedArea;
  final String selectedPlotArea;

  const FilterModel({
    this.isResidential = false,
    this.isCommercial = false,
    required this.selectedCategory,
    required this.priceRange,
    required this.selectedBedrooms,
    required this.selectedArea,
    required this.selectedPlotArea,
  });

  factory FilterModel.defaultModel() {
    return const FilterModel(
      isResidential: false,
      isCommercial: false,
      selectedCategory: '',
      priceRange: SfRangeValues(1.0, 25.0),
      selectedBedrooms: 'Any',
      selectedArea: 'Min',
      selectedPlotArea: 'Min',
    );
  }

  FilterModel copyWith({
    bool? isResidential,
    bool? isCommercial,
    String? selectedCategory,
    SfRangeValues? priceRange,
    String? selectedBedrooms,
    String? selectedArea,
    String? selectedPlotArea,
  }) {
    return FilterModel(
      isResidential: isResidential ?? this.isResidential,
      isCommercial: isCommercial ?? this.isCommercial,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      priceRange: priceRange ?? this.priceRange,
      selectedBedrooms: selectedBedrooms ?? this.selectedBedrooms,
      selectedArea: selectedArea ?? this.selectedArea,
      selectedPlotArea: selectedPlotArea ?? this.selectedPlotArea,
    );
  }
}
