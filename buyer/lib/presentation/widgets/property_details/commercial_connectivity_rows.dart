import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:buyer/domain/entities/property_details_model.dart';
import 'package:flutter/material.dart';

class CommercialConnectivityRows extends StatelessWidget {
  final ConnectivityModel? connectivity;
  final ThemeManager themeManager;

  const CommercialConnectivityRows({
    super.key,
    required this.connectivity,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    final c = connectivity;
    if (c == null) return const SizedBox.shrink();

    final items = <MapEntry<String, String>>[
      if (c.metroStation.trim().isNotEmpty) MapEntry(AppStrings.metroStation, c.metroStation),
      if (c.majorRoad.trim().isNotEmpty) MapEntry(AppStrings.majorRoad, c.majorRoad),
      if (c.techParks.trim().isNotEmpty) MapEntry(AppStrings.techParks, c.techParks),
      if (c.airport.trim().isNotEmpty) MapEntry(AppStrings.airport, c.airport),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (final item in items) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.key,
                    style: themeManager.commercialConnectivityRowLabelStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.value,
                    style: themeManager.commercialConnectivityRowValueStyle,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

