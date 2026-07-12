import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/buyer_offer.dart';

class BuyerOfferCard extends StatelessWidget {
  final BuyerOfferSummary offer;
  final VoidCallback? onTap;

  const BuyerOfferCard({super.key, required this.offer, this.onTap});

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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGrayLightNew),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundBlueVeryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_offer_outlined,
                    color: AppColors.bluePrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.projectName.isNotEmpty
                            ? offer.projectName
                            : 'Property offer',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (offer.unitLabel.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          offer.unitLabel,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGray70,
                          ),
                        ),
                      ],
                      if (offer.totalCost.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          offer.totalCost,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.bluePrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    OfferStatusChip(status: offer.status),
                    const SizedBox(height: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textGray70,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OfferStatusChip extends StatelessWidget {
  final String status;

  const OfferStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color color;
    String label;
    switch (s) {
      case 'sent':
        color = AppColors.bluePrimary;
        label = 'New offer';
        break;
      case 'viewed':
        color = AppColors.bluePrimary;
        label = 'Viewed';
        break;
      case 'accepted':
        color = AppColors.tokenPaidGreen;
        label = 'Accepted';
        break;
      case 'declined':
        color = AppColors.errorRed;
        label = 'Declined';
        break;
      case 'booked':
        color = AppColors.tokenPaidGreen;
        label = 'Booked';
        break;
      case 'cancelled':
        color = AppColors.textGray70;
        label = 'Cancelled';
        break;
      default:
        color = AppColors.textGray70;
        label = status.isEmpty ? 'Offer' : status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
