import 'package:flutter/material.dart';
import '../core/theme/academia_theme.dart';
import 'academia_widgets.dart';

/// Reusable screen header with back arrow, title, and ornate divider.
class ScreenHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;

  const ScreenHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              if (showBack)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AcademiaColors.brass),
                  onPressed: () => Navigator.pop(context),
                ),
              Expanded(
                child: Text(
                  title,
                  style: AcademiaTypography.heading(size: 22),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: OrnateDivider(),
          ),
        ],
      ),
    );
  }
}
