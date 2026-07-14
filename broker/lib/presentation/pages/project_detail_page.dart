import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/di/injection_container.dart';
import '../../data/models/broker_project_model.dart';
import '../../data/models/broker_unit_model.dart';
import '../providers/project_detail_provider.dart';
import '../providers/projects_provider.dart';
import 'unit_detail_page.dart';

const Color _alignedGreen = Color(0xFF12B76A);
const Color _alignedGreenBg = Color(0xFFE7F8F0);
const Color _pausedAmber = Color(0xFFB54708);
const Color _pausedAmberBg = Color(0xFFFFF4E5);
const Color _pendingBlue = Color(0xFF1570EF);
const Color _pendingBlueBg = Color(0xFFEFF4FF);

/// Canonical public URL for a project, on the buyer website.
String _projectShareUrl(String projectId) =>
    'https://buyer.demo.paysft.com/projects/$projectId';

/// Opens the OS native share sheet with the project's public link.
Future<void> _shareProject(BuildContext context, BrokerProjectModel project) async {
  final url = _projectShareUrl(project.id);
  final where = project.location.isEmpty ? '' : ' — ${project.location}';
  final box = context.findRenderObject() as RenderBox?;
  await Share.share(
    '${project.name}$where\n$url',
    subject: project.name,
    sharePositionOrigin:
        box != null ? box.localToGlobal(Offset.zero) & box.size : null,
  );
}

class ProjectDetailPage extends StatelessWidget {
  final BrokerProjectModel seed;
  const ProjectDetailPage({super.key, required this.seed});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<ProjectDetailProvider>()..load(seed.id, seed: seed),
      child: const _ProjectDetailView(),
    );
  }
}

class _ProjectDetailView extends StatelessWidget {
  const _ProjectDetailView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectDetailProvider>();
    final project = provider.project;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1D2939)),
        title: Text(
          project?.name ?? 'Project',
          style: const TextStyle(
            color: Color(0xFF1D2939),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (project != null)
            IconButton(
              tooltip: 'Share',
              icon: const Icon(Icons.share_outlined, color: Color(0xFF1D2939)),
              onPressed: () => _shareProject(context, project),
            ),
        ],
      ),
      bottomNavigationBar:
          project == null ? null : _ContactBar(project: project),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, ProjectDetailProvider provider) {
    final project = provider.project;

    if (project == null) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            provider.errorMessage ?? 'Could not load project details.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textGray70, fontSize: 14),
          ),
        ),
      );
    }

    final images = _imageUrls(provider, project);

    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle:
                NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              automaticallyImplyLeading: false,
              primary: false,
              backgroundColor: AppColors.backgroundWhite,
              elevation: 0,
              pinned: true,
              toolbarHeight: 0,
              // carousel (230) + header (~130) + contact card (~86) + room for
              // the pinned TabBar (46) so nothing collides with it.
              expandedHeight: 500,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Carousel(images: images),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: _Header(project: project),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: _ContactCard(project: project),
                    ),
                  ],
                ),
              ),
              bottom: const TabBar(
                labelColor: AppColors.bluePrimary,
                unselectedLabelColor: Color(0xFF667085),
                indicatorColor: AppColors.bluePrimary,
                labelStyle:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: 'Description'),
                  Tab(text: 'Units'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          children: [
            _DescriptionTab(project: project, provider: provider),
            _UnitsTab(provider: provider),
          ],
        ),
      ),
    );
  }

  /// Build the ordered list of image URLs: media images first, then the cover
  /// image as a fallback so the carousel always has something to show.
  List<String> _imageUrls(
      ProjectDetailProvider provider, BrokerProjectModel project) {
    final urls = provider.imageMedia
        .map((m) => m.url)
        .where((u) => u.isNotEmpty)
        .toList();
    if (urls.isEmpty &&
        project.coverImageUrl != null &&
        project.coverImageUrl!.isNotEmpty) {
      urls.add(project.coverImageUrl!);
    }
    return urls;
  }
}

class _Carousel extends StatefulWidget {
  final List<String> images;
  const _Carousel({required this.images});

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    if (images.isEmpty) {
      return _fallback();
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _ImageGridPage(images: images),
        ),
      ),
      child: SizedBox(
        height: 230,
        width: double.infinity,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => Image.network(
                images[i],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => _fallback(),
              ),
            ),
            // Count badge + expand hint.
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.grid_view_rounded,
                        size: 13, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      '${_index + 1}/${images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (images.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _index ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      height: 230,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blueGradientStart, AppColors.blueGradientEnd],
        ),
      ),
      child: const Center(
        child: Icon(Icons.apartment, color: AppColors.textWhite, size: 56),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final BrokerProjectModel project;
  const _Header({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.backgroundBlueSelectedVeryLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                project.typeLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bluePrimary,
                ),
              ),
            ),
            const Spacer(),
            _StatusPill(project: project),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.location_on_outlined,
                size: 18, color: AppColors.textGrayMedium),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                [project.locality, project.city, project.state]
                    .where((p) => p.isNotEmpty)
                    .join(', '),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGray80,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Aligned / Paused pill reflecting the broker's assignment to this project.
class _StatusPill extends StatelessWidget {
  final BrokerProjectModel project;
  const _StatusPill({required this.project});

  @override
  Widget build(BuildContext context) {
    final status =
        context.watch<ProjectsProvider>().assignmentStatusFor(project.id);
    if (status == null) return const SizedBox.shrink();
    final pending = status == 'pending';
    final paused = status == 'paused';
    final color = pending
        ? _pendingBlue
        : (paused ? _pausedAmber : _alignedGreen);
    final bg = pending
        ? _pendingBlueBg
        : (paused ? _pausedAmberBg : _alignedGreenBg);
    final icon = pending
        ? Icons.hourglass_top
        : (paused ? Icons.pause_circle_outline : Icons.check_circle);
    final label = pending ? 'Pending approval' : (paused ? 'Paused' : 'Aligned');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionTab extends StatelessWidget {
  final BrokerProjectModel project;
  final ProjectDetailProvider provider;
  const _DescriptionTab({required this.project, required this.provider});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    void addRow(String label, String? value) {
      if (value == null || value.isEmpty || value == '—') return;
      rows.add(_InfoRow(label: label, value: value));
    }

    addRow('Construction status', project.statusLabel);
    addRow('Project type', BrokerProjectModel.pretty(project.projectType));
    addRow('Total units', project.totalUnitsPlanned?.toString());
    addRow('Total area', project.totalAcres == null
        ? null
        : '${project.totalAcres} acres');
    addRow('Built-up area', project.totalBuiltUpAreaSqft == null
        ? null
        : '${project.totalBuiltUpAreaSqft} sqft');
    addRow('RERA number', project.reraProjectNumber);
    addRow('RERA state', project.reraProjectState);
    addRow('Pincode', project.pincode);
    addRow('Launch date', _date(project.launchDate));
    addRow('Possession', _date(project.possessionDate));

    final children = <Widget>[
      if ((project.tagline ?? '').isNotEmpty) ...[
        Text(
          project.tagline!,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: AppColors.bluePrimary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
      ],
      if (rows.isNotEmpty) ...[
        const _SectionTitle('Details'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderGrayMedium),
          ),
          child: Column(children: rows),
        ),
      ],
      if ((project.description ?? '').isNotEmpty) ...[
        const SizedBox(height: 20),
        const _SectionTitle('About this project'),
        const SizedBox(height: 8),
        Text(
          project.description!,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textGray80,
          ),
        ),
      ],
      if (project.amenities.isNotEmpty) ...[
        const SizedBox(height: 20),
        const _SectionTitle('Amenities'),
        const SizedBox(height: 10),
        _AmenityChips(amenities: project.amenities),
      ],
      if (project.placesNearby.isNotEmpty) ...[
        const SizedBox(height: 20),
        const _SectionTitle('Places nearby'),
        const SizedBox(height: 10),
        ...project.placesNearby.map((p) => _NearbyRow(place: p)),
      ],
      if (rows.isEmpty &&
          (project.description ?? '').isEmpty &&
          project.amenities.isEmpty &&
          (project.tagline ?? '').isEmpty &&
          project.placesNearby.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(
            child: Text(
              'No additional details available.',
              style: TextStyle(color: AppColors.textGray70, fontSize: 14),
            ),
          ),
        ),
    ];

    return CustomScrollView(
      key: const PageStorageKey('descriptionTab'),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverList(delegate: SliverChildListDelegate(children)),
        ),
      ],
    );
  }

  String? _date(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F1F3)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textGray70,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101828),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitsTab extends StatelessWidget {
  final ProjectDetailProvider provider;
  const _UnitsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final units = provider.units;
    final injector = SliverOverlapInjector(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
    );

    if (units.isEmpty) {
      return CustomScrollView(
        key: const PageStorageKey('unitsTab'),
        slivers: [
          injector,
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: provider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'No units published for this project yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textGray70, fontSize: 14),
                      ),
              ),
            ),
          ),
        ],
      );
    }

    final children = <Widget>[
      Text.rich(
        TextSpan(
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textGray70,
          ),
          children: [
            TextSpan(
              text: '${provider.availableUnitsCount} ',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _alignedGreen,
              ),
            ),
            TextSpan(text: 'available of ${units.length} units'),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ...units.map((u) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _UnitCard(
              unit: u,
              projectName: provider.project?.name ?? '',
            ),
          )),
    ];

    return CustomScrollView(
      key: const PageStorageKey('unitsTab'),
      slivers: [
        injector,
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverList(delegate: SliverChildListDelegate(children)),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF101828),
      ),
    );
  }
}

class _NearbyRow extends StatelessWidget {
  final NearbyPlace place;
  const _NearbyRow({required this.place});

  @override
  Widget build(BuildContext context) {
    final sub = [place.category, place.distance]
        .where((s) => s != null && s.isNotEmpty)
        .join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.backgroundBlueSelectedVeryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.place_outlined,
                size: 18, color: AppColors.bluePrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (sub.isNotEmpty)
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGray70,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenityChips extends StatelessWidget {
  final List<String> amenities;
  const _AmenityChips({required this.amenities});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amenities
          .map(
            (a) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.borderGrayMedium),
              ),
              child: Text(
                BrokerProjectModel.pretty(a),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGray80,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final BrokerUnitModel unit;
  final String projectName;
  const _UnitCard({required this.unit, required this.projectName});

  @override
  Widget build(BuildContext context) {
    final price = _formatInr(unit.totalPrice ?? unit.basePrice);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UnitDetailPage(unit: unit, projectName: projectName),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGrayMedium),
        ),
        child: Row(
          children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.backgroundBlueSelectedVeryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.meeting_room_outlined,
                color: AppColors.bluePrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.propertyTitle?.isNotEmpty == true
                      ? unit.propertyTitle!
                      : '${BrokerProjectModel.pretty(unit.unitType)} ${unit.unitNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  price ?? 'Price on request',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bluePrimary,
                  ),
                ),
              ],
            ),
          ),
            _statusBadge(unit.inventoryStatus, unit.isAvailable),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status, bool available) {
    final color = available ? _alignedGreen : _pausedAmber;
    final bg = available ? _alignedGreenBg : _pausedAmberBg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        BrokerProjectModel.pretty(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Formats a decimal-string price into a compact INR label.
  static String? _formatInr(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final value = double.tryParse(raw);
    if (value == null || value <= 0) return null;
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(2)} Cr';
    }
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)} L';
    }
    return '₹${value.toStringAsFixed(0)}';
  }
}

/// Full-screen grid of all project images. Tapping one opens the large viewer.
class _ImageGridPage extends StatelessWidget {
  final List<String> images;
  const _ImageGridPage({required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1D2939)),
        title: Text(
          'Photos (${images.length})',
          style: const TextStyle(
            color: Color(0xFF1D2939),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: images.length,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    _ImageViewerPage(images: images, initialIndex: i),
              ),
            ),
            child: Hero(
              tag: 'project_img_$i',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  images[i],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.borderGrayLight,
                    child: const Icon(Icons.broken_image_outlined,
                        color: AppColors.textGrayMedium),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Full-screen swipeable, zoomable image viewer.
class _ImageViewerPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const _ImageViewerPage({required this.images, required this.initialIndex});

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Hero(
                    tag: 'project_img_$i',
                    child: Image.network(
                      widget.images[i],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_index + 1} / ${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Builder contact card (avatar, name, call / chat). Contact details aren't yet
/// exposed by the broker API, so the name/role are placeholders pending a
/// backend field; the call/chat actions are stubbed.
class _ContactCard extends StatelessWidget {
  final BrokerProjectModel project;
  const _ContactCard({required this.project});

  // DUMMY — no builder-contact endpoint exists yet.
  static const String _builderName = 'Sales Desk';
  static const String _builderRole = 'Builder';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bluePrimary.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.backgroundBlueSelectedVeryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.bluePrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  _builderName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  _builderRole,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGray70,
                  ),
                ),
              ],
            ),
          ),
          _circleIcon(Icons.call, () => _stub(context, 'Call')),
          const SizedBox(width: 10),
          _circleIcon(Icons.chat_bubble_outline, () => _stub(context, 'Chat')),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: AppColors.backgroundBlueSelectedVeryLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.bluePrimary),
      ),
    );
  }

  void _stub(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what builder — coming soon')),
    );
  }
}

/// Bottom bar: contact the builder or request a site visit.
class _ContactBar extends StatelessWidget {
  final BrokerProjectModel project;
  const _ContactBar({required this.project});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          border: Border(top: BorderSide(color: AppColors.borderGrayMedium)),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _stub(context, 'Contact builder'),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Contact Builder'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.bluePrimary,
                    side: const BorderSide(color: AppColors.bluePrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _stub(context, 'Site visit'),
                  icon: const Icon(Icons.event_available_outlined, size: 18),
                  label: const Text('Site Visit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bluePrimary,
                    foregroundColor: AppColors.textWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _stub(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what — coming soon')),
    );
  }
}
