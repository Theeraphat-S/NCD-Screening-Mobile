import 'package:flutter/material.dart';

class PShadow {
  static List<BoxShadow> get dropdown => [
        const BoxShadow(
          color: Color(0x0F0F172A),
          spreadRadius: 0,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get sm => [
        const BoxShadow(
          color: Color(0x0A0F172A),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        const BoxShadow(
          color: Color(0x0F0F172A),
          blurRadius: 14,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get card => [
        const BoxShadow(
          color: Color(0x080F172A),
          blurRadius: 12,
          spreadRadius: 0,
          offset: Offset(0, 3),
        ),
      ];
}
