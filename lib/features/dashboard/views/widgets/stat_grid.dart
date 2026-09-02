import 'package:flutter/material.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';

/// The two-column grid the dashboards lay their tiles out in.
class StatGrid extends StatelessWidget {
  const StatGrid({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: AppDimens.md,
      mainAxisSpacing: AppDimens.md,
      childAspectRatio: 1,
      children: children,
    );
  }
}
