import 'package:flutter/material.dart';

class PShadow {
  static List<BoxShadow> get dropdown => [
        BoxShadow(
          color: const Color(0x0F0F172A),
          spreadRadius: 0,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: const Color(0x0A0F172A),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: const Color(0x0F0F172A),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0x080F172A),
          blurRadius: 12,
          spreadRadius: 0,
          offset: const Offset(0, 3),
        ),
      ];
}
