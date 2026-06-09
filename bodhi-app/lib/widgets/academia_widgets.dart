import 'package:flutter/material.dart';
import '../core/theme/academia_theme.dart';

/// Brass gradient button — primary CTA
class BrassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  const BrassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: AcademiaColors.brassGradient,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: AcademiaColors.brass.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AcademiaColors.background, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label.toUpperCase(),
                  style: AcademiaTypography.button(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Crimson button — emergency / emphasis
class CrimsonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const CrimsonButton({super.key, required this.label, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: AcademiaColors.crimsonGradient,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AcademiaColors.foreground, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label.toUpperCase(),
                  style: AcademiaTypography.button(color: AcademiaColors.foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Aged oak card with optional corner flourishes
class AcademiaCard extends StatelessWidget {
  final Widget child;
  final bool flourish;
  final EdgeInsets padding;
  final bool shadow;

  const AcademiaCard({
    super.key,
    required this.child,
    this.flourish = false,
    this.padding = const EdgeInsets.all(16),
    this.shadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AcademiaColors.backgroundAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AcademiaColors.border, width: 1),
        boxShadow: shadow
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))]
            : null,
      ),
      child: Stack(
        children: [
          Padding(padding: padding, child: child),
          if (flourish) ...[
            Positioned(top: 4, left: 4, child: _CornerFlourish(topLeft: true)),
            Positioned(top: 4, right: 4, child: _CornerFlourish(topRight: true)),
            Positioned(bottom: 4, left: 4, child: _CornerFlourish(bottomLeft: true)),
            Positioned(bottom: 4, right: 4, child: _CornerFlourish(bottomRight: true)),
          ],
        ],
      ),
    );
  }
}

class _CornerFlourish extends StatelessWidget {
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  const _CornerFlourish({
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16, 16),
      painter: _CornerPainter(
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool topLeft, topRight, bottomLeft, bottomRight;

  _CornerPainter({
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AcademiaColors.brass.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final s = size.width;
    if (topLeft) {
      canvas.drawLine(Offset(0, s), Offset.zero, paint);
      canvas.drawLine(Offset.zero, Offset(s, 0), paint);
    }
    if (topRight) {
      canvas.drawLine(Offset(0, 0), Offset(s, 0), paint);
      canvas.drawLine(Offset(s, 0), Offset(s, s), paint);
    }
    if (bottomLeft) {
      canvas.drawLine(Offset(0, 0), Offset(0, s), paint);
      canvas.drawLine(Offset(0, s), Offset(s, s), paint);
    }
    if (bottomRight) {
      canvas.drawLine(Offset(s, 0), Offset(s, s), paint);
      canvas.drawLine(Offset(0, s), Offset(s, s), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ornate divider with centered glyph
class OrnateDivider extends StatelessWidget {
  final String glyph;

  const OrnateDivider({super.key, this.glyph = '✶'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  AcademiaColors.border,
                  AcademiaColors.brass,
                ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(glyph, style: TextStyle(color: AcademiaColors.brass, fontSize: 10)),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AcademiaColors.brass,
                  AcademiaColors.border,
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overline label (VOLUME I, CATEGORY, etc.)
class Overline extends StatelessWidget {
  final String text;
  final Color? color;

  const Overline(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AcademiaTypography.label(size: 10, color: color ?? AcademiaColors.brass),
    );
  }
}

/// Brass icon medallion
class IconMedallion extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const IconMedallion({super.key, required this.icon, this.size = 48, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AcademiaColors.background,
        border: Border.all(color: color ?? AcademiaColors.brass, width: 1),
      ),
      child: Icon(icon, color: color ?? AcademiaColors.brass, size: size * 0.45),
    );
  }
}

/// Brass voice mic button — the centerpiece of the voice-first UX
class VoiceMicButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;
  final bool listening;

  const VoiceMicButton({super.key, this.onPressed, this.size = 112, this.listening = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AcademiaColors.brassGradient,
          boxShadow: [
            BoxShadow(
              color: AcademiaColors.brass.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
            if (listening)
              BoxShadow(
                color: AcademiaColors.brass.withValues(alpha: 0.15),
                blurRadius: 40,
                spreadRadius: 8,
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Inner ring
            Container(
              width: size - 16,
              height: size - 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AcademiaColors.background.withValues(alpha: 0.3), width: 1),
              ),
            ),
            Icon(Icons.mic, size: size * 0.35, color: AcademiaColors.background),
          ],
        ),
      ),
    );
  }
}

/// Wax seal badge
class WaxSeal extends StatelessWidget {
  final IconData icon;
  final double size;

  const WaxSeal({super.key, this.icon = Icons.star, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AcademiaColors.crimson,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.5, color: AcademiaColors.foreground),
    );
  }
}

/// Service tile for the home grid
class ServiceTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const ServiceTile({super.key, required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AcademiaColors.backgroundAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AcademiaColors.border, width: 0.8),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconMedallion(icon: icon, size: 48),
            const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              style: AcademiaTypography.label(size: 9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// List row with icon, title, subtitle, and optional price
class AcademiaListRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final bool selected;
  final VoidCallback? onTap;

  const AcademiaListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AcademiaColors.muted : AcademiaColors.backgroundAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AcademiaColors.brass : AcademiaColors.border,
            width: selected ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          children: [
            IconMedallion(icon: icon, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AcademiaTypography.heading(size: 17)),
                  if (subtitle != null)
                    Text(subtitle!, style: AcademiaTypography.body(size: 13, color: AcademiaColors.mutedForeground)),
                ],
              ),
            ),
            if (trailing != null)
              Text(trailing!, style: AcademiaTypography.heading(size: 18, color: AcademiaColors.brass))
            else
              Icon(Icons.chevron_right, color: AcademiaColors.mutedForeground, size: 20),
          ],
        ),
      ),
    );
  }
}
