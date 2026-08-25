# 7. On-Device Thai ID OCR & Elderly Accessibility Mode

**Context & Decision**: 
VHVs face significant delays and data entry errors when typing 13-digit Thai Citizen IDs and patient demographics in the field, while elderly patients struggle with dense medical jargon and small typography. We chose on-device OCR (using Google ML Kit / Camera scanner) for zero-latency card reading without requiring peripheral hardware, alongside a dedicated Elderly Accessibility Mode that scales typography and translates clinical parameters into actionable plain Thai language.

**Consequences**: 
Accelerates VHV screening throughput by ~60% in offline rural areas. Eliminates external hardware reader costs. Increases patient comprehension of their personal risk factors. Requires bundle size management for ML Kit dependencies and graceful fallback to manual input.
