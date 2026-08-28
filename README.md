# The General Electric Stores — Mobile

Flutter client for `the-general-electric-stores-api`. GetX for state, routing
and DI; Dio for HTTP; feature-first folders.

## Getting started

```bash
cp .env.example .env          # point API_BASE_URL at your API
flutter pub get
flutter run
```

`.env` is gitignored but **is** declared as an asset in `pubspec.yaml`, so the
build fails if the file is missing. Copy the example before the first run.

`API_BASE_URL` points at SIT: `https://the-general-electric-stores-api-sit.onrender.com`.
It sleeps on Render's free tier, so the first request after an idle period waits
out a 30–60s cold start — hence the generous receive timeout. Against a local
API use `http://10.0.2.2:3000` on the Android emulator, `http://127.0.0.1:3000`
on the iOS simulator, and the machine's LAN IP on a physical device.

## Layout

```
lib/
├── main.dart                  bootstrap: env, error zone, services, runApp
├── app/
│   ├── app.dart               GetMaterialApp
│   ├── bindings/              services created before the first route
│   ├── routes/                app_routes.dart (names) + app_pages.dart (table)
│   └── theme/                 colours, type scale, spacing, ThemeData
├── core/
│   ├── config/                typed .env access
│   ├── constants/             endpoints, storage keys, app constants
│   ├── controllers/           BaseListController — paging, search, retry
│   ├── middleware/            route guards (auth, guest, role)
│   ├── models/                Pagination, ListQuery
│   ├── network/               ApiClient, ApiResponse, ApiException, interceptors
│   ├── services/              StorageService, AuthService, ConnectivityService
│   ├── utils/                 validators, formatters, logger, snackbars
│   └── widgets/               AppButton, AppTextField, loading/error/empty
└── features/<feature>/
    ├── bindings/              what this route needs
    ├── controllers/           screen state and actions, one per role where they differ
    ├── data/models/           JSON ⇄ Dart, shared across roles
    ├── data/repositories/     the endpoints this feature calls, role-scoped
    ├── views/                 screens, one per role where they differ
    └── widgets/               widgets used only by this feature
```

The rule that keeps it honest: **views** read from a controller, **controllers**
call a repository, **repositories** are the only things that touch `ApiClient`,
and `ApiClient` is the only thing that touches `Dio`.

## Roles

Three roles, each with its own shell and its own screens:

| | Super admin | Employee | Warehouse manager |
|---|---|---|---|
| Dashboard | ✔ own | ✔ own | ✔ own |
| Products | ✔ + create | ✔ read-only | — |
| Contacts | ✔ + create | ✔ read-only | — |
| Stocks | — | — | ✔ |
| Settings | ✔ shared | ✔ shared | ✔ shared |

`core/navigation/role_navigation.dart` is the single source of truth for that
table. Adding a tab to a role is an edit there and nowhere else — the bottom
bar, the route guards and the binding all read from it.

Four things enforce the separation, and all four have to hold:

1. **Its own shell route.** `/super-admin`, `/employee`, `/warehouse-manager`,
   each behind `RoleMiddleware`. A role asking for another's shell is sent back
   to its own, not shown an empty screen.
2. **Guarded detail routes.** `DestinationMiddleware` reads `RoleNavigation`, so
   a warehouse manager cannot deep-link `/products/abc123`. Removing a tab from
   a role closes its deep links in the same edit.
3. **Its own binding.** `SuperAdminShellBinding` never registers
   `WarehouseStocksController`. A screen somehow built for the wrong role throws
   on `Get.find` rather than quietly fetching.
4. **Role-scoped paths.** Every request goes to `/{role}/…`, built from the
   session's role. The client cannot construct another role's URL.

Only the fourth is real security — the first three are routing, and the server
is what actually keeps one role's data away from another.

Super admin and employee share tab *names* but not screens: `RoleScreens` maps
`(role, destination)` to a widget, and each pairing resolves to its own file, so
an admin-only control cannot appear on the employee screen by accident. Models
and repositories *are* shared, because the shape of a product is the same
whoever reads it — only the path and the actions differ.

Settings is the one genuinely shared screen: it shows who is signed in and signs
them out, which is the same job for all three.

## Talking to the API

The client mirrors the API's own contracts rather than guessing at them.

**The response envelope.** Every endpoint answers through `send_response(res,
status, message, data)`. `data` is normalised server-side: a single document
comes back wrapped, an empty result becomes `[]`, and an action with several
values returns one object — `{ products, summary, sort, pagination }`.
`ApiResponse.asMap` / `.asList` absorb all three shapes so no repository indexes
into raw JSON.

**List endpoints.** `ListQuery` builds the query string a list config accepts:
`page`, `limit`, `search`, and either `sort` **or** `sort_by`+`sort_order` —
never both, because the server's `.oxor` rejects that with a 400. `limit` is
clamped to 100 client-side to match `pagination_defaults.MAX_LIMIT`.

A column is only searchable, filterable or sortable if that resource's list
config on the API names it. Adding a filter here without adding it there is a
400, not a broken screen — check `src/validators/query_params/<feature>/config/`
in the API repo first.

**Errors.** `ErrorInterceptor` turns every failure into an `ApiException`
carrying the server's own message plus any field-level Joi messages in
`.errors`. Controllers show `error.message` and hand `.errors` to the form.

**Auth is role-scoped.** The API mounts a separate auth router per role, so the
role travels in the URL, not the body:

```
POST /super-admin/signin
POST /employee/signin
POST /warehouse-manager/signin        body: { username, password }
```

`UserRole` owns that mapping. The path segments are kebab-case and do **not**
match the `user_type` values, which are snake_case: `super_admin` signs in at
`/super-admin`. Both spellings are real — one is the router mount point, the
other is the field on the user record.

The role chosen on the sign-in screen is stored with the session, because every
later call needs it to build a path. Resources are scoped the same way —
`/employee/products`, `/warehouse-manager/stocks`, `/super-admin/dashboard` —
all through `ApiEndpoints.scoped(role, path)`.

**None of it is verified against SIT.** The sign-in paths come from the API
team; `me`, `signout`, `refresh-token`, `products`, `contacts`, `stocks` and
`dashboard` follow the same shape by assumption. They all live in
`ApiEndpoints`, so a wrong path is one line there and nothing else moves.

`AuthInterceptor` attaches the bearer token, and on a 401 refreshes once and
replays the request. A second failure clears the session and routes to login.
Tokens live in the keychain / keystore, never in `SharedPreferences`.

## Adding a feature

1. `lib/features/<name>/data/models/<name>_model.dart` — `fromJson` reads the
   API's snake_case, defensively (a populated reference arrives as an object,
   an unpopulated one as a string).
2. `data/repositories/<name>_repository.dart` — one method per endpoint, add the
   paths to `core/constants/api_endpoints.dart`.
3. `controllers/` — extend `BaseListController<T>` for a list screen and
   implement `fetchPage`; a plain `GetxController` for anything else.
4. `views/` + `widgets/`.
5. `bindings/<name>_binding.dart` — `lazyPut` the repository (`fenix: true`) and
   the controller.
6. Register the route in `app/routes/app_routes.dart` and `app_pages.dart`.

## Scanning

Every dashboard has a scan card. Tapping it asks the camera permission *before*
opening the scanner, so the user never sees a black viewfinder behind a pending
dialog — either the camera opens or we say why it did not.

The four outcomes are handled separately, because they need different answers:
granted opens the scanner; denied says "tap again to allow"; permanently denied
offers a jump to Settings (iOS only ever shows its prompt once, so asking again
would be a dead button); restricted explains that a policy or parental control
is blocking it and there is nothing the user can do.

What a scanned code *means* is each role's decision —
`BaseDashboardController.onScanned` is abstract. Super admin and employee open
the product; warehouse manager opens the stock line, because they are scanning
shelf labels. Codes printed as a URL are reduced to their last path segment.

Native setup, needed once per platform:

- **Android** — `CAMERA` permission, plus `camera` and `camera.autofocus`
  declared `required="false"` so the app still installs on a device without one.
- **iOS** — `NSCameraUsageDescription` in `Info.plist`, and
  `PERMISSION_CAMERA=1` in the Podfile's `post_install`. That second one
  matters: `permission_handler` compiles every permission it ships unless told
  which to keep, and App Store review rejects a binary that links the
  microphone API with no matching usage string.

## Platform notes

**Android.** Kotlin DSL, `minSdk 24`, application id
`com.thegeneralelectricstores.app` (debug builds get `.debug`, so both can sit
on one device). Cleartext HTTP is allowed only to `10.0.2.2`, `localhost` and
`127.0.0.1` via `network_security_config.xml`.

Release signing reads `android/key.properties` (gitignored):

```properties
storePassword=…
keyPassword=…
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

Until that file exists, release builds fall back to the debug key so
`flutter build apk --release` still runs locally.

**iOS.** Everything except the Xcode project is here. Generate it once:

```bash
flutter create --platforms=ios .
git diff --stat ios/          # see what the tool overwrote
git checkout -- ios/Runner/Info.plist ios/Podfile   # keep our versions
cd ios && pod install
```

Deployment target is 13.0 (`flutter_secure_storage` and `connectivity_plus`
both need 12+). `NSAllowsLocalNetworking` lets the simulator reach an API on
the same Mac.

## Conventions

- No tests while the app is under development. `flutter analyze` is the gate:
  it should be clean before a PR.
- `analysis_options.yaml` runs `flutter_lints` plus strict casts, single
  quotes, trailing commas and explicit return types.
- Imports are always `package:the_general_electric_stores_mobile/…`, never
  `../..`. `always_use_package_imports` enforces it, so a file moved between
  folders does not drag a trail of broken paths behind it.
- No `print` — use `AppLogger`.
- No colour, spacing or radius literals in widgets — use `AppColors`,
  `AppDimens` and the theme.
- No route string literals — use `AppRoutes`.
