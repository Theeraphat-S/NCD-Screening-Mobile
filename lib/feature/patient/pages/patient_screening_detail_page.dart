import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/clinical_triage_service.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_lifestyle_advisor.dart';
import 'package:ncd_screening_mobile/feature/nurse/pages/nurse_approve_risk_page.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/pdf_preview_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/widgets/elderly_bento_advice_card.dart';
import 'package:ncd_screening_mobile/shared/widgets/emergency_hospital_card.dart';
import 'package:ncd_screening_mobile/shared/widgets/patient_accessibility_floating_bubble.dart';

class PatientScreeningDetailPage extends StatelessWidget {
  final Patient patient;
  final Screening screening;
  final Nurse? nurse;
  final VHV? vhv;

  const PatientScreeningDetailPage({
    super.key,
    required this.patient,
    required this.screening,
    this.nurse,
    this.vhv,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScreeningBloc, ScreeningState>(
      builder: (context, state) {
        final currentScreening = state.historyList.firstWhere(
          (s) => s.screenId == screening.screenId,
          orElse: () => state.currentScreening ?? screening,
        );

        final isPending = currentScreening.reviewStatus == ReviewStatus.pending;
        final dateStr =
            '${currentScreening.screeningDate.day.toString().padLeft(2, '0')}/${currentScreening.screeningDate.month.toString().padLeft(2, '0')}/${currentScreening.screeningDate.year + 543}';

        return Scaffold(
          backgroundColor: PColor.backgroundColor,
          appBar: AppBar(
            backgroundColor: PColor.primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'ผลคัดกรอง: ${patient.patientFname} ${patient.patientLname}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            actions: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: AccessibilityScaleToggle(),
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
                tooltip: 'ส่งออก/พิมพ์รายงาน PDF',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfPreviewPage(
                        patient: patient,
                        screening: currentScreening,
                        vhv: vhv,
                        nurse: nurse,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Emergency Hospital Card if Triage Alert
                    EmergencyHospitalCard(
                      triage: ClinicalTriageService.assess(
                        screening: currentScreening,
                        results: currentScreening.results,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Status Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isPending ? PColor.statusPendingBg : PColor.statusApprovedBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPending ? PColor.statusPending : PColor.statusApproved,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPending ? Icons.hourglass_top_rounded : Icons.check_circle_rounded,
                            color: isPending ? PColor.statusPending : PColor.statusApproved,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isPending ? 'รอพยาบาลตรวจสอบและรับรองผล' : 'ผ่านการรับรองโดยพยาบาลแล้ว',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: isPending ? PColor.statusPending : PColor.statusApproved,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'วันที่ตรวจ: $dateStr',
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

                    // 4 NCDs Risk Summary Cards
                    const Text(
                      'ผลการประเมินความเสี่ยง 4 โรค',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: PColor.contentColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...currentScreening.results.map(
                      (res) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: PColor.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _getRiskColor(res.riskLevel).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.favorite_rounded,
                                color: _getRiskColor(res.riskLevel),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    res.diseaseName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: PColor.contentColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'คะแนน: ${res.score} คะแนน',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: PColor.textNeutralColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getRiskColor(res.riskLevel),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                res.riskLevel.labelTh,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Plain Thai Lifestyle Guidance Header (Elderly Friendly)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            PColor.primaryDark,
                            PColor.primaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.health_and_safety_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'คู่มือการปฏิบัติตัวและอาหารสุขภาพ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'คำแนะนำเข้าใจง่ายสำหรับประชาชนและผู้สูงอายุ',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Personalized Plain Thai Lifestyle Guidance Bento Cards
                    ...NcdLifestyleAdvisor.generateAdviceList(
                      screening: currentScreening,
                      results: currentScreening.results,
                    ).map((adv) => ElderlyBentoAdviceCard(advice: adv)),

                    const SizedBox(height: 14),

                    // Vitals Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ข้อมูลสัญญาณชีพและร่างกาย',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: PColor.contentColor,
                              ),
                            ),
                            const Divider(height: 20),
                            _buildMetricRow('น้ำหนัก', '${currentScreening.weight.toStringAsFixed(1)} กก.'),
                            _buildMetricRow('ส่วนสูง', '${currentScreening.height.toStringAsFixed(1)} ซม.'),
                            _buildMetricRow('BMI', '${currentScreening.bmi.toStringAsFixed(1)} kg/m²'),
                            _buildMetricRow('รอบเอว', '${currentScreening.waistCm.toStringAsFixed(1)} ซม.'),
                            _buildMetricRow(
                              'ความดันโลหิต',
                              '${currentScreening.sbp.toInt()}/${currentScreening.dbp.toInt()} mmHg',
                            ),
                            _buildMetricRow('ชีพจร', '${currentScreening.pulse.toInt()} ครั้ง/นาที'),
                            _buildMetricRow(
                              'น้ำตาลในเลือด',
                              '${currentScreening.bloodSugar.toStringAsFixed(1)} mg/dL',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Export PDF Button
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfPreviewPage(
                              patient: patient,
                              screening: currentScreening,
                              vhv: vhv,
                              nurse: nurse,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined, color: PColor.primaryColor),
                      label: const Text(
                        'ดูตัวอย่าง / พิมพ์เอกสารสรุปผล (PDF)',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: PColor.primaryColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: PColor.primaryColor, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Nurse Action Button
                    if (nurse != null) ...[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NurseApproveRiskPage(
                                nurse: nurse!,
                                patient: patient,
                                screening: currentScreening,
                              ),
                            ),
                          );
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
                          'ประเมินและยืนยันผล (Submit)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
              const PatientAccessibilityFloatingBubble(),
            ],
          ),
        );
      },
    );
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return PColor.riskHigh;
      case RiskLevel.moderate:
        return PColor.riskModerate;
      case RiskLevel.low:
        return PColor.riskLow;
    }
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13.5, color: PColor.textNeutralColor)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: PColor.contentColor,
            ),
          ),
        ],
      ),
    );
  }
}
