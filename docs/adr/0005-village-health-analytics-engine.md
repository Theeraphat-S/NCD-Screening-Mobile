# 5. Nurse Village Health Analytics & Triage Queue Engine

**Context & Decision**:
Supervising nurses at Tambon Health Promoting Hospitals need rapid situational awareness across multiple administrative villages to allocate resources, monitor screening coverage, and identify patients requiring urgent follow-up. We created a pure Dart domain analytics engine (`VillageAnalyticsCalculator`) paired with `VillageAnalyticsBloc`.

The calculator computes multi-dimensional aggregates from relational screening snapshots: screening coverage percentage, 4 NCD risk distributions (DM, HT, CVD, Metabolic Syndrome), demographic statistics, comparative village rankings, and a prioritized high-risk clinical triage queue.

**Consequences**:
- Fast in-memory aggregation: Recalculates metrics on-demand from local database queries without requiring external BI backend services.
- Deterministic and testable: Pure computation allows exhaustive automated unit test coverage across all boundary conditions.
