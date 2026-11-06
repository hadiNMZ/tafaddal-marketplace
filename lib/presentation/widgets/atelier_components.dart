import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Luxury Atelier Product Visual Card
/// Replaces generic grey placeholder boxes with bespoke editorial fashion aesthetics.
class AtelierProductVisual extends StatelessWidget {
  final String productName;
  final String category;
  final double height;
  final BorderRadius? borderRadius;

  const AtelierProductVisual({
    super.key,
    required this.productName,
    required this.category,
    this.height = 160,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getAestheticStyle(productName, category);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.maxHeight <= 80 || constraints.maxWidth <= 80;

        if (isCompact) {
          final iconSize = (constraints.maxHeight * 0.44).clamp(16.0, 24.0);
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: style.gradientColors,
              ),
              borderRadius: borderRadius ?? BorderRadius.circular(10),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: style.accentColor.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  style.iconData,
                  size: iconSize,
                  color: style.accentColor,
                ),
              ),
            ),
          );
        }

        return Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: style.gradientColors,
            ),
            borderRadius: borderRadius ?? BorderRadius.circular(14),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Subtle luxury texture arches
              CustomPaint(
                painter: _AtelierPatternPainter(
                  accentColor: style.accentColor.withValues(alpha: 0.12),
                ),
              ),

              // Central Couture Silhouette / Iconography
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: style.accentColor.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        style.iconData,
                        size: 26,
                        color: style.accentColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        style.fabricLabel,
                        style: GoogleFonts.tajawal(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.95),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Subtle Atelier Watermark Crest at top-left
              Positioned(
                bottom: 8,
                right: 8,
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 11,
                      color: style.accentColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'ATELIER TAFADDAL',
                      style: GoogleFonts.outfit(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _AestheticStyle _getAestheticStyle(String name, String cat) {
    final lower = name.toLowerCase();

    if (lower.contains('سهرة') || lower.contains('كريب') || lower.contains('فستان') || lower.contains('درابيه') || cat == 'فساتين') {
      return _AestheticStyle(
        gradientColors: [
          const Color(0xFF0D281E),
          const Color(0xFF1B4636),
          const Color(0xFF143026),
        ],
        accentColor: const Color(0xFFD8B983),
        iconData: Icons.dry_cleaning_outlined,
        fabricLabel: 'حرير كريب ملكي',
      );
    } else if (lower.contains('معطف') || lower.contains('صوف') || lower.contains('كشمير') || lower.contains('كاب') || lower.contains('جاكيت') || cat == 'معاطف') {
      return _AestheticStyle(
        gradientColors: [
          const Color(0xFF1A1C20),
          const Color(0xFF2C2F36),
          const Color(0xFF20232A),
        ],
        accentColor: const Color(0xFFE2C89D),
        iconData: Icons.shield_moon_outlined,
        fabricLabel: 'صوف كشمير نقي',
      );
    } else if (lower.contains('عباية') || lower.contains('قفطان') || lower.contains('مقصّب') || cat == 'عبايات') {
      return _AestheticStyle(
        gradientColors: [
          const Color(0xFF1E1724),
          const Color(0xFF2F243A),
          const Color(0xFF1B1421),
        ],
        accentColor: const Color(0xFFE6C488),
        iconData: Icons.auto_awesome_outlined,
        fabricLabel: 'حرير فاخر مطرز',
      );
    } else if (lower.contains('بدلة') || lower.contains('تويد') || lower.contains('تاكسيدو') || cat == 'بدلات') {
      return _AestheticStyle(
        gradientColors: [
          const Color(0xFF141E28),
          const Color(0xFF1F2E3D),
          const Color(0xFF162330),
        ],
        accentColor: const Color(0xFFD2B48C),
        iconData: Icons.checkroom_outlined,
        fabricLabel: 'تويد إنجليزي فاخر',
      );
    } else if (lower.contains('حذاء') || lower.contains('أوكسفورد') || cat == 'أحذية') {
      return _AestheticStyle(
        gradientColors: [
          const Color(0xFF2A1C14),
          const Color(0xFF3F2B20),
          const Color(0xFF2E1E16),
        ],
        accentColor: const Color(0xFFE8C89A),
        iconData: Icons.straighten_outlined,
        fabricLabel: 'جلد فينيسي طبيعي',
      );
    } else if (lower.contains('حقيبة') || lower.contains('شال') || lower.contains('جلد') || cat == 'حقائب') {
      return _AestheticStyle(
        gradientColors: [
          const Color(0xFF381F10),
          const Color(0xFF5A331B),
          const Color(0xFF422413),
        ],
        accentColor: const Color(0xFFF3D29E),
        iconData: Icons.shopping_bag_outlined,
        fabricLabel: 'جلد إيطالي أصيل',
      );
    }

    return _AestheticStyle(
      gradientColors: [
        const Color(0xFF1A2621),
        const Color(0xFF2A3C35),
        const Color(0xFF1E2E28),
      ],
      accentColor: const Color(0xFFC7A774),
      iconData: Icons.diamond_outlined,
      fabricLabel: 'إصدار فاخر حصري',
    );
  }
}

class _AestheticStyle {
  final List<Color> gradientColors;
  final Color accentColor;
  final IconData iconData;
  final String fabricLabel;

  _AestheticStyle({
    required this.gradientColors,
    required this.accentColor,
    required this.iconData,
    required this.fabricLabel,
  });
}

/// Artistic subtle filigree background painter for luxury depth
class _AtelierPatternPainter extends CustomPainter {
  final Color accentColor;
  _AtelierPatternPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw delicate concentric luxury arch arcs
    final center = Offset(size.width * 0.5, size.height * 0.45);
    for (double r = 40; r <= 100; r += 24) {
      canvas.drawCircle(center, r, paint);
    }

    // Corner decorative diamond marks
    final diamondPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(14, 14), 1.5, diamondPaint);
    canvas.drawCircle(Offset(size.width - 14, 14), 1.5, diamondPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Luxury Certified Atelier Emblem & Avatar
/// Displays a prestigious calligraphic seal for accredited fashion houses.
class AtelierStoreAvatar extends StatelessWidget {
  final String storeName;
  final bool isSelected;
  final double radius;
  final VoidCallback? onTap;

  const AtelierStoreAvatar({
    super.key,
    required this.storeName,
    this.isSelected = false,
    this.radius = 28,
    this.onTap,
  });

  String _getInitial(String name) {
    if (name.isEmpty) return 'ت';
    String clean = name
        .replaceFirst('متجر ', '')
        .replaceFirst('بوتيك ', '')
        .replaceFirst('دار ', '')
        .replaceFirst('أزياء ', '')
        .replaceFirst('مشغل ', '')
        .replaceFirst('أتيليه ', '')
        .trim();
    if (clean.startsWith('ال') && clean.length > 2) {
      clean = clean.substring(2);
    }
    return clean.isNotEmpty ? clean[0] : name[0];
  }

  @override
  Widget build(BuildContext context) {
    final initial = _getInitial(storeName);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius + 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                width: radius * 2,
                height: radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF143026),
                            Color(0xFF265444),
                          ],
                        )
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFFF7F3EB),
                          ],
                        ),
                  border: Border.all(
                    color: isSelected
                        ? AtelierColors.gold
                        : AtelierColors.border,
                    width: isSelected ? 2.0 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AtelierColors.primary.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: isSelected ? 10 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.tajawal(
                      fontSize: radius * 0.72,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AtelierColors.goldLight : AtelierColors.primary,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
              // Verified Golden Crest
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified,
                  color: AtelierColors.gold,
                  size: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            storeName,
            style: GoogleFonts.tajawal(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AtelierColors.primary : AtelierColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Refined Luxury Card Container
class AtelierCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final Border? border;
  final VoidCallback? onTap;

  const AtelierCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AtelierColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: border ?? Border.all(color: AtelierColors.borderSubtle, width: 1.0),
        boxShadow: AtelierTheme.subtleShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: container,
      );
    }

    return container;
  }
}

/// Micro luxury pill badge
class AtelierBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final IconData? icon;

  const AtelierBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor ?? backgroundColor,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Atelier Notifications Bottom Sheet
void showAtelierNotificationsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AtelierColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AtelierColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AtelierColors.goldTint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              size: 19,
                              color: AtelierColors.goldDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'مركز الإشعارات والتنبيهات',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AtelierColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'تحديثات الشحنات والامتيازات الحصرية',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: AtelierColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: AtelierColors.textSecondary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AtelierColors.borderSubtle),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      _buildNotificationItemTile(
                        title: 'شحنة أزياء الشام (#SO-902)',
                        subtitle: 'بدأ خياطو الأتيليه في تحضير وتطريز طلبك الفاخر.',
                        time: 'منذ 15 دقيقة',
                        category: 'شحنات',
                        icon: Icons.local_shipping_outlined,
                        isUnread: true,
                      ),
                      _buildNotificationItemTile(
                        title: 'رصيد نقاط المكافآت متاح',
                        subtitle: 'لديك 450 نقطة بريفيليدج بقيمة \$45 مؤهلة للتطبيق على إجمالي الطلب.',
                        time: 'منذ ساعتين',
                        category: 'مكافآت',
                        icon: Icons.stars_rounded,
                        isUnread: true,
                      ),
                      _buildNotificationItemTile(
                        title: 'افتتاح دور أزياء جديدة في المنصة',
                        subtitle: 'انضم كل من "أتيليه القصب" و "دار الياسمين" و "مشغل الفيروز" للموسم الحالي.',
                        time: 'اليوم، 11:30 ص',
                        category: 'كولكشن',
                        icon: Icons.storefront_outlined,
                        isUnread: false,
                      ),
                      _buildNotificationItemTile(
                        title: 'توثيق عنوان التوصيل',
                        subtitle: 'تم التحقق من عنوان التوصيل (دمشق، المزة) وهو معتمد للشحن السريع.',
                        time: 'أمس',
                        category: 'أمان',
                        icon: Icons.shield_outlined,
                        isUnread: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildNotificationItemTile({
  required String title,
  required String subtitle,
  required String time,
  required String category,
  required IconData icon,
  required bool isUnread,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isUnread ? AtelierColors.primaryTint : AtelierColors.surfaceElevated,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: isUnread ? AtelierColors.primaryBorder : AtelierColors.borderSubtle,
        width: 0.8,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isUnread ? Colors.white : AtelierColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isUnread ? AtelierColors.primary : AtelierColors.borderSubtle,
              width: 0.8,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isUnread ? AtelierColors.primary : AtelierColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                        color: AtelierColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AtelierColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AtelierColors.borderSubtle, width: 0.6),
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.tajawal(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AtelierColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: GoogleFonts.tajawal(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AtelierColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: GoogleFonts.tajawal(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AtelierColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
