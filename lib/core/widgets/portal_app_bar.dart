import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PortalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PortalAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    this.bottom,
    this.gradientColors = const <Color>[
      Color(0xFF3366FF),
      Color(0xFF00CCFF),
    ],
  });

  final Widget title;
  final Widget? subtitle;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;
  final List<Color> gradientColors;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight +
            (subtitle != null ? 20 : 0) +
            (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: subtitle != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                title,
                DefaultTextStyle(
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  child: subtitle!,
                ),
              ],
            )
          : title,
      centerTitle: true,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}
