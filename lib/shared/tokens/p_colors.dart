import 'package:flutter/material.dart';

class PColor {
  static const Color primaryColor = Color(0xFF5B34B9); // NCD App Purple
  static const Color primaryDark = Color(0xFF45229B);
  static const Color primaryLight = Color(0xFF7E57C2);
  static const Color secondaryColor = Color(0xFF651FFF);
  static const Color backgroundColor = Color(0xFFF6F7FA);
  static const Color neutralColor = Color(0xFFFFFFFF);
  static const Color textNeutralColor = Color(0xFF757575);
  static const Color contentColor = Color(0xFF1E293B);
  static const Color errorColor = Color(0xFFE53935);

  // Status colors
  static const Color riskLow = Color(0xFF2E7D32); // Green
  static const Color riskModerate = Color(0xFFEF6C00); // Orange
  static const Color riskHigh = Color(0xFFC62828); // Red
  static const Color statusPending = Color(0xFFE65100); // Orange-Amber
  static const Color statusApproved = Color(0xFF2E7D32); // Green

  static Color getRiskColor(String? risk) {
    if (risk == null) return riskLow;
    final lower = risk.toLowerCase();
    if (lower.contains('สูง') || lower.contains('high')) return riskHigh;
    if (lower.contains('ปานกลาง') || lower.contains('moderate')) return riskModerate;
    return riskLow;
  }
}
