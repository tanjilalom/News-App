import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_scraping_with_flutter/core/config/portals.dart';
import 'package:web_scraping_with_flutter/core/theme/app_theme.dart';
import 'package:web_scraping_with_flutter/core/widgets/portal_app_bar.dart';
import 'package:web_scraping_with_flutter/features/pages/bajus_prices_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/banglanews24_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/banglatribune_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/bdnews24_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/business_standard_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/daily_star_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/dailyinqilab_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/dhakapost_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/dhakatribune_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/ittefaq_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/jagonews24_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/jugantor_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/kalerkontho_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/manabzamin_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/newagebd_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/prothomalo_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/samakal_news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/somoynews_news_screen.dart';
import 'package:web_scraping_with_flutter/features/providers/news_providers.dart';
import 'package:web_scraping_with_flutter/features/search_screen.dart';

// ─── Page builder registry ───────────────────────────────────────────────────

final Map<String, WidgetBuilder> _pageBuilders = {
  'bajus': (_) => const BajusRateScreen(),
  'kalerkantho': (_) => const KalerKonthoNewsScreen(),
  'prothomalo': (_) => const ProthomAloNewsScreen(),
  'banglanews24': (_) => const BanglaNews24Screen(),
  'ittefaq': (_) => const IttefaqNewsScreen(),
  'tbsnews': (_) => const TBSNewsScreen(),
  'jugantor': (_) => const JugantorNewsScreen(),
  'samakal': (_) => const SamakalNewsScreen(),
  'manabzamin': (_) => const ManabzaminNewsScreen(),
  'bdnews24': (_) => const Bdnews24Screen(),
  'jagonews24': (_) => const JagoNews24Screen(),
  'somoynews': (_) => const SomoyNewsScreen(),
  'banglatribune': (_) => const BanglaTribuneScreen(),
  'dhakapost': (_) => const DhakaPostScreen(),
  'dailyinqilab': (_) => const DailyInqilabScreen(),
  'dailystar': (_) => const DailyStarNewsScreen(),
  'dhakatribune': (_) => const DhakaTribuneScreen(),
  'newagebd': (_) => const NewAgeScreen(),
};

// ─── HomePage ─────────────────────────────────────────────────────────────────

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  PortalCategory _selectedCategory = PortalCategory.all;
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

  List<PortalConfig> get _filteredPortals =>
      PortalRegistry.byCategory(_selectedCategory);

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

  void _openSearch() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => const SearchScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          return FadeTransition(opacity: fade, child: child);
        },
      ),
    );
  }

  void _toggleTheme() {
    final current = ref.read(themeModeProvider);
    ref.read(themeModeProvider.notifier).state =
        current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final portals = _filteredPortals;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
            ),
            onPressed: _toggleTheme,
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: _openSearch,
            tooltip: 'Search all portals',
          ),
        ],
      ),
      body: Column(
        children: [
          FadeTransition(
            opacity: _headerFade,
            child: _HeroHeader(totalPortals: PortalRegistry.all.length),
          ),
          _CategoryFilterRow(
            selected: _selectedCategory,
            onChanged: (c) => setState(() => _selectedCategory = c),
          ),
          Expanded(
            child: portals.isEmpty
                ? _EmptyCategory(category: _selectedCategory)
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.92,
                    ),
                    itemCount: portals.length,
                    itemBuilder: (context, index) {
                      final entry = portals[index];
                      return _PortalCard(
                        entry: entry,
                        index: index,
                        onTap: () {
                          final builder = _pageBuilders[entry.id];
                          if (builder != null) {
                            _navigateWithSlide(context, builder(context));
                          }
                        },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    color: Colors.white.withValues(alpha: isDark ? 0.9 : 0.75),
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
                    color: Colors.white.withValues(alpha: isDark ? 0.8 : 0.6),
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
                    color: Colors.white.withValues(
                        alpha: isDark ? 0.85 : 0.65),
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

  final PortalCategory selected;
  final ValueChanged<PortalCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).cardColor;
    final divider = Theme.of(context).dividerColor;

    return SizedBox(
      height: 52,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: PortalCategory.values.map((cat) {
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
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(cat.label),
                  ],
                ),
                labelStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                backgroundColor: surface,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.transparent,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : divider,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: isSelected ? 2 : 0,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
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

  final PortalConfig entry;
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
                      child: Icon(entry.icon, color: Colors.white, size: 24),
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
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 10, color: Colors.white),
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

  final PortalCategory category;

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
