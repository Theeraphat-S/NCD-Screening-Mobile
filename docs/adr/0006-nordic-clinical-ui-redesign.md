# 6. Nordic Clinical Precision UI System Redesign

**Context & Decision**: 
The existing user interface used generic saturated purple palettes and basic material components that lacked clear visual hierarchy and clinical gravitas for healthcare workers (VHVs and Nurses) and elderly patients. We decided to transition to a unified **Nordic Clinical Precision** design system specified in `DESIGN.md`. This system adopts medical teal primary tones (`#0D9488`), slate neutral surfaces (`#F8FAFC`, `#0F172A`), calibrated WCAG AA compliant risk indicators, tactile spring micro-interactions, and asymmetric Bento grid results visualizations.

**Consequences**:
- Replaces all legacy purple color constants in `lib/shared/tokens/p_colors.dart` with modern teal/slate/calibrated clinical tokens.
- Delivers a cohesive, high-agency user experience across Authentication, Patient Management, 4-NCD Screening, and Nurse Village Analytics.
- Guarantees touch ergonomics (minimum 48x48dp interactive areas) and clear readability under rural field conditions without affecting BLoC state or Drift persistence layers.
