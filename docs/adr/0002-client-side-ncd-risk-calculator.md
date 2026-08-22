# 2. Client-Side NCD Risk Calculation Engine

**Context & Decision**:
VHV (อสม.) workers in the field require instantaneous risk assessment feedback immediately after entering biometric and family history data. We decided to implement the 4 NCD risk calculation logic as a pure Dart domain service (`NcdRiskCalculator`) embedded within the mobile client.

**Consequences**:
- Real-time instant risk feedback across 4 diseases (Diabetes, Hypertension, Cardiovascular Disease, Metabolic Syndrome).
- Decouples clinical evaluation formulas from backend latency.
- Allows Nurses to review and adjust/override automatic risk evaluations as specified in the SRS use case `Approve Risk Assessment`.
