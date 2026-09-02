import 'package:flutter/material.dart';

/// Centralized Corner Radius Tokens conforming to DESIGN.md §2.3.
class PRadius {
  PRadius._();

  // Raw double values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double card = 16.0; // DESIGN.md §2.3 Cards: 16-20dp
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double pill = 999.0;
  static const double full = 999.0;

  // BorderRadius objects
  static final BorderRadius borderSm = BorderRadius.circular(sm);
  static final BorderRadius borderMd = BorderRadius.circular(md);
  static final BorderRadius borderCard = BorderRadius.circular(card);
  static final BorderRadius borderLg = BorderRadius.circular(lg);
  static final BorderRadius borderXl = BorderRadius.circular(xl);
  static final BorderRadius borderFull = BorderRadius.circular(full);
}
