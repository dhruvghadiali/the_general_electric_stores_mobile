import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/navigation/app_destination.dart';
import 'package:the_general_electric_stores_mobile/features/shell/controllers/shell_controller.dart';
import 'package:the_general_electric_stores_mobile/features/shell/views/role_screens.dart';

/// The chrome every role shares: a bottom bar built from that role's
/// destinations, over an [IndexedStack] so a tab keeps its scroll position and
/// loaded page when you come back to it.
///
/// Which screens go in the stack is [RoleScreens]' decision, and only the
/// current role's screens are ever built.
class AppShellView extends GetView<ShellController> {
  const AppShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<AppDestination> destinations = controller.destinations;

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.index.value,
          children: destinations
              .map(
                (AppDestination destination) =>
                    RoleScreens.build(controller.role, destination),
              )
              .toList(growable: false),
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.index.value,
          onDestinationSelected: controller.select,
          destinations: destinations
              .map(
                (AppDestination destination) => NavigationDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.activeIcon),
                  label: destination.label,
                  tooltip: destination.label,
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
