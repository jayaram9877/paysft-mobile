import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../../domain/entities/filter_model.dart';

class FilterProvider extends ChangeNotifier {
  FilterModel _filterModel = FilterModel.defaultModel();
  FilterModel get filterModel => _filterModel;
  
  Function(FilterModel)? onFiltersApplied;

  void setResidential(bool value) {
    _filterModel = _filterModel.copyWith(isResidential: value);
    notifyListeners();
  }

  void setCommercial(bool value) {
    _filterModel = _filterModel.copyWith(isCommercial: value);
    notifyListeners();
  }

  void setCategory(String category) {
    _filterModel = _filterModel.copyWith(selectedCategory: category);
    notifyListeners();
  }

  void setPriceRange(SfRangeValues range) {
    _filterModel = _filterModel.copyWith(priceRange: range);
    notifyListeners();
  }

  void setBedrooms(String bedrooms) {
    _filterModel = _filterModel.copyWith(selectedBedrooms: bedrooms);
    notifyListeners();
  }

  void setArea(String area) {
    _filterModel = _filterModel.copyWith(selectedArea: area);
    notifyListeners();
  }

  void setPlotArea(String plotArea) {
    _filterModel = _filterModel.copyWith(selectedPlotArea: plotArea);
    notifyListeners();
  }

  void resetFilters() {
    _filterModel = FilterModel.defaultModel();
    notifyListeners();
  }

  void applyFilters(BuildContext context) {
    // Call the callback if provided
    if (onFiltersApplied != null) {
      onFiltersApplied!(_filterModel);
    }
    Navigator.of(context).pop();
  }

  void cancel(BuildContext context) {
    Navigator.of(context).pop();
  }
}
