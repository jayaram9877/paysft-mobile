import 'package:flutter/foundation.dart';
import '../../domain/entities/property_model.dart';
import '../../domain/entities/property_details_model.dart';
import '../../core/constants/app_string_constants.dart';

class AgentProfileProvider extends ChangeNotifier {
  AgentModel? _agent;
  AgentModel? get agent => _agent;

  List<PropertyModel> _allProperties = [];
  List<PropertyModel> _filteredProperties = [];
  List<PropertyModel> get agentProperties => _filteredProperties;

  int _selectedCategoryIndex = 0;
  int get selectedCategoryIndex => _selectedCategoryIndex;

  final List<String> categories = [
    AppStrings.categoryAll,
    AppStrings.residential,
    AppStrings.commercial,
    AppStrings.lands,
  ];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setAgent(AgentModel agent) {
    _agent = agent;
    _loadAgentProperties();
  }

  void _loadAgentProperties() {
    _isLoading = true;
    notifyListeners();

    // Mocking agent properties for now
    _allProperties = [
      const PropertyModel(
        id: '1',
        title: 'The White Gloves',
        location: 'Banjara Hills, Hyderabad',
        imageUrl:
            'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
        propertyType: 'House',
      ),
      const PropertyModel(
        id: '2',
        title: 'Modern Luxury Villa',
        location: 'Jubilee Hills, Hyderabad',
        imageUrl:
            'https://images.unsplash.com/photo-1613490493576-7fde63acd811',
        propertyType: 'Villa',
      ),
      const PropertyModel(
        id: '3',
        title: 'Skyline Apartment',
        location: 'Gachibowli, Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
        propertyType: 'Apartment',
      ),
      const PropertyModel(
        id: '4',
        title: 'Green Valley House',
        location: 'Puppalaguda, Hyderabad',
        imageUrl:
            'https://images.unsplash.com/photo-1564013799919-ab600027ffc6',
        propertyType: 'House',
      ),
    ];

    _applyFilter();

    _isLoading = false;
    notifyListeners();
  }

  void onCategoryChanged(int index) {
    _selectedCategoryIndex = index;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    final selectedCategory = categories[_selectedCategoryIndex];
    if (selectedCategory == AppStrings.categoryAll) {
      _filteredProperties = List.from(_allProperties);
    } else if (selectedCategory == AppStrings.residential) {
      _filteredProperties = _allProperties.where((p) {
        final type = p.propertyType.toLowerCase();
        return type == AppStrings.categoryHouse.toLowerCase() ||
            type == AppStrings.categoryVilla.toLowerCase() ||
            type == AppStrings.categoryApartment.toLowerCase() ||
            type == AppStrings.residential.toLowerCase();
      }).toList();
    } else if (selectedCategory == AppStrings.commercial) {
      _filteredProperties = _allProperties
          .where(
            (p) =>
                p.propertyType.toLowerCase() ==
                AppStrings.commercial.toLowerCase(),
          )
          .toList();
    } else if (selectedCategory == AppStrings.lands) {
      _filteredProperties = _allProperties
          .where(
            (p) =>
                p.propertyType.toLowerCase() ==
                    AppStrings.lands.toLowerCase() ||
                p.propertyType.toLowerCase() == 'land',
          )
          .toList();
    } else {
      _filteredProperties = _allProperties
          .where(
            (p) =>
                p.propertyType.toLowerCase() == selectedCategory.toLowerCase(),
          )
          .toList();
    }
  }

  void onCallAgent() {
    // Implement call integration
  }

  void onMessageAgent() {
    // Implement message integration
  }
}
