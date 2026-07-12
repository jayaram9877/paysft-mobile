import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/favorite_unit.dart';

/// Card used in both Favorites tabs (Saved + Interested). Shows the enriched
/// unit/project data returned by the API with a trailing or labeled action.
class FavoriteUnitCard extends StatelessWidget {
  final FavoriteUnit unit;
  final IconData? actionIcon;
  final String? actionTooltip;
  final String? actionLabel;
  final bool actionBusy;
  final VoidCallback? onAction;
  final VoidCallback? onTap;

  const FavoriteUnitCard({
    super.key,
    required this.unit,
    this.actionIcon,
    this.actionTooltip,
    this.actionLabel,
    this.actionBusy = false,
    this.onAction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Material(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGrayLightNew),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _thumbnail(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (unit.location.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 14, color: AppColors.textGray70),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    unit.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13, color: AppColors.textGray70),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (unit.priceLabel.isNotEmpty)
                                Text(
                                  unit.priceLabel,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.bluePrimary,
                                  ),
                                ),
                              if (unit.statusLabel.isNotEmpty) _statusChip(unit),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (actionLabel == null) ...[
                      const SizedBox(width: 6),
                      _iconActionButton(),
                    ],
                  ],
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: 12),
                  _labeledActionButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _thumbnail() {
    const size = 64.0;
    final img = unit.imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: (img != null && img.isNotEmpty)
            ? Image.network(
                img,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _thumbPlaceholder(),
              )
            : _thumbPlaceholder(),
      ),
    );
  }

  Widget _thumbPlaceholder() => Container(
        color: AppColors.backgroundBlueVeryLight,
        child: const Icon(Icons.apartment_rounded,
            color: AppColors.bluePrimary, size: 28),
      );

  Widget _statusChip(FavoriteUnit u) {
    final available = u.isAvailable;
    final bg = (available ? AppColors.tokenPaidGreen : AppColors.textGray70)
        .withValues(alpha: 0.12);
    final fg = available ? AppColors.tokenPaidGreen : AppColors.textGray70;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        u.statusLabel,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _iconActionButton() {
    if (actionBusy) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return IconButton(
      icon: Icon(actionIcon, color: AppColors.textGray70),
      tooltip: actionTooltip,
      onPressed: onAction,
    );
  }

  Widget _labeledActionButton() {
    return SizedBox(
      height: 42,
      child: OutlinedButton(
        onPressed: actionBusy ? null : onAction,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.errorRed,
          side: const BorderSide(color: AppColors.errorRed),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: actionBusy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
