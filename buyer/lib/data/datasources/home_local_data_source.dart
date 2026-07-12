import '../../domain/entities/category_model.dart';
import '../../domain/entities/location_model.dart';
import '../../domain/entities/property_model.dart';
import '../../core/constants/app_string_constants.dart';

abstract class HomeLocalDataSource {
  Future<List<PropertyModel>> getFeaturedProperties();
  Future<List<CategoryModel>> getCategories();
  Future<List<PropertyModel>> getRecommendedProperties();
  Future<List<PropertyModel>> getNearbyProperties();
  Future<List<PropertyModel>> getPopularProperties();
  Future<List<LocationModel>> getTopLocations();
  Future<List<PropertyModel>> getFavorites();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  Future<List<PropertyModel>> getFeaturedProperties() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const PropertyModel(
        id: '1',
        title: 'Prithvi Towers Residential',
        location: 'Puppalaguda, West Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1568605114967-8130f3a36994',
        isFeatured: true,
        facing: 'East',
        sftArea: '1850',
        unitType: 'Apartment',
        hasPayment: true,
        nextPaymentAmount: '₹12,45,000',
        dueDate: 'Dec 25, 2025',
        propertyType: 'residential',
      ),
      const PropertyModel(
        id: '2',
        title: 'Signature Altius Residential',
        location: 'Kollur, West Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1570129477492-45c003edd2be',
        isFeatured: true,
        propertyType: 'residential',
      ),
      const PropertyModel(
        id: '12',
        title: 'Tech Park Commercial Office',
        location: 'HITEC City, Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c',
        isFeatured: true,
        propertyType: 'commercial',
      ),
      const PropertyModel(
        id: '13',
        title: 'Prime Commercial Shop',
        location: 'Banjara Hills, Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1497366754035-f200968a6e72',
        isFeatured: true,
        propertyType: 'commercial',
      ),
      const PropertyModel(
        id: '14',
        title: 'Green Valley Land Plot',
        location: 'Gachibowli, Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef',
        isFeatured: true,
        propertyType: 'land',
      ),
    ];
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const CategoryModel(id: '1', name: "Apartment"),
      const CategoryModel(id: '2', name: "Flat"),
      const CategoryModel(id: '3', name: "Villa"),
      const CategoryModel(id: '4', name: "Loft"),
    ];
  }

  @override
  Future<List<PropertyModel>> getRecommendedProperties() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      PropertyModel(
        id: '3',
        title: 'Ayana Residential Villa',
        location: 'Imogiri, Yogyakarta',
        imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
        propertyType: 'residential',
      ),
      PropertyModel(
        id: '4',
        title: 'Bali Komang Guest House',
        location: 'Nusa Penida, Bali',
        imageUrl: 'https://images.unsplash.com/photo-1613490493576-7fde63acd811',
        propertyType: 'residential',
      ),
      PropertyModel(
        id: '15',
        title: 'Metro Commercial Complex',
        location: 'Jubilee Hills, Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab',
        propertyType: 'commercial',
      ),
      PropertyModel(
        id: '16',
        title: 'Sunset Land Development',
        location: 'Kokapet, Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef',
        propertyType: 'land',
      ),
    ];
  }

  @override
  Future<List<PropertyModel>> getNearbyProperties() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      PropertyModel(
        id: '5',
        title: 'Maharani Residential Villa',
        location: 'Benhi, Jl. Bendungan Hilir Karet...',
        imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        propertyType: 'residential',
      ),
      PropertyModel(
        id: '6',
        title: 'Premium Residential Apartment',
        location: 'Jl. Tentara Pelajar...',
        imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
        propertyType: 'residential',
      ),
      PropertyModel(
        id: '17',
        title: 'Business Hub Commercial Office',
        location: 'Financial District, Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c',
        propertyType: 'commercial',
      ),
      PropertyModel(
        id: '18',
        title: 'Retail Commercial Space',
        location: 'Madhapur, Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1497366754035-f200968a6e72',
        propertyType: 'commercial',
      ),
      PropertyModel(
        id: '19',
        title: 'Agricultural Land Plot',
        location: 'Shamshabad, Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef',
        propertyType: 'land',
      ),
      PropertyModel(
        id: '20',
        title: 'Residential Land Development',
        location: 'Miyapur, Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef',
        propertyType: 'land',
      ),
    ];
  }

  @override
  Future<List<PropertyModel>> getPopularProperties() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      PropertyModel(
        id: '7',
        title: 'Takatea Residential Homestay',
        location: 'Jl. Tentara Pelajar No.47, RW.01',
        imageUrl: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c',
        propertyType: 'residential',
      ),
      PropertyModel(
        id: '8',
        title: 'Maharani Residential Villa',
        location: 'Benhi, Jl. Bendungan Hilir Karet...',
        imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        propertyType: 'residential',
      ),
      PropertyModel(
        id: '9',
        title: 'Bali Komang Guest House',
        location: 'Nusa Penida, Bali',
        imageUrl: 'https://images.unsplash.com/photo-1613490493576-7fde63acd811',
        propertyType: 'residential',
      ),
      PropertyModel(
        id: '10',
        title: 'Batavia Residential Apartments',
        location: 'Benhi, Jl. Bendungan Hilir Karet...',
        imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
        propertyType: 'residential',
      ),
      PropertyModel(
        id: '11',
        title: 'Manhattan Commercial Hotel',
        location: 'Jl. Prof. DR. Satrio No.Kav.19-24',
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945',
        propertyType: 'commercial',
      ),
      PropertyModel(
        id: '21',
        title: 'Luxury Residential Villa',
        location: 'Banjara Hills, Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        propertyType: 'residential',
      ),
      PropertyModel(
        id: '22',
        title: 'Corporate Commercial Tower',
        location: 'HITEC City, Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab',
        propertyType: 'commercial',
      ),
      PropertyModel(
        id: '23',
        title: 'Investment Land Plot',
        location: 'Kokapet, Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef',
        propertyType: 'land',
      ),
    ];
  }

  @override
  Future<List<LocationModel>> getTopLocations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const LocationModel(
        id: '1',
        name: "Jubilee Hills",
        imageUrl: 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df',
      ),
      const LocationModel(
        id: '2',
        name: "Banjara Hills",
        imageUrl: 'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b',
      ),
      const LocationModel(
        id: '3',
        name: "Gachibowli",
        imageUrl: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000',
      ),
    ];
  }

  @override
  Future<List<PropertyModel>> getFavorites() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Return empty list for empty state, or populated list for favorites
    // You can toggle this to test both states
    return const [
      PropertyModel(
        id: 'fav1',
        title: 'The White Gloves',
        location: 'Banjarahills, Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1568605114967-8130f3a36994',
        isFeatured: true,
        propertyType: 'residential',
      ),
      PropertyModel(
        id: 'fav2',
        title: 'Modern Villa',
        location: 'Gachibowli, Hyderabad',
        imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        isFeatured: false,
        propertyType: 'residential',
      ),
    ];
    // // Uncomment below to test empty state:
    // return [];
  }
}
