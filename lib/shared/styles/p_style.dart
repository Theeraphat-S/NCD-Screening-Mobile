import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_elevation.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';

class PStyle {
  static ButtonStyle get btnPrimary {
    return ElevatedButton.styleFrom(
      backgroundColor: PColor.primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PRadius.sm),
      ),
      elevation: PElevation.none,
    );
  }

  static ButtonStyle get btnSecondary {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: PColor.contentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PRadius.sm),
      ),
      elevation: PElevation.none,
    );
  }
}
