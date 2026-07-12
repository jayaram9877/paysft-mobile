import '../../domain/entities/property_details_model.dart';
import '../../domain/repositories/property_details_repository.dart';
import '../datasources/remote/property_details_remote_data_source.dart';
import '../../domain/entities/property_model.dart';

class PropertyDetailsRepositoryImpl implements PropertyDetailsRepository {
  final PropertyDetailsRemoteDataSource remoteDataSource;

  PropertyDetailsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PropertyDetailsModel> getPropertyDetails(PropertyModel property) {
    return remoteDataSource.getPropertyDetails(property);
  }
}
