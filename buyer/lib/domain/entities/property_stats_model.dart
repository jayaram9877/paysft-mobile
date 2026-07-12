class PropertyStatsModel {
  final int totalProperties;
  final String pendingPayments;
  final PropertyTypeStatsModel propertyTypeStats;
  final FeaturedPropertyModel? featuredProperty;

  const PropertyStatsModel({
    required this.totalProperties,
    required this.pendingPayments,
    required this.propertyTypeStats,
    this.featuredProperty,
  });
}

class PropertyTypeStatsModel {
  final int residential;
  final int commercial;
  final int lands;

  const PropertyTypeStatsModel({
    required this.residential,
    required this.commercial,
    required this.lands,
  });
}

class FeaturedPropertyModel {
  final String id;
  final String name;
  final String location;
  final String nextPayment;
  final String dueDate;

  const FeaturedPropertyModel({
    required this.id,
    required this.name,
    required this.location,
    required this.nextPayment,
    required this.dueDate,
  });
}

class QuickActionModel {
  final String id;
  final String name;
  final String tag;
  final String iconPath;

  const QuickActionModel({
    required this.id,
    required this.name,
    required this.tag,
    required this.iconPath,
  });
}
