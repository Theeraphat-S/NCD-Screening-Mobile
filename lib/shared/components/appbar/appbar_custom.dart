import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_standard/shared/components/appbar/language_dropdown.dart';

class AppBarCustom extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  final String currentRouteName;
  final List<Widget>? actions;

  const AppBarCustom({super.key, required this.currentRouteName, this.actions});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8), // Translucent
        border: const Border(
          bottom: BorderSide(color: Color(0x33000000), width: 0.0),
        ), // Remove explicit border for glass effect
        middle: const Text(
          'Fakduai',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Material(
          type: MaterialType.transparency,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              LanguageDropdown(context: context),

              if (actions != null) ...actions!,
            ],
          ),
        ),
      );
    }

    // Android/Material implementation
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Fakduai',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          LanguageDropdown(context: context),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }
}
