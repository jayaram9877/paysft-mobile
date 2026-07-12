import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  final String id;
  final String name;
  final String imageUrl;

  const LocationModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, imageUrl];
}
