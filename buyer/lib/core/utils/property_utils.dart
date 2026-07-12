import '../../domain/entities/property_model.dart';

/// Property type enum for navigation
enum PropertyType { residential, commercial, land }

/// Utility class for property-related helper functions
class PropertyUtils {
  /// Checks if a property is a land/plot based on its title
  /// Returns true if the title contains "land" or "plot" (case-insensitive)
  static bool isLandOrPlot(PropertyModel property) {
    final titleLower = property.title.toLowerCase();
    return titleLower.contains('land') || titleLower.contains('plot');
  }

  /// Checks if a property is commercial based on its title
  /// Returns true if the title contains "commercial", "office", or "shop" (case-insensitive)
  static bool isCommercial(PropertyModel property) {
    final titleLower = property.title.toLowerCase();
    return titleLower.contains('commercial') ||
        titleLower.contains('office') ||
        titleLower.contains('shop');
  }

  /// Checks if a property is residential based on its title
  /// Returns true if the title contains "residential", "apartment", "house", or "villa" (case-insensitive)
  static bool isResidential(PropertyModel property) {
    final titleLower = property.title.toLowerCase();
    return titleLower.contains('residential') ||
        titleLower.contains('apartment') ||
        titleLower.contains('house') ||
        titleLower.contains('villa');
  }

  /// Determines the property type based on propertyType field or title
  /// Priority: propertyType field > Title-based detection > Default (Residential)
  static PropertyType getPropertyType(PropertyModel property) {
    // First, check if propertyType is explicitly set in the model
    final typeLower = property.propertyType.toLowerCase();
    if (typeLower == 'land' || typeLower == 'plot') {
      return PropertyType.land;
    } else if (typeLower == 'commercial') {
      return PropertyType.commercial;
    } else if (typeLower == 'residential') {
      return PropertyType.residential;
    }
    
    // Fallback to title-based detection if propertyType is not set or invalid
    if (isLandOrPlot(property)) {
      return PropertyType.land;
    } else if (isCommercial(property)) {
      return PropertyType.commercial;
    } else {
      // Default to residential if not explicitly commercial or land
      return PropertyType.residential;
    }
  }
}
