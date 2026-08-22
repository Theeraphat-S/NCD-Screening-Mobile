import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_standard/domain/models/ncd_models.dart';
import 'package:mobile_app_standard/feature/auth/pages/user_type_selection_page.dart';
import 'package:mobile_app_standard/feature/patient/bloc/patient_bloc.dart';
import 'package:mobile_app_standard/feature/patient/pages/add_edit_patient_page.dart';
import 'package:mobile_app_standard/feature/patient/pages/patient_detail_page.dart';
import 'package:mobile_app_standard/feature/patient/pages/vhv_search_patient_page.dart';
import 'package:mobile_app_standard/shared/tokens/p_colors.dart';

class VhvPatientListPage extends StatefulWidget {
  final VHV vhv;

  const VhvPatientListPage({super.key, required this.vhv});

  @override
  State<VhvPatientListPage> createState() => _VhvPatientListPageState();
}

class _VhvPatientListPageState extends State<VhvPatientListPage> {
  @override
  void initState() {
    super.initState();
    context.read<PatientBloc>().add(
          PatientLoadRequested(villageId: widget.vhv.villageId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: PColor.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const UserTypeSelectionPage()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'รายชื่อผู้ป่วย',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VhvSearchPatientPage(vhv: widget.vhv),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Subheader Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: PColor.primaryDark,
            child: Row(
              children: [
                const Icon(Icons.person_pin_rounded, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'อสม. ${widget.vhv.fullName} (หมู่ ${widget.vhv.villageId.replaceAll('V', '')})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Patient List
          Expanded(
            child: BlocConsumer<PatientBloc, PatientState>(
              listener: (context, state) {
                if (state.message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message!),
                      backgroundColor: PColor.primaryDark,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == PatientStatus.loading && state.patients.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: PColor.primaryColor));
                }

                if (state.patients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'ไม่พบข้อมูลผู้ป่วย',
                          style: TextStyle(
                            fontSize: 16,
                            color: PColor.textNeutralColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: PColor.primaryColor,
                  onRefresh: () async {
                    context.read<PatientBloc>().add(
                          PatientLoadRequested(villageId: widget.vhv.villageId),
                        );
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: state.patients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final patient = state.patients[index];
                      return _buildPatientCard(context, patient);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: PColor.primaryColor,
        elevation: 4,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text(
          'เพิ่มผู้ป่วย',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditPatientPage(
                vhv: widget.vhv,
                villageId: widget.vhv.villageId,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, Patient patient) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.04),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          context.read<PatientBloc>().add(PatientSelected(patient));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientDetailPage(
                patient: patient,
                vhv: widget.vhv,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: PColor.primaryLight.withOpacity(0.15),
                child: const Icon(
                  Icons.person,
                  color: PColor.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: PColor.contentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'เลขบัตร: ${patient.patientCitizenId}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: PColor.textNeutralColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFFBDBDBD),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
