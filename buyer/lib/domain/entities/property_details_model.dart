import 'property_model.dart';

class PropertyDetailsModel {
  final String id;
  final String title;
  final String subtitle;
  final String location;
  final String mainImageUrl;
  final List<String> galleryImages;
  final AgentModel agent;
  final String description;
  final AreaDetailsModel areaDetails;
  final PropertyInfoModel propertyInfo;
  final List<FacilityModel> facilities;
  final List<String> galleryFullImages;
  final List<PublicFacilityModel> publicFacilities;
  final MapLocationModel mapLocation;
  final String propertyType; // 'house', 'apartment', 'land', etc.
  final String? reraId; // RERA ID for land properties
  final List<PropertyTagModel>? imageTags; // Tags like "Plot Booked", "HDMA Approved"
  final List<DocumentModel>? documents; // Documents for land properties
  final LandLayoutInfoModel? landLayoutInfo; // Layout information for land properties
  final PlotDetailsModel? plotDetails; // Plot details for land properties
  final List<LayoutAmenityModel>? layoutAmenities; // Layout amenities for land properties
  final ConnectivityModel? connectivity; // Connectivity information for land properties
  final PricingModel? pricing; // Pricing information for land properties
  final List<PropertyModel>? relatedProperties; // Related properties for "Related Properties" section
  final List<UnitInfo> units; // Project units/inventory from the API
  final String? googleMapsLink; // Deep link to Google Maps (from the API)
  final String? builderName; // Real builder/developer name (from the API)

  const PropertyDetailsModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.mainImageUrl,
    required this.galleryImages,
    required this.agent,
    required this.description,
    required this.areaDetails,
    required this.propertyInfo,
    required this.facilities,
    required this.galleryFullImages,
    required this.publicFacilities,
    required this.mapLocation,
    this.propertyType = 'house',
    this.reraId,
    this.imageTags,
    this.documents,
    this.landLayoutInfo,
    this.plotDetails,
    this.layoutAmenities,
    this.connectivity,
    this.pricing,
    this.relatedProperties,
    this.units = const [],
    this.googleMapsLink,
    this.builderName,
  });

  bool get isLandProperty => propertyType.toLowerCase() == 'land';
}

/// A single unit/inventory item of a project (from GET /buyer/projects/{id}/units).
class UnitInfo {
  final String id;
  final String unitNumber;
  final String unitType; // flat / plot / villa / office / retail / warehouse
  final String title;
  final String inventoryStatus; // available / sold_registered / held / ...
  final String priceLabel; // formatted ₹ total (or base) price, may be empty
  final Map<String, dynamic> attributes;
  final Map<String, dynamic> pricing; // full price breakdown from the API

  const UnitInfo({
    required this.id,
    required this.unitNumber,
    required this.unitType,
    required this.title,
    required this.inventoryStatus,
    required this.priceLabel,
    this.attributes = const {},
    this.pricing = const {},
  });

  bool get isAvailable => inventoryStatus.toLowerCase() == 'available';

  String get filterBhkLabel {
    final label = '${attributes['bhk_label'] ?? ''}'.trim();
    if (label.isNotEmpty) return label;
    final bhk = attributes['bhk'];
    if (bhk == null) return '';
    final n = int.tryParse('$bhk');
    return n != null ? '$n BHK' : '$bhk';
  }

  String get filterFacing => _prettyAttr(attributes['facing']);

  String get filterTower => _prettyAttr(attributes['tower']);

  double? get filterPrice {
    final raw = pricing['total_price'] ?? pricing['base_price'];
    return double.tryParse('${raw ?? ''}');
  }

  double? get filterArea {
    final raw = attributes['carpet_area_sqft'] ??
        attributes['super_built_up_area_sqft'];
    return double.tryParse('${raw ?? ''}');
  }

  static String _prettyAttr(dynamic v) {
    final s = '$v'.trim();
    if (s.isEmpty) return '';
    return s
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  /// Amenity slugs from the unit's attributes (e.g. ['modular_kitchen']).
  List<String> get amenities {
    final a = attributes['amenities_included'];
    if (a is List) {
      return a.map((e) => '$e').where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }
}

class AgentModel {
  final String name;
  final String role;
  final String imageUrl;
  final String phoneNumber;
  final String email;

  const AgentModel({
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.phoneNumber,
    required this.email,
  });
}

class AreaDetailsModel {
  final String indoorArea;
  final String indoorAreaLabel;
  final String openSkyArea;
  final String openSkyAreaLabel;

  const AreaDetailsModel({
    required this.indoorArea,
    required this.indoorAreaLabel,
    required this.openSkyArea,
    required this.openSkyAreaLabel,
  });
}

class PropertyInfoModel {
  final String sqft;
  final String sqftLabel;
  final String bedrooms;
  final String bedroomsLabel;
  final String bathrooms;
  final String bathroomsLabel;
  final String safetyRank;
  final String safetyRankLabel;

  const PropertyInfoModel({
    required this.sqft,
    required this.sqftLabel,
    required this.bedrooms,
    required this.bedroomsLabel,
    required this.bathrooms,
    required this.bathroomsLabel,
    required this.safetyRank,
    required this.safetyRankLabel,
  });
}

class FacilityModel {
  final String name;
  final String iconName;

  const FacilityModel({required this.name, required this.iconName});
}

class PublicFacilityModel {
  final String name;
  final String iconName;

  const PublicFacilityModel({required this.name, required this.iconName});
}

class MapLocationModel {
  final double latitude;
  final double longitude;
  final String mapImageUrl;

  const MapLocationModel({required this.latitude, required this.longitude, required this.mapImageUrl});
}

class PropertyTagModel {
  final String text;
  final String color; // 'green', 'gray', etc.

  const PropertyTagModel({required this.text, required this.color});
}

class DocumentModel {
  final String id;
  final String title;
  final String date;
  final String? downloadUrl;

  const DocumentModel({required this.id, required this.title, required this.date, this.downloadUrl});
}

class LandLayoutInfoModel {
  final String approvalType;
  final String totalArea;
  final String totalPlots;
  final String numberOfBlocks;
  final String roadWidths;
  final bool isReraCertified;

  const LandLayoutInfoModel({
    required this.approvalType,
    required this.totalArea,
    required this.totalPlots,
    required this.numberOfBlocks,
    required this.roadWidths,
    this.isReraCertified = true,
  });
}

class PlotDetailsModel {
  final String plotNumber;
  final String block;
  final String plotSize;
  final String facing;
  final String roadWidth;
  final List<String> tags;

  const PlotDetailsModel({
    required this.plotNumber,
    required this.block,
    required this.plotSize,
    required this.facing,
    required this.roadWidth,
    this.tags = const [],
  });
}

class LayoutAmenityModel {
  final String name;
  final String? iconName;
  final bool isAvailable;

  const LayoutAmenityModel({required this.name, this.iconName, this.isAvailable = false});
}

class ConnectivityModel {
  final String airport;
  final String orr;
  final String schools;
  final String hospitals;
  final String techParks;
  final String metroStation;
  final String majorRoad;

  const ConnectivityModel({
    required this.airport,
    required this.orr,
    required this.schools,
    required this.hospitals,
    required this.techParks,
    this.metroStation = '',
    this.majorRoad = '',
  });
}

class PricingModel {
  final String totalAmount;
  final String amountPaid;
  final String balance;
  final List<PriceBreakdownItem> breakdown;
  final String grandTotal;
  final List<PaymentMilestone> milestones;
  final EmiCalculatorModel emiCalculator;
  final RelationshipManagerModel relationshipManager;
  final String nextPaymentAmount;

  const PricingModel({
    required this.totalAmount,
    required this.amountPaid,
    required this.balance,
    required this.breakdown,
    required this.grandTotal,
    required this.milestones,
    required this.emiCalculator,
    required this.relationshipManager,
    required this.nextPaymentAmount,
  });
}

class PriceBreakdownItem {
  final String label;
  final String amount;
  final bool isSubtotal;

  const PriceBreakdownItem({required this.label, required this.amount, this.isSubtotal = false});
}

class PaymentMilestone {
  final int number;
  final String title;
  final String date;
  final String amount;
  final String status; // 'paid', 'due', 'pending'

  const PaymentMilestone({
    required this.number,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
  });
}

class EmiCalculatorModel {
  final String loanAmount;
  final String tenure;
  final String interestRate;
  final String monthlyEmi;
  final String totalInterest;
  final String totalAmount;

  const EmiCalculatorModel({
    required this.loanAmount,
    required this.tenure,
    required this.interestRate,
    required this.monthlyEmi,
    required this.totalInterest,
    required this.totalAmount,
  });
}

class RelationshipManagerModel {
  final String name;
  final String role;
  final String imageUrl;
  final String reraId;
  final bool isVerified;
  final String phoneNumber;
  final String email;

  const RelationshipManagerModel({
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.reraId,
    this.isVerified = true,
    required this.phoneNumber,
    required this.email,
  });
}
