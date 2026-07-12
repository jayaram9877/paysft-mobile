import 'package:buyer/presentation/widgets/common/custom_snackbar.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/property_details_model.dart';
import '../../domain/entities/property_model.dart';
import '../../domain/repositories/property_details_repository.dart';
import '../widgets/property_details/share_modal.dart';

class PropertyDetailsProvider extends ChangeNotifier {
  final PropertyDetailsRepository repository;

  PropertyDetailsProvider({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  PropertyDetailsModel? _propertyDetails;
  PropertyDetailsModel? get propertyDetails => _propertyDetails;

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  Future<void> loadPropertyDetails(PropertyModel property) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _propertyDetails = await repository.getPropertyDetails(property);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onTabChanged(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void onBackPressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  void onSharePressed(BuildContext context) {
    if (_propertyDetails == null) return;

    showDialog(
      context: context,

      builder: (ac) => Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TapRegion(
                onTapOutside: (details) => Navigator.pop(ac),
                child: SizedBox(
                  width: double.infinity,
                  child: ShareModal(property: _propertyDetails!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onFavoritePressed(BuildContext context) {
    CustomSnackbar.showAddedToFavorites(context);
  }

  void onCallAgent() {}

  void onMessageAgent() {}

  void onSeeAllGallery() {}
}
