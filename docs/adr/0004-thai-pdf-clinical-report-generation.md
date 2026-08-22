# 4. Thai PDF Clinical Summary Report Generation & Sharing

**Context & Decision**:
Patients and healthcare workers in community health promotion hospitals require physical and digital documentation of NCD risk evaluations to present during physician consultations or hospital referrals. We implemented a client-side PDF document generation service (`PdfReportService`) using the `pdf` and `printing` packages.

The engine bundles TrueType Thai fonts (Sarabun regular and bold) and formats clinical findings into a structured 7-section medical summary conforming to Thai Ministry of Public Health visual presentation standards with Buddhist Era dates and formal certification sections.

**Consequences**:
- Complete offline capability: PDFs can be generated, previewed, printed, and shared via OS share sheets in zero-connectivity environments.
- Self-contained asset dependency: Thai TrueType font assets must be bundled within the application binaries to prevent broken glyph rendering.
