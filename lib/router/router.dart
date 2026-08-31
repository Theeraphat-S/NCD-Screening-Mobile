import 'package:auto_route/auto_route.dart';
import 'package:ncd_screening_mobile/feature/home/pages/home_page.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        CustomRoute(
          page: HomeRoute.page,
          initial: true,
          transitionsBuilder: TransitionsBuilders.noTransition,
        ),
      ];
}
