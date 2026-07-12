import '../entities/property_details_model.dart';
import '../entities/property_model.dart';

abstract class PropertyDetailsRepository {
  Future<PropertyDetailsModel> getPropertyDetails(PropertyModel property);
}
