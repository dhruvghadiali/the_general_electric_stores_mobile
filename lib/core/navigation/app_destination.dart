import 'package:flutter/material.dart';

/// Every top-level place the app can show.
///
/// A destination is not owned by a role — [RoleNavigation] decides which roles
/// get which. This enum only says what each one is called and what it looks
/// like in the bottom bar, so a rename happens once.
enum AppDestination {
  dashboard(
    label: 'Dashboard',
    icon: Icons.space_dashboard_outlined,
    activeIcon: Icons.space_dashboard_rounded,
  ),
  products(
    label: 'Products',
    icon: Icons.inventory_2_outlined,
    activeIcon: Icons.inventory_2_rounded,
  ),
  stocks(
    label: 'Stocks',
    icon: Icons.warehouse_outlined,
    activeIcon: Icons.warehouse_rounded,
  ),
  contacts(
    label: 'Contacts',
    icon: Icons.contacts_outlined,
    activeIcon: Icons.contacts_rounded,
  ),
  settings(
    label: 'Settings',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
  );

  const AppDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
