/// Mirrors the API `BrokerProjectMediaResponse` — a media asset for a project.
class BrokerProjectMediaModel {
  final String id;
  final String mediaType; // image | video_file | video_youtube_link | floor_plan | master_plan | brochure_pdf
  final String mediaCategory;
  final String? title;
  final String? caption;
  final bool isPrimary;
  final int displayOrder;
  final String url;

  BrokerProjectMediaModel({
    required this.id,
    required this.mediaType,
    required this.mediaCategory,
    this.title,
    this.caption,
    required this.isPrimary,
    required this.displayOrder,
    required this.url,
  });

  bool get isImage => mediaType == 'image';

  static String? _s(dynamic v) => v?.toString();

  factory BrokerProjectMediaModel.fromJson(Map<String, dynamic> json) {
    return BrokerProjectMediaModel(
      id: _s(json['id']) ?? '',
      mediaType: _s(json['media_type']) ?? '',
      mediaCategory: _s(json['media_category']) ?? '',
      title: _s(json['title']),
      caption: _s(json['caption']),
      isPrimary: json['is_primary'] == true,
      displayOrder:
          json['display_order'] is int ? json['display_order'] as int : 0,
      url: _s(json['url']) ?? '',
    );
  }
}
