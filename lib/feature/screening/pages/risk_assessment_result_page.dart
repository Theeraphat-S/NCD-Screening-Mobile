import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_standard/domain/models/ncd_models.dart';
import 'package:mobile_app_standard/feature/patient/bloc/patient_bloc.dart';
import 'package:mobile_app_standard/feature/patient/pages/vhv_patient_list_page.dart';
import 'package:mobile_app_standard/feature/screening/pages/pdf_preview_page.dart';
import 'package:mobile_app_standard/shared/tokens/p_colors.dart';

class RiskAssessmentResultPage extends StatelessWidget {
  final Patient patient;
  final Screening screening;
  final VHV? vhv;

  const RiskAssessmentResultPage({
    super.key,
    required this.patient,
    required this.screening,
    this.vhv,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: PColor.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'แนวโน้มความเสี่ยง',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
            tooltip: 'ส่งออก/พิมพ์รายงาน PDF',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PdfPreviewPage(
                    patient: patient,
                    screening: screening,
                    vhv: vhv,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step Indicator
              _buildStepIndicator(),
              const SizedBox(height: 16),

              // Patient Header Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: PColor.primaryLight.withValues(alpha: 0.15),
                      child: const Icon(Icons.person, color: PColor.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ผู้ป่วย: ${patient.fullName}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: PColor.contentColor,
                            ),
                          ),
                          Text(
                            'เลขบัตร: ${patient.patientCitizenId} • อายุ ${screening.ageAtScreening} ปี',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: PColor.textNeutralColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: Text(
                  'มีแนวโน้มความเสี่ยงที่จะเป็น',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: PColor.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 4 Disease Risk Cards
              ...screening.results.map(_buildDiseaseCard),

              // PDF Export Action Button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfPreviewPage(
                        patient: patient,
                        screening: screening,
                        vhv: vhv,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_outlined, color: PColor.primaryColor),
                label: const Text(
                  'ดูตัวอย่างและพิมพ์รายงาน PDF (Export PDF)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: PColor.primaryColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: PColor.primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Back to Patient List Button
              ElevatedButton(
                onPressed: () {
                  if (vhv != null) {
                    context.read<PatientBloc>().add(
                          PatientLoadRequested(villageId: vhv!.villageId),
                        );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VhvPatientListPage(vhv: vhv!),
                      ),
                      (route) => route.isFirst,
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PColor.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'กลับไปหน้ารายชื่อผู้ป่วย',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(number: '1', label: 'ข้อมูลผู้ป่วย', isDone: true),
          _buildStepLine(isActive: true),
          _buildStepItem(number: '2', label: 'แบบคัดกรอง', isDone: true),
          _buildStepLine(isActive: true),
          _buildStepItem(number: '3', label: 'แนวโน้มความเสี่ยง', isActive: true),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String number,
    required String label,
    bool isActive = false,
    bool isDone = false,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: (isActive || isDone) ? PColor.primaryColor : Colors.grey.shade300,
          child: isDone
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  number,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: (isActive || isDone) ? Colors.white : Colors.grey.shade700,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? PColor.primaryDark : PColor.textNeutralColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: isActive ? PColor.primaryColor : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildDiseaseCard(ScreeningResult result) {
    Color badgeColor;
    Color badgeBg;
    switch (result.riskLevel) {
      case RiskLevel.high:
        badgeColor = PColor.riskHigh;
        badgeBg = Colors.red.shade50;
        break;
      case RiskLevel.moderate:
        badgeColor = PColor.riskModerate;
        badgeBg = Colors.orange.shade50;
        break;
      case RiskLevel.low:
        badgeColor = PColor.riskLow;
        badgeBg = Colors.green.shade50;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                result.diseaseName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PColor.contentColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'ความเสี่ยง${result.riskLevel.labelTh}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.criteriaText,
            style: const TextStyle(
              fontSize: 13,
              color: PColor.textNeutralColor,
              height: 1.3,
            ),
          ),
          if (result.adviceText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: PColor.primaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'คำแนะนำ: ${result.adviceText}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: PColor.contentColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
