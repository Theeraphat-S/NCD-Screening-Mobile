import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_app_standard/i18n/i18n.dart';
import 'package:mobile_app_standard/router/router.dart';
import 'package:mobile_app_standard/shared/tokens/p_colors.dart';

class BottomBarCustom extends HookWidget {
  final String currentRouteName;

  const BottomBarCustom({super.key, required this.currentRouteName});

  int _getIndexFromRoute(String routeName) {
    if (routeName == HomeRoute.name) return 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(_getIndexFromRoute(currentRouteName));

    useEffect(() {
      selectedIndex.value = _getIndexFromRoute(currentRouteName);
      return null;
    }, [currentRouteName]);

    void onItemTapped(int index) {
      if (index == 0 && currentRouteName != HomeRoute.name) {
        context.router.push(const HomeRoute());
      }
      selectedIndex.value = index;
    }

    final msg = AppLocalizations(context).appbar;

    if (Platform.isIOS) {
      return CupertinoTabBar(
        currentIndex: selectedIndex.value,
        onTap: onItemTapped,
        activeColor: PColor.primaryColor,
        inactiveColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.home),
            label: msg.home_route_name,
          ),
        ],
      );
    }

    return BottomNavigationBar(
      currentIndex: selectedIndex.value,
      onTap: onItemTapped,
      selectedItemColor: PColor.primaryColor,
      unselectedItemColor: Colors.black,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: msg.home_route_name,
        ),
      ],
    );
  }
}
