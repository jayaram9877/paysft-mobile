import 'package:equatable/equatable.dart';

class PropertyModel extends Equatable {
  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final bool isFeatured;
  final String? facing;
  final String? sftArea;
  final String? unitType;
  final bool hasPayment;
  final String? nextPaymentAmount;
  final String? dueDate;
  final String propertyType; // 'residential', 'commercial', 'land'

  const PropertyModel({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    this.isFeatured = false,
    this.facing,
    this.sftArea,
    this.unitType,
    this.hasPayment = false,
    this.nextPaymentAmount,
    this.dueDate,
    this.propertyType = 'residential',
  });

  @override
  List<Object?> get props => [
        id,
        title,
        location,
        imageUrl,
        isFeatured,
        facing,
        sftArea,
        unitType,
        hasPayment,
        nextPaymentAmount,
        dueDate,
        propertyType,
      ];
}
