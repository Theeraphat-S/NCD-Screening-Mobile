# Specification: Field OCR, Offline Sync Queue, Clinical Triage & Elderly Accessibility Upgrade

## Problem Statement

Primary care staff at subdistrict health promotion hospitals (รพ.สต.แม่อาย) and community health volunteers (VHV / อสม.) face significant friction during community health screenings for non-communicable diseases (4 NCDs). 

Specifically:
1. **Field Entry Delays**: VHVs manually typing 13-digit Thai Citizen IDs and patient demographics on mobile devices experience high error rates and slow throughput (up to 3-4 minutes per patient), creating bottlenecks during large field screening sessions.
2. **Intermittent Connectivity & Data Silos**: Remote villages lack stable mobile internet. Screenings recorded locally in isolated SQLite databases risk data loss or delays in reaching hospital systems (HIS/JHCIS) without an automated background sync mechanism.
3. **Delayed Critical Interventions**: When a patient exhibits hypertensive crisis or high NCD risk, nurses have no instant multi-channel alert or prioritized home visit queue to initiate immediate clinical triage.
4. **Cognitive Burden on Elderly Patients**: Patients viewing their screening results are overwhelmed by complex medical metrics and small font sizes, limiting their ability to understand and adopt personalized lifestyle modifications.

---

## Solution

A robust, field-hardened mobile health upgrade that delivers:
1. **IdCardOcrScan & SmartFieldMatching**: On-device Thai Citizen ID optical character recognition that extracts the 13-digit ID and patient name, instantly pre-populating existing patient records and opening the screening form.
2. **OfflineSyncQueue & Dynamic SyncBadgeState**: SQLite-persisted sync transaction queue that automatically dispatches recorded screenings to the cloud API upon detecting network connectivity, complemented by a real-time status badge and manual retry trigger in the application header.
3. **ClinicalTriageAlert & Urgent Home Visit Queue**: Automated clinical risk triage that surfaces high-risk patients to primary care nurses in an Urgent Care queue, triggers external notification webhooks (LINE Notify), and provides an emergency hospital contact card for the patient.
4. **ElderlyAccessibilityMode**: Simplified patient result interface featuring bold categorical status cards, actionable plain-language dietary/exercise guidance, and a one-tap extra-large typography scale switch.
5. **HealthDataExport with Privacy Compliance**: Dual-mode Excel/CSV data export supporting both anonymized/masked exports for statistical reporting (PDPA compliant) and complete clinical datasets for hospital HIS import guarded by Nurse authentication.

---

## User Stories

1. As a VillageHealthVolunteer (VHV), I want to scan a citizen's Thai ID card using my phone camera, so that I do not have to manually type the 13-digit citizen ID.
2. As a VillageHealthVolunteer (VHV), I want the application to automatically match the scanned ID against existing patient records, so that I can immediately start recording vitals without re-entering demographic details.
3. As a VillageHealthVolunteer (VHV), I want the camera scanner to work completely offline, so that I can screen patients in remote rural areas without cellular coverage.
4. As a VillageHealthVolunteer (VHV), I want a clear visual camera bounding guide and lighting toggle, so that I can accurately capture ID cards in low-light household conditions.
5. As a VillageHealthVolunteer (VHV), I want a fallback option to manually type or edit scanned details, so that I can correct damaged or faded ID cards.
6. As a VillageHealthVolunteer (VHV), I want newly registered patients discovered during scanning to be saved directly to the village database, so that their profiles are available for subsequent screening rounds.
7. As a VillageHealthVolunteer (VHV), I want all screening assessments saved in the field to be enqueued in an offline transaction table, so that no screening data is lost if the device loses power or signal.
8. As a VillageHealthVolunteer (VHV), I want an always-visible sync badge in the top navigation bar, so that I can instantly verify whether my recorded screenings are synchronized or pending.
9. As a VillageHealthVolunteer (VHV), I want the app to automatically synchronize pending records when internet connectivity is detected, so that I do not have to remember to upload data manually at the end of the day.
10. As a VillageHealthVolunteer (VHV), I want a one-tap manual sync button on the sync badge, so that I can immediately force an upload when I return to the clinic's Wi-Fi network.
11. As a Patient, I want to view my 4 NCD risk assessment results with clear green, yellow, and red indicator cards, so that I can immediately understand my overall health status without medical knowledge.
12. As an elderly Patient, I want a one-tap button to enlarge all text and numeric figures, so that I can comfortably read my blood pressure and blood sugar numbers without straining my eyes.
13. As a Patient, I want plain Thai lifestyle, dietary, and exercise recommendations tailored to my specific risk level, so that I know what practical steps to take to improve my health.
14. As a Patient identified with high risk or crisis blood pressure, I want an emergency contact button with the direct phone number of the subdistrict health center, so that I can immediately seek medical attention.
15. As a Nurse, I want an Urgent Home Visit queue on my dashboard that highlights patients categorized as High Risk, so that I can prioritize proactive clinical follow-ups.
16. As a Nurse, I want critical screening results to trigger automated webhook notifications (LINE Notify), so that our public health team is notified in real time of life-threatening vitals.
17. As a Nurse, I want to review and batch-approve pending screening records submitted by VHVs across different villages, so that clinical evaluations are officially endorsed in the permanent record.
18. As a Nurse, I want to export screening and demographic datasets to Excel (.xlsx) or CSV formats, so that I can import routine health data into hospital information systems (HIS/JHCIS).
19. As a Nurse, I want the option to export masked health records (hiding national IDs), so that epidemiological statistics can be shared publicly in full compliance with PDPA regulations.
20. As a Nurse, I want unmasked health data exports to require nurse credential verification, so that sensitive medical records remain protected against unauthorized downloads.

---

## Implementation Decisions

### 1. Smart Field Entry & OCR Module
- Utilize an on-device text recognition engine (Google ML Kit Text Recognition) running locally on Android and iOS platforms.
- Implement an automated regular expression parser optimized for Thai National ID format (`\d{1}\s?\d{4}\s?\d{5}\s?\d{2}\s?\d{1}`) and Thai naming prefixes (นาย, นาง, นางสาว).
- Query local SQLite database via repository immediately upon OCR extraction. If an existing `Patient` is resolved, transition directly to `ScreeningFormPage` with pre-filled state; if new, transition to `AddEditPatientPage` with pre-filled name and citizen ID.

### 2. Offline Sync Queue & Connectivity Engine
- Introduce a relational `SyncQueueTable` in the Drift SQLite database to store unacknowledged transactions (operation type, entity payload, creation timestamp, retry count, sync status).
- Maintain an active connectivity listener monitoring network state changes (Cellular, Wi-Fi, None).
- Background sync engine processes pending items sequentially with exponential backoff on failure (max 5 retries before marking as failed).
- Reactive `SyncBadgeBloc` broadcasts synchronization state:
  - `Synced` (Green): Zero pending items, network active.
  - `Pending` (Amber): Count of pending offline transactions.
  - `Syncing` (Blue): Active sync transfer in progress.
  - `Offline` (Grey): No network available.

### 3. Clinical Triage & Alert System
- Risk evaluation service computes individual and composite risk tiers for Diabetes, Hypertension, CVD, and Metabolic Syndrome.
- When `RiskLevel.high` or critical blood pressure (`SBP >= 180` or `DBP >= 110`) is evaluated:
  - Flag the screening record as `requiresImmediateVisit = true`.
  - Dispatch a secure webhook payload to configured endpoint (LINE Notify / Public Health webhook).
  - Inject an `EmergencyActionCard` into the Patient view with one-touch phone dialer integration (`tel:053-XXXXXX`).

### 4. Elderly Accessibility & Patient Presentation Module
- Implement an `AccessibilityCubit` managing typography scaling factor (Standard 1.0x vs. Elderly 1.35x) and high-contrast clinical theme tokens.
- Replace dense medical parameter grids with intuitive, color-calibrated Bento cards displaying status chips (`ปกติ`, `เสี่ยงปานกลาง`, `เสี่ยงสูง`) and clear Thai action text.

### 5. Health Data Export & Privacy Engine
- Pure Dart Excel/CSV generation service formatting screening datasets matching the Ministry of Public Health (MOPH) 43-folder / JHCIS standard.
- Dual export mode:
  - `ExportMode.anonymized`: Masks citizen ID (`X-XXXX-XXXXX-XX-X`) and trims patient names to initials.
  - `ExportMode.clinicalFull`: Complete dataset requiring authenticated Nurse session verification.

---

## Testing Decisions

### Test Characteristics
- All tests must verify external observable behavior and contracts rather than internal implementation details.
- Avoid mocking SQLite storage when repository unit testing; use Drift in-memory SQLite database (`NativeDatabase.memory()`) to ensure real query execution and transaction safety.

### Tested Modules
1. **IdCardOcrParser Unit Tests**: Validate extraction accuracy across diverse Thai ID card string patterns, whitespace anomalies, and hyphen variations.
2. **OfflineSyncQueue & Repository Tests**: Test queue insertion, batch dequeuing, idempotent retry handling, and rollback on simulated network failure.
3. **ClinicalTriage & Risk Calculator Tests**: Assert that extreme vitals (crisis BP, high blood sugar) correctly trigger `requiresImmediateVisit` flags and triage alert payloads.
4. **HealthDataExport Service Tests**: Verify CSV and Excel sheet column mappings, correct mathematical summaries, and complete masking in anonymized mode.
5. **UI & BLoC Widget Tests**:
   - `SyncBadge` widget reflecting accurate pending counts and color state changes.
   - `AccessibilityToggle` scaling font sizes dynamically without UI overflow.
   - `PatientResultPage` rendering emergency cards when high risk is present.

### Prior Art
- Repository and domain calculation test suites in `test/unit/domain/` using Drift in-memory databases and BLoC test harnesses (`bloc_test`).

---

## Out of Scope

1. **Physical Smart Card Reader Hardware Integration**: Bluetooth / USB smart card readers are excluded in favor of camera OCR to eliminate hardware acquisition costs.
2. **Direct Hospital Database Socket Connection**: Direct VPN/socket connection to hospital server clusters is excluded; data exchange occurs via standard REST sync endpoints and structured file imports.
3. **Automated Biometric Facial Recognition**: Face verification against national databases is excluded due to privacy constraints and regulatory approvals.

---

## Further Notes

- The system adheres strictly to the color calibration and typography hierarchy documented in `DESIGN.md` (Nordic Clinical Palette, Slate neutrals, WCAG AA contrast).
- All domain terminology aligns with definitions in `CONTEXT.md` (`IdCardOcrScan`, `OfflineSyncQueue`, `ClinicalTriageAlert`, `ElderlyAccessibilityMode`, `HealthDataExport`).
