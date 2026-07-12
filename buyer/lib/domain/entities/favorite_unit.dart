/// A unit-level item shown in the Favorites screen — used for both the
/// "Saved" tab (GET /buyer/saved-units) and the "Interested" tab
/// (GET /buyer/leads). Both endpoints return the same shape of enriched
/// unit + project data, so one entity serves both.
class FavoriteUnit {
  final String unitId;
  final String projectId; // used to open the property details page
  final String title; // property/unit title, falls back to project name
  final String projectName;
  final String location; // "locality, city"
  final String unitNumber;
  final String unitType; // flat / plot / office ... (may be empty)
  final String priceLabel; // formatted ₹, may be empty
  final String? imageUrl; // cover image, may be null
  final String statusLabel; // "Available" / "Routing" ... (prettified)
  final bool isAvailable;

  const FavoriteUnit({
    required this.unitId,
    required this.projectId,
    required this.title,
    required this.projectName,
    required this.location,
    required this.unitNumber,
    required this.unitType,
    required this.priceLabel,
    required this.imageUrl,
    required this.statusLabel,
    required this.isAvailable,
  });
}
