import 'package:equatable/equatable.dart';

/// Buyer profile returned by GET /buyer/me.
class BuyerProfile extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? mobile;
  final String? avatarUrl;
  final String? pan;
  final String? address;
  final String? nationality;
  final String? countryOfResidence;
  final String? preferredLocationId;
  final String? preferredCityId;
  final bool emailVerified;
  final bool mobileVerified;
  final bool isActive;

  const BuyerProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.mobile,
    this.avatarUrl,
    this.pan,
    this.address,
    this.nationality,
    this.countryOfResidence,
    this.preferredLocationId,
    this.preferredCityId,
    this.emailVerified = false,
    this.mobileVerified = false,
    this.isActive = true,
  });

  factory BuyerProfile.fromJson(Map<String, dynamic> json) {
    String? str(dynamic v) => v == null ? null : '$v';
    return BuyerProfile(
      id: str(json['id']) ?? '',
      email: str(json['email']) ?? '',
      fullName: str(json['full_name']) ?? '',
      mobile: str(json['mobile']),
      avatarUrl: str(json['avatar_url']),
      pan: str(json['pan']),
      address: str(json['address']),
      nationality: str(json['nationality']),
      countryOfResidence: str(json['country_of_residence']),
      preferredLocationId: str(json['preferred_location_id']),
      preferredCityId: str(json['preferred_city_id']),
      emailVerified: json['email_verified_at'] != null,
      mobileVerified: json['mobile_verified_at'] != null,
      isActive: json['is_active'] == true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        mobile,
        avatarUrl,
        pan,
        address,
        nationality,
        countryOfResidence,
        preferredLocationId,
        preferredCityId,
        emailVerified,
        mobileVerified,
        isActive,
      ];
}
