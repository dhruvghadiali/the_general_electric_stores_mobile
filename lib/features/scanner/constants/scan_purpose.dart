import 'package:flutter/material.dart';

/// Why the camera is being opened.
///
/// The same sticker means different things depending on which direction the
/// stock is moving, so the purpose is chosen *before* the camera opens rather
/// than inferred afterwards — a scanned code with no intent attached is
/// ambiguous, and asking after the fact is a worse moment to interrupt.
enum ScanPurpose {
  purchase(
    label: 'Purchase stock',
    description: 'Items arriving into the warehouse',
    icon: Icons.arrow_downward_rounded,
  ),
  sales(
    label: 'Sales stock',
    description: 'Items going out to a customer',
    icon: Icons.arrow_upward_rounded,
  );

  const ScanPurpose({
    required this.label,
    required this.description,
    required this.icon,
  });

  final String label;
  final String description;
  final IconData icon;
}
