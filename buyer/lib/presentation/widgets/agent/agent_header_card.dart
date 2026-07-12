import 'package:flutter/material.dart';
import '../../../domain/entities/property_details_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../../core/theme/theme_manager.dart';
import '../common/app_svg_icon.dart';

class AgentHeaderCard extends StatelessWidget {
  final AgentModel agent;
  static const Key agentStatsContainerKey = Key('agent_profile_stats_container');
  static const Key agentStatsDividerOneKey = Key('agent_profile_stats_divider_1');
  static const Key agentStatsDividerTwoKey = Key('agent_profile_stats_divider_2');

  const AgentHeaderCard({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhiteLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blue30, width: 1),
        boxShadow: themeManager.agentCardSectionBoxShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0, -10),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  key: const Key('agent_profile_avatar'),
                  width: 144,
                  height: 144,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.backgroundWhite, width: 2),
                    boxShadow: themeManager.agentAvatarBoxShadow,
                    image: DecorationImage(image: NetworkImage(agent.imageUrl), fit: BoxFit.cover),
                    color: AppColors.avatarPlaceholderGray,
                  ),
                ),
                Positioned(
                  bottom: -8,
                  right: 0,
                  left: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: AppSvgIcon(assetPath: 'assets/images/rera_protected.svg', width: 20, height: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(agent.name, textAlign: TextAlign.center, style: themeManager.agentCardNameStyle),
          const SizedBox(height: 20),
          _buildStatsSection(themeManager),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  iconPath: 'assets/images/agent_phone.svg',
                  label: AppStrings.makeACall,
                  onTap: () {}, // Handled in Provider/Page
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  context,
                  iconPath: 'assets/images/agent_chat.svg',
                  label: AppStrings.message,
                  onTap: () {}, // Handled in Provider/Page
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ThemeManager themeManager) {
    return Container(
      key: agentStatsContainerKey,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(themeManager: themeManager, value: '40', label: AppStrings.listings),
          ),
          Container(key: agentStatsDividerOneKey, width: 1, height: 52, color: AppColors.textGrayMedium),
          Expanded(
            child: _buildStatItem(themeManager: themeManager, value: '120', label: AppStrings.sold),
          ),
          Container(key: agentStatsDividerTwoKey, width: 1, height: 52, color: AppColors.textGrayMedium),
          Expanded(
            child: _buildStatItem(themeManager: themeManager, value: '50', label: AppStrings.conversions),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required ThemeManager themeManager, required String value, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: themeManager.agentProfileStatValueStyle),
        const SizedBox(height: 8),
        Text(label, style: themeManager.agentProfileStatLabelStyle),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    final themeManager = ThemeManager();
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.ultramarine10,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.ultramarine30, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppSvgIcon(assetPath: iconPath, width: 20, height: 20, color: AppColors.ultramarine90),
            const SizedBox(width: 8),
            Text(label, textAlign: TextAlign.center, style: themeManager.agentCardActionButtonTextStyle),
          ],
        ),
      ),
    );
  }
}
