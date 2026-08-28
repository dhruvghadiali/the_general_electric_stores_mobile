import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/middleware/auth_middleware.dart';
import 'package:the_general_electric_stores_mobile/core/navigation/app_destination.dart';
import 'package:the_general_electric_stores_mobile/features/auth/bindings/auth_binding.dart';
import 'package:the_general_electric_stores_mobile/features/auth/views/login_view.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/views/contact_detail_view.dart';
import 'package:the_general_electric_stores_mobile/features/products/views/product_detail_view.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/bindings/scanner_binding.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/views/scanner_view.dart';
import 'package:the_general_electric_stores_mobile/features/shell/bindings/detail_bindings.dart';
import 'package:the_general_electric_stores_mobile/features/shell/bindings/shell_binding.dart';
import 'package:the_general_electric_stores_mobile/features/shell/views/app_shell_view.dart';
import 'package:the_general_electric_stores_mobile/features/splash/bindings/splash_binding.dart';
import 'package:the_general_electric_stores_mobile/features/splash/views/splash_view.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/views/stock_detail_view.dart';

/// The route table.
///
/// Three things make role isolation real here, and all three have to hold:
///
///  * each role has its own shell route, guarded by [RoleMiddleware] — a role
///    asking for another's shell is sent back to its own;
///  * every detail route is guarded by [DestinationMiddleware], which reads
///    `RoleNavigation` — a warehouse manager cannot deep-link a product;
///  * each shell's binding registers only that role's controllers, so a screen
///    built for the wrong role would throw rather than fetch.
///
/// The server is still the authority. This stops screens opening; it does not
/// stop data leaving.
class AppPages {
  const AppPages._();

  static const String initial = AppRoutes.splash;

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<void>(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage<void>(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      middlewares: <GetMiddleware>[GuestMiddleware()],
      transition: Transition.fadeIn,
    ),

    // ------------------------------------------------------- role shells
    GetPage<void>(
      name: AppRoutes.superAdmin,
      page: () => const AppShellView(),
      binding: SuperAdminShellBinding(),
      middlewares: <GetMiddleware>[
        AuthMiddleware(),
        RoleMiddleware(UserRole.superAdmin),
      ],
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: AppRoutes.employee,
      page: () => const AppShellView(),
      binding: EmployeeShellBinding(),
      middlewares: <GetMiddleware>[
        AuthMiddleware(),
        RoleMiddleware(UserRole.employee),
      ],
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: AppRoutes.warehouseManager,
      page: () => const AppShellView(),
      binding: WarehouseShellBinding(),
      middlewares: <GetMiddleware>[
        AuthMiddleware(),
        RoleMiddleware(UserRole.warehouseManager),
      ],
      transition: Transition.fadeIn,
    ),

    // ---------------------------------------------------- detail routes
    GetPage<void>(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailView(),
      binding: ProductDetailBinding(),
      middlewares: <GetMiddleware>[
        AuthMiddleware(),
        DestinationMiddleware(AppDestination.products),
      ],
    ),
    GetPage<void>(
      name: AppRoutes.contactDetail,
      page: () => const ContactDetailView(),
      binding: ContactDetailBinding(),
      middlewares: <GetMiddleware>[
        AuthMiddleware(),
        DestinationMiddleware(AppDestination.contacts),
      ],
    ),
    // Any signed-in role may scan; what a scanned code *means* is the
    // dashboard's decision, and the detail route it opens is guarded there.
    GetPage<dynamic>(
      name: AppRoutes.scanner,
      page: () => const ScannerView(),
      binding: ScannerBinding(),
      middlewares: <GetMiddleware>[AuthMiddleware()],
      fullscreenDialog: true,
    ),
    GetPage<void>(
      name: AppRoutes.stockDetail,
      page: () => const StockDetailView(),
      binding: StockDetailBinding(),
      middlewares: <GetMiddleware>[
        AuthMiddleware(),
        DestinationMiddleware(AppDestination.stocks),
      ],
    ),
  ];
}
