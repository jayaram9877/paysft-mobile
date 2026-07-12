import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/di/injection_container.dart' as di;
import '../providers/agent_profile_provider.dart';
import '../widgets/agent/agent_header_card.dart';
import '../widgets/common/property_category_tab_bar.dart';
import '../widgets/favorites/favorite_property_card_widget.dart';
import '../../domain/entities/property_details_model.dart';
import '../../core/utils/property_utils.dart';
import 'property_details_page.dart';
import 'land_details_page.dart';
import 'commercial_details_page.dart';

class AgentProfilePage extends StatefulWidget {
  final AgentModel agent;

  /// Key for the category tab bar wrapper used in tests.
  static const Key categoryChipsKey = Key('agent_profile_category_chips');

  const AgentProfilePage({super.key, required this.agent});

  @override
  State<AgentProfilePage> createState() => _AgentProfilePageState();
}

class _AgentProfilePageState extends State<AgentProfilePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AgentProfileProvider>(
      create: (_) => di.sl<AgentProfileProvider>()..setAgent(widget.agent),
      child: Consumer<AgentProfileProvider>(
        builder: (context, provider, _) {
          final themeManager = ThemeManager();

          return Scaffold(
            backgroundColor: AppColors.backgroundGray25,
            appBar: AppBar(
              backgroundColor: AppColors.backgroundGray25,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimaryDark,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                AppStrings.agentProfile,
                style: themeManager.titleMediumStyle,
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AgentHeaderCard(agent: widget.agent),
                ),
                _buildCategoryChips(provider),
                const SizedBox(height: 16),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.agentProperties.isEmpty
                      ? Center(child: Text(AppStrings.noPropertiesFound))
                      : _buildPropertiesList(provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips(AgentProfileProvider provider) {
    return SizedBox(
      key: AgentProfilePage.categoryChipsKey,
      height: 56,
      child: PropertyCategoryTabBar(
        tabs: provider.categories,
        selectedIndex: provider.selectedCategoryIndex,
        onTabChanged: provider.onCategoryChanged,
        themeManager: ThemeManager(),
      ),
    );
  }

  Widget _buildPropertiesList(AgentProfileProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 16),
      itemCount: provider.agentProperties.length,
      itemBuilder: (context, index) {
        final property = provider.agentProperties[index];
        return FavoritePropertyCardWidget(
          property: property,
          hideFavIcon: true,
          scrollableContent: false,
          onTap: () {
            Widget page;
            switch (PropertyUtils.getPropertyType(property)) {
              case PropertyType.land:
                page = LandDetailsPage(property: property);
                break;
              case PropertyType.commercial:
                page = CommercialDetailsPage(property: property);
                break;
              case PropertyType.residential:
              default:
                page = PropertyDetailsPage(property: property);
                break;
            }
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          },
        );
      },
    );
  }
}
