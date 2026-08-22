import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_standard/domain/models/ncd_models.dart';
import 'package:mobile_app_standard/feature/patient/bloc/patient_bloc.dart';
import 'package:mobile_app_standard/feature/patient/pages/add_edit_patient_page.dart';
import 'package:mobile_app_standard/feature/patient/pages/patient_history_list_page.dart';
import 'package:mobile_app_standard/feature/screening/pages/screening_form_page.dart';
import 'package:mobile_app_standard/shared/tokens/p_colors.dart';

class PatientDetailPage extends StatelessWidget {
  final Patient patient;
  final VHV? vhv;
  final Nurse? nurse;

  const PatientDetailPage({
    super.key,
    required this.patient,
    this.vhv,
    this.nurse,
  });

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'ต้องการลบผู้ป่วยรายนี้ไหม?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PColor.contentColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                patient.fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: PColor.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'ข้อมูลจะถูกลบออกจากระบบอย่างถาวร',
                style: TextStyle(
                  fontSize: 12.5,
                  color: PColor.textNeutralColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(color: PColor.textNeutralColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PColor.errorColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        context.read<PatientBloc>().add(
                              PatientDeleteRequested(patient.patientId),
                            );
                        Navigator.pop(dialogContext); // Close dialog
                        Navigator.pop(context); // Close detail page
                      },
                      child: const Text(
                        'ยืนยันลบ',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientBloc, PatientState>(
      builder: (context, state) {
        // Fetch most up-to-date patient object if available in state
        final currentPatient = state.patients.firstWhere(
          (p) => p.patientId == patient.patientId,
          orElse: () => patient,
        );

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
              'รายละเอียดผู้ป่วย',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            actions: [
              if (vhv != null) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditPatientPage(
                          vhv: vhv,
                          patient: currentPatient,
                          villageId: currentPatient.villageId,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                  onPressed: () => _showDeleteConfirmation(context),
                ),
              ],
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Card with Avatar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: PColor.primaryLight.withOpacity(0.15),
                        child: const Icon(Icons.person, size: 54, color: PColor.primaryColor),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        currentPatient.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: PColor.contentColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: PColor.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'รหัสผู้ป่วย: ${currentPatient.patientId}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: PColor.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Patient Information Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('เลขบัตรประชาชน', currentPatient.patientCitizenId),
                      const Divider(height: 24),
                      _buildInfoRow('ชื่อ - นามสกุล', currentPatient.fullName),
                      const Divider(height: 24),
                      _buildInfoRow('เพศ', currentPatient.patientGender),
                      const Divider(height: 24),
                      _buildInfoRow('อายุ', '${currentPatient.age} ปี'),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'วันเกิด',
                        '${currentPatient.patientBirthDate.day.toString().padLeft(2, '0')}/${currentPatient.patientBirthDate.month.toString().padLeft(2, '0')}/${currentPatient.patientBirthDate.year + 543}',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('ที่อยู่', currentPatient.patientAddress),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Action 1: Start Screening (If VHV is logged in)
                if (vhv != null) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScreeningFormPage(
                            patient: currentPatient,
                            vhv: vhv!,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.assignment_outlined, color: Colors.white),
                    label: const Text(
                      'เริ่มคัดกรอง / ประเมินความเสี่ยง',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PColor.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Action 2: View Screening History
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientHistoryListPage(
                          patient: currentPatient,
                          nurse: nurse,
                          vhv: vhv,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history_rounded, color: PColor.primaryColor),
                  label: const Text(
                    'ดูประวัติการคัดกรอง',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: PColor.primaryColor,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: PColor.primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: PColor.textNeutralColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: PColor.contentColor,
            ),
          ),
        ),
      ],
    );
  }
}
