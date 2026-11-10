import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Crisp elevated white card with a 1px hairline border and subtle ambient shadow.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 18,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: backgroundColor ?? AppTheme.cardColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor ?? AppTheme.borderColor, width: 1),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF181D27).withValues(alpha: 0.03),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    );

    final content = padding != null
        ? Padding(padding: padding!, child: child)
        : child;

    if (onTap == null) {
      return Container(
        margin: margin,
        decoration: decoration,
        child: content,
      );
    }

    return Container(
      margin: margin,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      ),
    );
  }
}

/// Soft tonal hero container using airy pearl-indigo washes instead of harsh dark slabs.
class TonalHeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const TonalHeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF1F9), Color(0xFFF9FAFD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppTheme.primaryBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -28,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// Consistent soft tinted icon container.
class SoftIconBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double size;
  final double padding;
  final double borderRadius;

  const SoftIconBadge({
    super.key,
    required this.icon,
    this.iconColor = AppTheme.primaryColor,
    this.backgroundColor = AppTheme.primarySoft,
    this.size = 20,
    this.padding = 10,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(icon, color: iconColor, size: size),
    );
  }
}

/// Refined capsule status pill with optional leading icon.
class StatusPill extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final Color? borderColor;
  final IconData? icon;

  const StatusPill({
    super.key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    this.borderColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Editorial section heading with optional trailing widget.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Clean light AppBar with optional subtitle and crisp 1px bottom border.
PreferredSizeWidget buildPremiumAppBar(
  BuildContext context, {
  required String title,
  String? subtitle,
  Widget? leading,
  List<Widget>? actions,
  PreferredSizeWidget? bottom,
}) {
  return AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    systemOverlayStyle: AppTheme.lightStatusBar,
    leading: leading,
    titleSpacing: leading == null ? 16 : 4,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: 1),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    ),
    actions: actions,
    bottom: bottom ??
        const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppTheme.borderColor),
        ),
  );
}
