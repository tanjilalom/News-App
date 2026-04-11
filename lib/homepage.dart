import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_scraping_with_flutter/core/theme/app_theme.dart';
import 'package:web_scraping_with_flutter/core/widgets/portal_app_bar.dart';
import 'package:web_scraping_with_flutter/features/pages/bajus_prices_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/banglanews24_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/business_standard_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/daily_star_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/ittefaq_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/jugantor_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/kalerkontho_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/manabzamin_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/prothomalo_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/samakal_news_screen.dart';

// ─── Category enum ──────────────────────────────────────────────────────────

enum _Category { all, bangla, english, finance }

extension _CategoryLabel on _Category {
  String get label {
    switch (this) {
      case _Category.all:
        return 'All';
      case _Category.bangla:
        return 'বাংলা';
      case _Category.english:
        return 'English';
      case _Category.finance:
        return 'Finance';
    }
  }

  IconData get icon {
    switch (this) {
      case _Category.all:
        return Icons.grid_view_rounded;
      case _Category.bangla:
        return Icons.language_rounded;
      case _Category.english:
        return Icons.abc_rounded;
      case _Category.finance:
        return Icons.monetization_on_rounded;
    }
  }
}

// ─── Portal entry model ──────────────────────────────────────────────────────

class _PortalEntry {
  const _PortalEntry({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.category,
    required this.pageBuilder,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final _Category category;
  final WidgetBuilder pageBuilder;
}

// ─── Portal registry ─────────────────────────────────────────────────────────

const List<_PortalEntry> _allPortals = [
  // Finance
  _PortalEntry(
    title: 'Bajus Gold & Silver',
    description: 'Live gold & silver prices',
    icon: Icons.monetization_on_rounded,
    gradientColors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    category: _Category.finance,
    pageBuilder: _buildBajusPage,
  ),
  // Bangla news
  _PortalEntry(
    title: 'Kaler Kantho',
    description: 'কালের কণ্ঠ — Latest from RSS',
    icon: Icons.newspaper_rounded,
    gradientColors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    category: _Category.bangla,
    pageBuilder: _buildKalerKonthoPage,
  ),
  _PortalEntry(
    title: 'Prothom Alo',
    description: 'প্রথম আলো — Top stories',
    icon: Icons.article_rounded,
    gradientColors: [Color(0xFFE51A1B), Color(0xFFC62828)],
    category: _Category.bangla,
    pageBuilder: _buildProthomAloPage,
  ),
  _PortalEntry(
    title: 'Bangla News 24',
    description: 'বাংলানিউজ২৪ — Breaking news',
    icon: Icons.rss_feed_rounded,
    gradientColors: [Color(0xFF1E88E5), Color(0xFF00ACC1)],
    category: _Category.bangla,
    pageBuilder: _buildBanglaNews24Page,
  ),
  _PortalEntry(
    title: 'Ittefaq',
    description: 'ইত্তেফাক — Latest news',
    icon: Icons.feed_rounded,
    gradientColors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
    category: _Category.bangla,
    pageBuilder: _buildIttefaqPage,
  ),
  _PortalEntry(
    title: 'TBS News বাংলা',
    description: 'The Business Standard',
    icon: Icons.business_center_rounded,
    gradientColors: [Color(0xFF059669), Color(0xFF065F46)],
    category: _Category.bangla,
    pageBuilder: _buildTbsPage,
  ),
  _PortalEntry(
    title: 'Jugantor',
    description: 'যুগান্তর — National & World',
    icon: Icons.public_rounded,
    gradientColors: [Color(0xFF0066CC), Color(0xFF0044AA)],
    category: _Category.bangla,
    pageBuilder: _buildJugantorPage,
  ),
  _PortalEntry(
    title: 'Samakal',
    description: 'সমকাল — Current affairs',
    icon: Icons.newspaper_rounded,
    gradientColors: [Color(0xFF00897B), Color(0xFF00695C)],
    category: _Category.bangla,
    pageBuilder: _buildSamakalPage,
  ),
  _PortalEntry(
    title: 'Manabzamin',
    description: 'মানবজমিন — In-depth news',
    icon: Icons.article_rounded,
    gradientColors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
    category: _Category.bangla,
    pageBuilder: _buildManabzaminPage,
  ),
  // English news
  _PortalEntry(
    title: 'The Daily Star',
    description: 'English — Top stories',
    icon: Icons.star_rounded,
    gradientColors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
    category: _Category.english,
    pageBuilder: _buildDailyStarPage,
  ),
];

// ─── Page builder functions ───────────────────────────────────────────────────

Widget _buildBajusPage(BuildContext context) => const BajusRateScreen();
Widget _buildKalerKonthoPage(BuildContext context) =>
    const KalerKonthoNewsScreen();
Widget _buildProthomAloPage(BuildContext context) =>
    const ProthomAloNewsScreen();
Widget _buildBanglaNews24Page(BuildContext context) =>
    const BanglaNews24Screen();
Widget _buildIttefaqPage(BuildContext context) => const IttefaqNewsScreen();
Widget _buildTbsPage(BuildContext context) => const TBSNewsScreen();
Widget _buildJugantorPage(BuildContext context) => const JugantorNewsScreen();
Widget _buildSamakalPage(BuildContext context) => const SamakalNewsScreen();
Widget _buildManabzaminPage(BuildContext context) =>
    const ManabzaminNewsScreen();
Widget _buildDailyStarPage(BuildContext context) => const DailyStarNewsScreen();

// ─── HomePage ─────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  _Category _selectedCategory = _Category.all;
  late final AnimationController _headerController;
  late final Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  List<_PortalEntry> get _filteredPortals => _selectedCategory == _Category.all
      ? _allPortals
      : _allPortals
          .where((p) => p.category == _selectedCategory)
          .toList(growable: false);

  void _navigateWithSlide(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final slide = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
          return SlideTransition(position: slide, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final portals = _filteredPortals;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PortalAppBar(
        title: Text(
          'BD News Hub',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        subtitle: const Text('আপনার সংবাদ কেন্দ্র'),
      ),
      body: Column(
        children: [
          // ── Hero header ──────────────────────────────────────────────
          FadeTransition(
            opacity: _headerFade,
            child: _HeroHeader(totalPortals: _allPortals.length),
          ),

          // ── Category filter chips ────────────────────────────────────
          _CategoryFilterRow(
            selected: _selectedCategory,
            onChanged: (c) => setState(() => _selectedCategory = c),
          ),

          // ── Portal grid ──────────────────────────────────────────────
          Expanded(
            child: portals.isEmpty
                ? _EmptyCategory(category: _selectedCategory)
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.92,
                    ),
                    itemCount: portals.length,
                    itemBuilder: (context, index) {
                      return _PortalCard(
                        entry: portals[index],
                        index: index,
                        onTap: () => _navigateWithSlide(
                          context,
                          portals[index].pageBuilder(context),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero header ─────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.totalPortals});

  final int totalPortals;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dateStr = '${months[now.month - 1]} ${now.day}, ${now.year}';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3366FF).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_greeting()}, Reader!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stay Informed Today',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateStr,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '$totalPortals',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00CCFF),
                    height: 1,
                  ),
                ),
                Text(
                  'Portals',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

// ─── Category filter row ──────────────────────────────────────────────────────

class _CategoryFilterRow extends StatelessWidget {
  const _CategoryFilterRow({
    required this.selected,
    required this.onChanged,
  });

  final _Category selected;
  final ValueChanged<_Category> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: _Category.values.map((cat) {
          final isSelected = cat == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.icon,
                      size: 14,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(cat.label),
                  ],
                ),
                labelStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                backgroundColor: Colors.white,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.transparent,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.divider,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: isSelected ? 2 : 0,
                shadowColor:
                    AppColors.primary.withValues(alpha: 0.3),
                onSelected: (_) => onChanged(cat),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Portal card ──────────────────────────────────────────────────────────────

class _PortalCard extends StatefulWidget {
  const _PortalCard({
    required this.entry,
    required this.index,
    required this.onTap,
  });

  final _PortalEntry entry;
  final int index;
  final VoidCallback onTap;

  @override
  State<_PortalCard> createState() => _PortalCardState();
}

class _PortalCardState extends State<_PortalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _entranceAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Entrance stagger animation
    _entranceAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 1, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _controller.forward();
    });
    _controller.value = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.reverse();
  void _onTapUp(TapUpDetails _) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final gradient = entry.gradientColors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Opacity(
        opacity: _entranceAnim.value,
        child: Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.last.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circle
              Positioned(
                right: -18,
                top: -18,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: -30,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        entry.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      entry.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.description,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Open',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory({required this.category});

  final _Category category;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No portals in "${category.label}"',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
