import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../../domain/entities/favorite_unit.dart';
import '../../domain/entities/property_model.dart';
import '../providers/lead_provider.dart';
import '../providers/saved_units_provider.dart';
import '../widgets/common/app_loader_widget.dart';
import '../widgets/favorites/favorite_unit_card.dart';
import 'property_details_page.dart';

/// Favorites screen with two API-backed tabs:
///   • Saved      -> GET /buyer/saved-units
///   • Interested -> GET /buyer/leads
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    // Refresh both lists whenever the screen is shown.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SavedUnitsProvider>().reload();
      context.read<LeadProvider>().reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundWhite,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppStrings.favorites,
              style: themeManager.headingStyle
                  .copyWith(color: AppColors.textPrimaryDark),
            ),
          ),
          bottom: TabBar(
            labelColor: AppColors.bluePrimary,
            unselectedLabelColor: AppColors.textGray70,
            indicatorColor: AppColors.bluePrimary,
            indicatorWeight: 3,
            labelStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            unselectedLabelStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Saved'),
              Tab(text: 'Interested'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SavedTab(),
            _InterestedTab(),
          ],
        ),
      ),
    );
  }
}

/// Opens the property that a favorite unit belongs to. The details page
/// re-fetches the full project from the API using this id, so only the id
/// needs to be real — the rest are just placeholders until that load completes.
void _openProperty(BuildContext context, FavoriteUnit unit) {
  if (unit.projectId.isEmpty) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PropertyDetailsPage(
        property: PropertyModel(
          id: unit.projectId,
          title: unit.projectName.isNotEmpty ? unit.projectName : unit.title,
          location: unit.location,
          imageUrl: unit.imageUrl ?? '',
        ),
      ),
    ),
  );
}

class _SavedTab extends StatelessWidget {
  const _SavedTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavedUnitsProvider>();
    if (provider.isLoading && provider.saved.isEmpty) {
      return const Center(child: AppLoaderWidget());
    }
    if (provider.saved.isEmpty) {
      return const _EmptyState(
        icon: Icons.bookmark_border,
        title: 'No saved units yet',
        subtitle: 'Tap the bookmark on a unit to save it here.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<SavedUnitsProvider>().reload(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: provider.saved.length,
        itemBuilder: (context, index) {
          final unit = provider.saved[index];
          return FavoriteUnitCard(
            unit: unit,
            actionIcon: Icons.bookmark,
            actionTooltip: 'Remove from favorites',
            actionBusy: provider.isBusy(unit.unitId),
            onAction: () => _remove(context, unit),
            onTap: () => _openProperty(context, unit),
          );
        },
      ),
    );
  }

  Future<void> _remove(BuildContext context, FavoriteUnit unit) async {
    final msg =
        await context.read<SavedUnitsProvider>().toggleSaved(unit.unitId);
    if (msg != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
  }
}

class _InterestedTab extends StatelessWidget {
  const _InterestedTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeadProvider>();
    if (provider.isLoading && provider.interests.isEmpty) {
      return const Center(child: AppLoaderWidget());
    }
    if (provider.interests.isEmpty) {
      return const _EmptyState(
        icon: Icons.favorite_border,
        title: 'No interests yet',
        subtitle: "Tap \"I'm Interested\" on a unit to see it here.",
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<LeadProvider>().reload(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: provider.interests.length,
        itemBuilder: (context, index) {
          final unit = provider.interests[index];
          return FavoriteUnitCard(
            unit: unit,
            actionLabel: AppStrings.dropInterest,
            actionBusy: provider.isBusy(unit.unitId),
            onAction: () => _dropInterest(context, unit),
            onTap: () => _openProperty(context, unit),
          );
        },
      ),
    );
  }

  Future<void> _dropInterest(BuildContext context, FavoriteUnit unit) async {
    final msg =
        await context.read<LeadProvider>().toggleInterest(unit.unitId);
    if (msg != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.borderGrayMedium),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textGray70),
            ),
          ],
        ),
      ),
    );
  }
}
