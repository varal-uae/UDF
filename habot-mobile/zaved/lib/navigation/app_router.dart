import 'package:flutter/material.dart';
import '../ui/master_menu_page.dart';
import '../ui/dynamic_typography_wrapper_workspace.dart';
import '../ui/design_system_infrastructure_showcase.dart';

/// Declarative Application Router Configuration for [MaterialApp.router]
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'APP-NAV-ROOT-003-A10');

  /// Creates a declarative [RouterConfig] for [MaterialApp.router]
  static RouterConfig<RouteInformation> get routerConfig {
    return _AppRouterConfig();
  }
}

class _AppRouterConfig implements RouterConfig<RouteInformation> {
  final _AppRouterDelegate _delegate = _AppRouterDelegate();
  final _AppRouteInformationParser _parser = _AppRouteInformationParser();
  final _AppRouteInformationProvider _provider = _AppRouteInformationProvider();

  @override
  RouterDelegate<RouteInformation> get routerDelegate => _delegate;

  @override
  RouteInformationParser<RouteInformation> get routeInformationParser => _parser;

  @override
  RouteInformationProvider get routeInformationProvider => _provider;

  @override
  BackButtonDispatcher get backButtonDispatcher => RootBackButtonDispatcher();
}

class _AppRouteInformationProvider extends RouteInformationProvider
    with ChangeNotifier {
  RouteInformation _value = RouteInformation(uri: Uri.parse('/'));

  @override
  RouteInformation get value => _value;

  @override
  void routerReportsNewRouteInformation(
    RouteInformation routeInformation, {
    RouteInformationReportingType type = RouteInformationReportingType.none,
  }) {
    _value = routeInformation;
    notifyListeners();
  }
}

class _AppRouteInformationParser
    extends RouteInformationParser<RouteInformation> {
  @override
  Future<RouteInformation> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    return routeInformation;
  }

  @override
  RouteInformation restoreRouteInformation(RouteInformation configuration) {
    return configuration;
  }
}

class _AppRouterDelegate extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = AppRouter.rootNavigatorKey;

  String _currentPath = '/';

  String get currentPath => _currentPath;

  void setPath(String path) {
    _currentPath = path;
    notifyListeners();
  }

  @override
  RouteInformation? get currentConfiguration =>
      RouteInformation(uri: Uri.parse(_currentPath));

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    _currentPath = configuration.uri.path;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage<void>(
          key: const ValueKey('MasterMenuPage'),
          child: _resolvePageContent(_currentPath),
        ),
      ],
      onDidRemovePage: (page) {
        _currentPath = '/';
        notifyListeners();
      },
    );
  }

  Widget _resolvePageContent(String path) {
    switch (path) {
      case '/dynamic-typography':
        return const DynamicTypographyWrapperWorkspace();
      case '/showcase':
        return const DesignSystemInfrastructureShowcase();
      case '/':
      default:
        return const MasterMenuPage();
    }
  }
}
