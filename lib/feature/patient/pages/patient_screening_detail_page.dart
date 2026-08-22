import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_standard/domain/models/ncd_models.dart';
import 'package:mobile_app_standard/feature/nurse/pages/nurse_approve_risk_page.dart';
import 'package:mobile_app_standard/feature/screening/bloc/screening_bloc.dart';
import 'package:mobile_app_standard/shared/tokens/p_colors.dart';

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
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Meta Date & Status Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'วันที่คัดกรอง: $dateStr',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: PColor.contentColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPending ? Colors.orange.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isPending ? Colors.orange : Colors.green,
                          ),
                        ),
                        child: Text(
                          'สถานะ: ${currentScreening.reviewStatus.labelTh}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isPending ? Colors.orange.shade800 : Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Patient Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: PColor.primaryLight.withOpacity(0.15),
                        child: const Icon(Icons.person, size: 36, color: PColor.primaryColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.fullName,
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: PColor.contentColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'เลขบัตร: ${patient.patientCitizenId}',
                              style: const TextStyle(fontSize: 12.5, color: PColor.textNeutralColor),
                            ),
                            Text(
                              'เพศ: ${patient.patientGender} • อายุ: ${currentScreening.ageAtScreening} ปี',
                              style: const TextStyle(fontSize: 12.5, color: PColor.textNeutralColor),
                            ),
                            Text(
                              'ที่อยู่: ${patient.patientAddress}',
                              style: const TextStyle(fontSize: 12, color: PColor.textNeutralColor),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Evaluation Results (4 Diseases)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ผลการประเมิน (4 โรค)',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: PColor.primaryDark,
                        ),
                      ),
                      const Divider(height: 18),
                      ...currentScreening.results.map((res) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                res.diseaseName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: PColor.contentColor,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getRiskColor(res.riskLevel).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  res.riskLevel.labelTh,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _getRiskColor(res.riskLevel),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Section 1: Physical Check
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ตอนที่ 1: ตรวจร่างกาย',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: PColor.primaryDark,
                        ),
                      ),
                      const Divider(height: 18),
                      _buildMetricRow('น้ำหนัก', '${currentScreening.weight.toStringAsFixed(0)} kg'),
                      _buildMetricRow('ส่วนสูง', '${currentScreening.height.toStringAsFixed(0)} cm'),
                      _buildMetricRow('BMI', '${currentScreening.bmi.toStringAsFixed(1)} kg/m²'),
                      _buildMetricRow('รอบเอว', '${currentScreening.waistCm.toStringAsFixed(0)} cm'),
                      _buildMetricRow('ความดันตัวบน (Systolic)', '${currentScreening.sbp.toStringAsFixed(0)} mmHg'),
                      _buildMetricRow('ความดันตัวล่าง (Diastolic)', '${currentScreening.dbp.toStringAsFixed(0)} mmHg'),
                      _buildMetricRow('ชีพจรขณะพัก', '${currentScreening.pulse.toStringAsFixed(0)} ครั้ง/นาที'),
                      _buildMetricRow('ระดับน้ำตาลในเลือด', '${currentScreening.bloodSugar.toStringAsFixed(0)} mg/dL'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Section 2: Medical History
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ตอนที่ 2: ประวัติบุคคล/ครอบครัว',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: PColor.primaryDark,
                        ),
                      ),
                      const Divider(height: 18),
                      ...currentScreening.histories.map((h) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                h.questionText,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: PColor.contentColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'คำตอบ: ${h.answerText}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: PColor.primaryDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

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
